//
//  BBMatterListViewController.m
//  barbooks-ipad
//
//  Created by Can on 6/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBMatterListViewController.h"
#import "BBCoreDataManager.h"
#import "BBMatterListTableViewCell.h"
#import "BBMatterCategoryListViewController.h"
#import "BBTaskListViewController.h"
#import "BBExpenseListViewController.h"
#import "BBInvoiceListViewController.h"

@interface BBMatterListViewController () {
    BOOL _showUnarchived;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *matterListTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *archiveBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *filterButtonItem;

@property (strong, nonatomic) NSArray *originalItemList;
@property (strong, nonatomic) NSArray *filteredItemList;

@property (strong, nonatomic) Matter *selectedMatter;

- (IBAction)onAdd:(id)sender;
- (IBAction)onArchive:(id)sender;
- (IBAction)onDelete:(id)sender;
- (IBAction)onFilterMatters:(id)sender;

@end

@implementation BBMatterListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _showUnarchived = YES;

    // tableview
    _matterListTableView.dataSource = self;
    _matterListTableView.delegate = self;
    [self registerRefreshControlFor:_matterListTableView withAction:@selector(fetchMatters)];
    
    // toolbar buttons
    UIImage *imageAdd = [[UIImage imageNamed:@"button_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *imageArchive = [[UIImage imageNamed:@"button_archive"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _addBarButtonItem.image = imageAdd;
    _archiveBarButtonItem.image = imageArchive;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchMatters];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // pre-select matter
    NSUInteger index = [_originalItemList indexOfObject:self.matter];
    if (index != NSNotFound) {
        [_matterListTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // user pressed back button in Navigation Bar
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [self.taskListViewController.navigationController popToRootViewControllerAnimated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _filteredItemList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"matterCell";
    BBMatterListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    Matter *matter = [_filteredItemList objectAtIndex:indexPath.row];
    cell.matterNameLabel.text = matter.name;
    cell.payorNameLabel.text = matter.payor;
    cell.tasksUnbilledAmountLabel.text = [[matter totalTasksUnbilled] currencyAmount];
    cell.invoicesOutstandingAmountLabel.text = [[matter totalInvoicesOutstanding] currencyAmount];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Matter *matter = [_filteredItemList objectAtIndex:indexPath.row];
    [self showTaskList:matter];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    Matter *matter = [_filteredItemList objectAtIndex:indexPath.row];
    [self showMatterDetail:matter];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 123;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 123;
}

// handle delete

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Matter *matterToDelete = [_originalItemList objectAtIndex:indexPath.row];
        [matterToDelete MR_deleteEntity];
        [self fetchMatters];
    }
}

#pragma mark - TableView helper methods

- (NSIndexPath *)indexPathOfMatter:(Matter *)matter {
    return [NSIndexPath indexPathForRow:[_originalItemList indexOfObject:matter] inSection:0];
}

#pragma mark - Core data

- (void)fetchMatters {
    // fetch from core data
    _originalItemList = _showUnarchived ? [Matter unarchivedMatters] : [Matter archivedMatters];
    [self filterContentForSearchText:_searchBar.text scope:nil];
    [_matterListTableView reloadData];
    [self stopAndUpdateDateOnRefreshControl];
}

#pragma mark - override

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    if (searchText && [searchText length] > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchText];
        _filteredItemList = [_originalItemList filteredArrayUsingPredicate:predicate];
    } else {
        _filteredItemList = _originalItemList;
    }
    [_matterListTableView reloadData];
}

#pragma mark - IBActions

- (IBAction)onAdd:(id)sender {
    Matter *newMatter = [Matter newInstanceWithDefaultValue];
    [self fetchMatters];
    [_matterListTableView selectRowAtIndexPath:[self indexPathOfMatter:newMatter] animated:YES scrollPosition:UITableViewScrollPositionTop];
    [self showTaskList:newMatter];
}

- (IBAction)onArchive:(id)sender {
    Matter *selectedMatter = [_filteredItemList objectAtIndex:_matterListTableView.indexPathForSelectedRow.row];
    selectedMatter.archived = [NSNumber numberWithBool:YES];
    [self fetchMatters];
}

- (IBAction)onDelete:(id)sender {
    Matter *selectedMatter = [_filteredItemList objectAtIndex:_matterListTableView.indexPathForSelectedRow.row];
    [selectedMatter MR_deleteEntity];
    [self fetchMatters];
}

- (IBAction)onFilterMatters:(id)sender {
    _showUnarchived = !_showUnarchived;
    _filterButtonItem.title = _showUnarchived ? @"Archived" : @"Unarchived";
    
    // toggle other bar buttons
    [_archiveBarButtonItem setTintColor:_showUnarchived ? [UIColor blackColor] : [UIColor clearColor]];
    [_archiveBarButtonItem setEnabled:_showUnarchived];
    [_archiveBarButtonItem setImage:_showUnarchived ? [[UIImage imageNamed:@"button_archive"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] : nil];
    [_deleteBarButtonItem setTintColor:!_showUnarchived ? [UIColor blackColor] : [UIColor clearColor]];
    [_deleteBarButtonItem setEnabled:!_showUnarchived];
    [_deleteBarButtonItem setImage:!_showUnarchived ? [[UIImage imageNamed:@"button_delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] : nil];
    
    [self fetchMatters];
}

#pragma mark - Navigation

- (void)showTaskList:(Matter *)matter {
    UITabBarController *tabBarController = [self.mainStoryboard instantiateViewControllerWithIdentifier:StoryboardIdBBMatterCategoryTabBarController];
    tabBarController.selectedIndex = 0;
    for (UIViewController *vc in [tabBarController viewControllers]) {
        if ([vc isKindOfClass:[BBTaskListViewController class]]) {
            ((BBTaskListViewController *)vc).matter = matter;
        }
        if ([vc isKindOfClass:[BBExpenseListViewController class]]) {
            ((BBExpenseListViewController *)vc).matter = matter;
        }
        if ([vc isKindOfClass:[BBInvoiceListViewController class]]) {
            ((BBInvoiceListViewController *)vc).matter = matter;
        }
    }
    [(UINavigationController *)[self.splitViewController detailViewController] popToRootViewControllerAnimated:NO];
    [(UINavigationController *)[self.splitViewController detailViewController] pushViewController:tabBarController animated:NO];
}

- (void)showMatterDetail:(Matter *)matter {
    self.selectedMatter = matter;
    [self performSegueWithIdentifier:BBSegueShowMatterDetail sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:BBSegueShowMatterDetail]) {
        BBMatterViewController *matterViewController = [((UINavigationController *)[segue destinationViewController]).viewControllers objectAtIndex:0];
        matterViewController.matter = self.selectedMatter;
        matterViewController.matterListViewController = self;
    }
}

@end
