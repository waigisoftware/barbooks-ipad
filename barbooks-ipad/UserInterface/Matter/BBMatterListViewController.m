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
#import "BBInvoiceListViewController.h"
#import "BBReceiptListViewController.h"
#import "BBExpenseListViewController.h"
#import "BBTaskTimer.h"
#import "Account.h"
#import "Rate.h"
#import "Disbursement.h"

@interface BBMatterListViewController () <UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate> {
    BOOL _showUnarchived;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *archiveBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *filterButtonItem;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@property (strong, nonatomic) Matter *selectedMatter;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

- (IBAction)onAdd:(id)sender;
- (IBAction)onArchive:(id)sender;
- (IBAction)onDelete:(id)sender;
- (IBAction)onFilterMatters:(id)sender;

@end

@implementation BBMatterListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _toolBar.clipsToBounds = YES;
    _showUnarchived = YES;


    // tableview
    _matterListTableView.dataSource = self;
    _matterListTableView.delegate = self;

    [_matterListTableView setContentOffset:CGPointMake(0, self.searchBar.frame.size.height)];
    
    // toolbar buttons
    UIImage *imageAdd = [[UIImage imageNamed:@"button_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *imageArchive = [[UIImage imageNamed:@"button_archive"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _addBarButtonItem.image = imageAdd;
    _archiveBarButtonItem.image = imageArchive;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self fetchMatters];

}



- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // pre-select matter
    if (self.createdObject) {
        if ([self.createdObject isKindOfClass:[Matter class]]) {

            [self.matterListTableView selectRowAtIndexPath:[self indexPathOfMatter:self.createdObject] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            [self showMatterDetail:self.createdObject];
        } else {
            [self performSegueWithIdentifier:BBSegueShowMatterEntries sender:self.createdObject];
        }
        self.createdObject = nil;
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // user pressed back button in Navigation Bar
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [(UINavigationController *)[self.splitViewController detailViewController] popToRootViewControllerAnimated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [_searchBar setShowsCancelButton:YES animated:YES];

//    [self filterContentForSearchText:searchText scope:nil];
    [self.matterListTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar setShowsCancelButton:NO animated:YES];
    searchBar.text = nil;
//    [self filterContentForSearchText:nil scope:nil];
    [self.matterListTableView reloadData];
}

- (IBAction)onEdit:(id)sender {
    if (self.matterListTableView.editing) {
        
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onEdit:)];
        
        [self.tabBarController.navigationItem setRightBarButtonItems:@[editButton] animated:YES];
        
    } else {
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onEdit:)];
        
        [self.navigationController.navigationItem setRightBarButtonItems:@[editButton] animated:YES];
    }
    
    [self.matterListTableView setEditing:!self.matterListTableView.editing animated:YES];
    
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"matterCell";
    BBMatterListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(BBMatterListTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Matter *matter = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.matterNameLabel.text = matter.name;
    cell.payorNameLabel.text = matter.payor;
    if ([[BBTaskTimer sharedInstance] currentTask] && [[[BBTaskTimer sharedInstance] currentTask] matter] == matter) {
        cell.timerIcon.hidden = NO;
    } else {
        cell.timerIcon.hidden = YES;
    }
    
    cell.tasksUnbilledAmountLabel.text = [[matter amountUnbilledTasks] currencyAmount];
    cell.invoicesOutstandingAmountLabel.text = [[matter amountOutstandingInvoices] currencyAmount];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!tableView.editing) {
        Matter *matter = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self showTaskList:matter];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    Matter *matter = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self showMatterDetail:matter];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.rowHeight;
}

// handle delete

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Matter *matterToDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [matterToDelete MR_deleteEntity];
        [matterToDelete.managedObjectContext MR_saveToPersistentStoreAndWait];
    }
}

#pragma mark - TableView helper methods

- (NSIndexPath *)indexPathOfMatter:(Matter *)matter {
    return [self.fetchedResultsController indexPathForObject:matter];
}

#pragma mark - Core data

- (void)refreshMatters {
//    [self fetchMatters];
//    [_matterListTableView reloadData];
//    [self performSelector:@selector(stopAndUpdateDateOnRefreshControl) withObject:nil afterDelay:1];
}

#pragma mark - override
//
//- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
//    if (searchText && [searchText length] > 0) {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchText];
//        _filteredItemList = [NSMutableArray arrayWithArray:[_originalItemList filteredArrayUsingPredicate:predicate]];
//    } else {
//        _filteredItemList = _originalItemList;
//    }
//    //[_matterListTableView reloadData];
//}

#pragma mark - IBActions

- (IBAction)onAdd:(id)sender {
    Account *account = [BBAccountManager sharedManager].activeAccount;
    Matter *newMatter = [Matter MR_createEntity];
    newMatter.tax = [account.tax copy];
    newMatter.dueDate = [account.defaultDueDate copy];
    newMatter.account = [account MR_inContext:newMatter.managedObjectContext];
    
    for (Rate *rate in [BBAccountManager sharedManager].activeAccount.rates) {
        Rate *newRate = [Rate MR_createEntityInContext:newMatter.managedObjectContext];
        [rate copyValueToRate:newRate];
        [newMatter addRatesObject:newRate];
        newRate.matter = newMatter;
    }
    
    BOOL changes = newMatter.managedObjectContext.hasChanges;
    BOOL rootChanges = NSManagedObjectContext.MR_rootSavingContext.hasChanges;
    [newMatter.managedObjectContext MR_saveToPersistentStoreAndWait];
    changes = newMatter.managedObjectContext.hasChanges;
    rootChanges = NSManagedObjectContext.MR_rootSavingContext.hasChanges;

//    [self fetchMatters];
    
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [_matterListTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
//    if (_originalItemList.count && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        [_matterListTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
//    }
    //[self showTaskList:newMatter];
    [self showMatterDetail:newMatter];
}

- (IBAction)onArchive:(id)sender {
//    for (NSIndexPath *indexPath in self.matterListTableView.indexPathsForSelectedRows) {
//        Matter *selectedMatter = [_filteredItemList objectAtIndex:indexPath.row];
//        selectedMatter.archived = [NSNumber numberWithBool:YES];
//        [self.filteredItemList removeObject:selectedMatter];
//    }
//    [[NSManagedObjectContext MR_rootSavingContext] MR_saveToPersistentStoreAndWait];
//
//    [_matterListTableView deleteRowsAtIndexPaths:@[self.matterListTableView.indexPathsForSelectedRows] withRowAnimation:UITableViewRowAnimationTop];
}

- (IBAction)onDelete:(id)sender {
//    Matter *selectedMatter = [_filteredItemList objectAtIndex:_matterListTableView.indexPathForSelectedRow.row];
//    [selectedMatter MR_deleteEntity];
//    [self fetchMatters];
    for (NSIndexPath *indexPath in self.matterListTableView.indexPathsForSelectedRows) {
        Matter *selectedMatter = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [selectedMatter MR_deleteEntity];
//        [self.filteredItemList removeObject:selectedMatter];
    }
    [[NSManagedObjectContext MR_rootSavingContext] MR_saveToPersistentStoreAndWait];

//    [self animateDeleteForSelections];
}

- (void)animateDeleteForSelections
{
    NSArray *selections = [_matterListTableView indexPathsForSelectedRows];
    [_matterListTableView deleteRowsAtIndexPaths:selections withRowAnimation:UITableViewRowAnimationTop];
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
    
    [self refreshMatters];
}

#pragma mark - Navigation

- (void)showTaskList:(Matter *)matter {
    
    [self performSegueWithIdentifier:BBSegueShowMatterEntries sender:matter];
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
    } else if ([[segue identifier] isEqualToString:BBSegueShowMatterEntries]) {
        Matter *matter = sender;
        if ([sender isKindOfClass:[Matter class]]) {
            matter = sender;
        } else {
            matter = [sender matter];
        }
        
        UITabBarController *tabBarController = (UITabBarController*)[(UINavigationController*)[segue destinationViewController] topViewController];
        tabBarController.selectedIndex = 0;
        if ([sender isKindOfClass:[Disbursement class]]) {
            tabBarController.selectedIndex = 1;
        }
        for (UIViewController *vc in [tabBarController viewControllers]) {
            if ([vc isKindOfClass:[BBTaskListViewController class]]) {
                BBTaskListViewController *taskListViewController = (BBTaskListViewController *)vc;
                taskListViewController.matter = matter;
                taskListViewController.matterListViewController = self;
                self.taskListViewController = taskListViewController;
                if ([sender isKindOfClass:[Task class]]) {
                    ((BBTaskListViewController *)vc).task = sender;
                }
            }
            if ([vc isKindOfClass:[BBExpenseListViewController class]]) {
                ((BBExpenseListViewController *)vc).matter = matter;
                if ([sender isKindOfClass:[Disbursement class]]) {
                    ((BBExpenseListViewController *)vc).expense = sender;
                }
            }
            if ([vc isKindOfClass:[BBInvoiceListViewController class]]) {
                ((BBInvoiceListViewController *)vc).matter = matter;
            }
            if ([vc isKindOfClass:[BBReceiptListViewController class]]) {
                ((BBReceiptListViewController *)vc).matter = matter;
            }
        }
    }
}

#pragma mark - BBMatterDelegate

- (void)updateMatter:(id)data {
    [self refreshMatters];
}

#pragma mark - NSFetchedResults

- (NSString *)entityName {
    return @"Matter";
}

- (NSArray *)sortDescriptors {
    return @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
}


- (NSPredicate *)filterPredicate {
    return [NSPredicate predicateWithFormat:@"account == %@ AND syncID != nil",[BBAccountManager sharedManager].activeAccount];
}


@end
