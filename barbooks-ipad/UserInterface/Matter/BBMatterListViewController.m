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

@interface BBMatterListViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *matterListTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *archiveBarButtonItem;

@property (strong, nonatomic) NSArray *originalItemList;
@property (strong, nonatomic) NSArray *filteredItemList;

- (IBAction)onAdd:(id)sender;
- (IBAction)onArchive:(id)sender;

@end

@implementation BBMatterListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // tableview
    _matterListTableView.dataSource = self;
    _matterListTableView.delegate = self;
    [self registerRefreshControlFor:_matterListTableView withAction:@selector(fetchMatters)];
    
    // toolbar buttons
    UIImage *imageAdd = [[UIImage imageNamed:@"button_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *imageArchive = [[UIImage imageNamed:@"button_archive"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _addBarButtonItem.image = imageAdd;
    _archiveBarButtonItem.image = imageArchive;
    
    [self fetchMatters];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // user pressed back button in Navigation Bar
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [self.matterViewController.navigationController popViewControllerAnimated:YES];
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
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Matter *matter = [_filteredItemList objectAtIndex:indexPath.row];
    _matterViewController.matter = matter;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    Matter *matter = [_filteredItemList objectAtIndex:indexPath.row];
    [self showMatterCategory:matter];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 123;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 123;
}

#pragma mark - TableView helper methods

- (NSIndexPath *)indexPathOfMatter:(Matter *)matter {
    return [NSIndexPath indexPathForRow:[_originalItemList indexOfObject:matter] inSection:0];
}

#pragma mark - Core data

- (void)fetchMatters {
    // fetch from core data
    _originalItemList = [Matter MR_findAll];
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
}

#pragma mark - IBActions

- (IBAction)onAdd:(id)sender {
    Matter *newMatter = [Matter newInstanceWithDefaultValue];
    [self.matterViewController setMatter:newMatter];
    [self fetchMatters];
    [_matterListTableView selectRowAtIndexPath:[self indexPathOfMatter:newMatter] animated:YES scrollPosition:UITableViewScrollPositionTop];
    _matterViewController.matter = newMatter;
}

- (IBAction)onArchive:(id)sender {
}

#pragma mark - Navigation

- (void)showMatterCategory:(Matter *)matter {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BBMatterCategoryListViewController *matterCategoryListViewController = [storyboard instantiateViewControllerWithIdentifier:StoryboardIdBBMatterCategoryListViewController];
    BBTaskListViewController *taskListViewController = [storyboard instantiateViewControllerWithIdentifier:StoryboardIdBBTaskListViewController];
    [(UINavigationController *)[self.splitViewController masterViewController] pushViewController:matterCategoryListViewController animated:YES];
    [(UINavigationController *)[self.splitViewController detailViewController] pushViewController:taskListViewController animated:YES];
    matterCategoryListViewController.matter = matter;
    matterCategoryListViewController.taskListViewController = taskListViewController;
    taskListViewController.matter = matter;
}

@end
