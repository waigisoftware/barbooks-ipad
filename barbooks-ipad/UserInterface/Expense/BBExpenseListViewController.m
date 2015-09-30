//
//  BBExpenseListViewController.m
//  barbooks-ipad
//
//  Created by Can on 11/07/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBExpenseListViewController.h"
#import "BBExpenseTableViewCell.h"
#import "Disbursement.h"
#import "GeneralExpense.h"
#import "TaxExpense.h"
#import "Account.h"

@interface BBExpenseListViewController () {
    BOOL _showUnarchived;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *expenseListTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *archiveBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *filterButtonItem;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeight;

@property (strong, nonatomic) NSArray *originalItemList;
@property (strong, nonatomic) NSArray *filteredItemList;

- (IBAction)onAdd:(id)sender;
- (IBAction)onArchive:(id)sender;
- (IBAction)onDelete:(id)sender;
- (IBAction)onFilterExpenses:(id)sender;

@end

@implementation BBExpenseListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _showUnarchived = YES;
    
    // tableview
    _expenseListTableView.dataSource = self;
    _expenseListTableView.delegate = self;
    _expenseListTableView.estimatedRowHeight = _expenseListTableView.rowHeight;
    _expenseListTableView.rowHeight = UITableViewAutomaticDimension;

    if ([self isMatterExpenses]) {
        _expenseListTableView.backgroundColor = [UIColor whiteColor];
    }
    
    [self registerRefreshControlFor:_expenseListTableView withAction:@selector(refreshExpenses)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // setup navigation bar and toolbar
    [self setupUI];
    [_expenseListTableView setContentOffset:CGPointMake(0, _searchBar.frame.size.height)];
    [self refreshExpenses];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.expense) {
        if ([self isMatterExpenses]) {
            BBExpenseTableViewCell *cell = (id)[_expenseListTableView cellForRowAtIndexPath:[self indexPathOfExpense:self.expense]];
            [cell.descriptionLabel becomeFirstResponder];
        } else {
            [self performSegueWithIdentifier:BBSegueShowExpenseDetail sender:self.expense];
        }
        self.expense = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // user pressed back button in Navigation Bar
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [self.expenseViewController.navigationController popViewControllerAnimated:YES];
    }
    _expenseListTableView.editing = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [_searchBar setShowsCancelButton:YES animated:YES];
    
    [self filterContentForSearchText:searchText scope:nil];
    [self.expenseListTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar setShowsCancelButton:NO animated:YES];
    searchBar.text = nil;
    [self filterContentForSearchText:nil scope:nil];
    [self.expenseListTableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _filteredItemList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Expense *expense = [_filteredItemList objectAtIndex:indexPath.row];
    NSString *reuseIdentifier = [self isMatterExpenses] ? @"disbursementCell" : @"expenseCell";

    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    BBExpenseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.descriptionLabel.text = expense.info;
    cell.payeeLabel.text = expense.payee;
    cell.dateLabel.text = [dateFormatter stringFromDate:expense.date];
    cell.amountLabel.text = [expense.amountIncGst currencyAmount];
    cell.typeLabel.text = expense.classDisplayName;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    Expense *expense = [_filteredItemList objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:BBSegueShowExpenseDetailModal sender:expense];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!tableView.editing) {
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Expense *expense = [self.filteredItemList objectAtIndex:indexPath.row];
    BBExpenseTableViewCell *cell = (id)[tableView cellForRowAtIndexPath:indexPath];
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:15]};
    // NSString class method: boundingRectWithSize:options:attributes:context is
    // available only on ios7.0 sdk.
    CGRect rect = [expense.info boundingRectWithSize:CGSizeMake(cell.descriptionLabel.frame.size.width, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:attributes
                                             context:nil];
    
    CGSize size = rect.size;
    size.height += tableView.estimatedRowHeight;
    
    return MAX(size.height, tableView.estimatedRowHeight);
}

// handle delete

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Expense *expenseToDelete = [_originalItemList objectAtIndex:indexPath.row];
        [expenseToDelete MR_deleteEntity];
        [expenseToDelete.managedObjectContext MR_saveToPersistentStoreAndWait];
        [(BBIncrementalStore*)[[NSManagedObjectContext MR_rootSavingContext].persistentStoreCoordinator.persistentStores objectAtIndex:0] purgeCachedObjectsForEntityName:NSStringFromClass([GeneralExpense class])];

        [self fetchExpenses];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
}

#pragma mark - TableView helper methods

- (NSIndexPath *)indexPathOfExpense:(Expense *)expense {
    return [NSIndexPath indexPathForRow:[_filteredItemList indexOfObject:expense] inSection:0];
}

#pragma mark - Core data

- (void)fetchExpenses {
    [[NSManagedObjectContext MR_rootSavingContext] processPendingChanges];
    // fetch from core data
    if ([self isMatterExpenses]) {
        _originalItemList = [NSMutableArray arrayWithArray:[self.matter.disbursements allObjects]];
    } else {
        // For some reason calling [Expense MR_findAll] is not refreshing properly
        // TODO: make it work through [Expense MR_findAll] !

        NSArray *objects = [GeneralExpense MR_findAll];
        objects = [objects arrayByAddingObjectsFromArray:[Disbursement MR_findAll]];
        _originalItemList = [NSMutableArray arrayWithArray:objects];
    }
    [self filterContentForSearchText:_searchBar.text scope:nil];
}


- (void)refreshExpenses {
    
    [self fetchExpenses];
    [_expenseListTableView reloadData];
    [self performSelector:@selector(stopAndUpdateDateOnRefreshControl) withObject:nil afterDelay:1];
}

#pragma mark - override

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    if (searchText && [searchText length] > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"info contains[cd] %@", searchText];
        _filteredItemList = [NSMutableArray arrayWithArray:[_originalItemList filteredArrayUsingPredicate:predicate]];
    } else {
        _filteredItemList = _originalItemList;
    }
}

#pragma mark - UITextViewDelegate Methods

- (void)textViewDidChange:(UITextView *)textView
{
    id cell = textView.superview.superview;
    NSIndexPath *indexPath = [_expenseListTableView indexPathForCell:cell];
    
    Expense *expense = [self.filteredItemList objectAtIndex:indexPath.row];
    expense.info = textView.text;
    
    [UIView setAnimationsEnabled:NO];
    [_expenseListTableView beginUpdates];
    [_expenseListTableView endUpdates];
    [UIView setAnimationsEnabled:YES];
    
    CGRect rect = [_expenseListTableView rectForRowAtIndexPath:indexPath];
    [_expenseListTableView scrollRectToVisible:rect animated:NO];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    id cell = textView.superview.superview;
    NSIndexPath *indexPath = [_expenseListTableView indexPathForCell:cell];
    
    Task *task = [self.filteredItemList objectAtIndex:indexPath.row];
    [task.managedObjectContext MR_saveToPersistentStoreAndWait];
}

#pragma mark - IBActions

- (IBAction)onAdd:(id)sender {
    // add Disbursement for Matter
    if ([self isMatterExpenses]) {
        Disbursement *newDisbursement = [Disbursement newInstanceOfMatter:self.matter];
        [self refreshExpenses];
        NSIndexPath *path = [self indexPathOfExpense:newDisbursement];
        [_expenseListTableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionTop];
        
        CGRect rect = [_expenseListTableView rectForRowAtIndexPath:path];
        rect.origin.y += _expenseListTableView.contentInset.top;
        
        BBExpenseTableViewCell *cell = (id)[_expenseListTableView cellForRowAtIndexPath:path];
        [cell.descriptionLabel becomeFirstResponder];
        
        NSLog(@"add a Disbursement");
        return;
    }
    
    // add General Expense/Tax Expense
    
    // show selection
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Choose an expense type"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *generalExpenseAction = [UIAlertAction actionWithTitle:@"General Expense" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // choose the type of expense
        GeneralExpense *generalExpense = [GeneralExpense newInstanceWithDefaultValue];
        generalExpense.tax = [BBAccountManager sharedManager].activeAccount.tax;
        [self fetchExpenses];
        
        NSIndexPath *path = [self indexPathOfExpense:generalExpense];
        if (path.row != NSNotFound) {
            [_expenseListTableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationTop];
            [_expenseListTableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionTop];
        }
//        BBExpenseTableViewCell *cell = (id)[_expenseListTableView cellForRowAtIndexPath:path];
//        [cell.descriptionLabel becomeFirstResponder];
        [self performSegueWithIdentifier:BBSegueShowExpenseDetail sender:generalExpense];

        NSLog(@"add a GeneralExpense");
    }];
    UIAlertAction *taxPaymentAction = [UIAlertAction actionWithTitle:@"Tax Payment" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // choose the type of expense
        TaxExpense *taxExpense = [TaxExpense newInstanceWithDefaultValue];
        [(BBIncrementalStore*)[[NSManagedObjectContext MR_rootSavingContext].persistentStoreCoordinator.persistentStores objectAtIndex:0] purgeCachedObjectsForEntityName:NSStringFromClass([GeneralExpense class])];

        [self fetchExpenses];
        
        NSIndexPath *path = [self indexPathOfExpense:taxExpense];
        for (BBManagedObject *object in _filteredItemList) {
            if ([[object.objectID couchbaseLiteIDRepresentation] isEqualToString:[object.objectID couchbaseLiteIDRepresentation]]) {
                path = [NSIndexPath indexPathForRow:[_filteredItemList indexOfObject:object] inSection:0];
            }
        }
        if (path.row != NSNotFound) {
            [_expenseListTableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationTop];
            [_expenseListTableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionTop];
        }
        [self performSegueWithIdentifier:BBSegueShowExpenseDetail sender:taxExpense];
        
        NSLog(@"add a TaxExpense");
    }];
    
    
    [alertController addAction:cancelAction];
    [alertController addAction:generalExpenseAction];
    [alertController addAction:taxPaymentAction];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover) {
        popover.barButtonItem = sender;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)onDelete {
    //    _expenseListTableView.editing = !_expenseListTableView.editing;
//    Expense *selectedExpense = [_filteredItemList objectAtIndex:_expenseListTableView.indexPathForSelectedRow.row];
//    [selectedExpense MR_deleteEntity];
//    [self fetchExpenses];
    [self animateDeleteForSelections];
}

- (void)animateDeleteForSelections
{
    NSArray *selections = [_expenseListTableView indexPathsForSelectedRows];
    [_expenseListTableView deleteRowsAtIndexPaths:selections withRowAnimation:UITableViewRowAnimationTop];
}

- (void)onEdit {
    if (_expenseListTableView.editing) {
        UIImage *imageAdd = [[UIImage imageNamed:@"button_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:imageAdd style:UIBarButtonItemStylePlain target:self action:@selector(onAdd:)];
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onEdit)];
        
        [self.tabBarController.navigationItem setRightBarButtonItems:@[addButton,editButton] animated:YES];
        
    } else {
        UIImage *imageDelete = [[UIImage imageNamed:@"button_delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIBarButtonItem *removeButton = [[UIBarButtonItem alloc] initWithImage:imageDelete style:UIBarButtonItemStylePlain target:self action:@selector(onDelete)];
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onEdit)];
        
        [self.tabBarController.navigationItem setRightBarButtonItems:@[removeButton,editButton] animated:YES];
    }
    
    [_expenseListTableView setEditing:!_expenseListTableView.editing animated:YES];
}

- (IBAction)onDelete:(id)sender {
    Expense *selectedExpense = [_filteredItemList objectAtIndex:_expenseListTableView.indexPathForSelectedRow.row];
    [selectedExpense MR_deleteEntity];
    [self fetchExpenses];
    [self animateDeleteForSelections];
}

- (IBAction)onFilterExpenses:(id)sender {
    _showUnarchived = !_showUnarchived;
    _filterButtonItem.title = _showUnarchived ? @"Archived" : @"Unarchived";
    
    // toggle other bar buttons
    [_archiveBarButtonItem setTintColor:_showUnarchived ? [UIColor blackColor] : [UIColor clearColor]];
    [_archiveBarButtonItem setEnabled:_showUnarchived];
    [_archiveBarButtonItem setImage:_showUnarchived ? [[UIImage imageNamed:@"button_archive"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] : nil];
    [_deleteBarButtonItem setTintColor:!_showUnarchived ? [UIColor blackColor] : [UIColor clearColor]];
    [_deleteBarButtonItem setEnabled:!_showUnarchived];
    [_deleteBarButtonItem setImage:!_showUnarchived ? [[UIImage imageNamed:@"button_delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] : nil];
    
    [self refreshExpenses];
}

#pragma mark - UI method

// if the expense list is showing all expenses or a Matter's expenses
- (BOOL)isMatterExpenses {
    return self.matter ? YES : NO;
}

- (void)setupUI {
    if ([self isMatterExpenses]) {
        // hide back button
        self.tabBarController.navigationItem.title = @"Disbursements";
        // add 'Add' & 'Delete' button
        UIImage *imageAdd = [[UIImage imageNamed:@"button_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onEdit)];
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:imageAdd style:UIBarButtonItemStylePlain target:self action:@selector(onAdd:)];
        self.tabBarController.navigationItem.rightBarButtonItems = @[addButton,editButton];
        // toolbar buttons
        self.toolbarHeight.constant = 0;
        self.toolbar.hidden = YES;
        
        [self.view updateConstraintsIfNeeded];
    } else {
        // show back button
        self.navigationItem.title = @"Expenses";
        // toolbar buttons
        self.toolbarHeight.constant = 44;
        self.toolbar.hidden = NO;
        UIImage *imageAdd = [[UIImage imageNamed:@"button_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *imageArchive = [[UIImage imageNamed:@"button_archive"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _addBarButtonItem.image = imageAdd;
        _archiveBarButtonItem.image = imageArchive;
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onEdit)];
        self.navigationItem.rightBarButtonItems = @[editButton];

        [self.view updateConstraintsIfNeeded];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:BBSegueShowExpenseDetail] || [[segue identifier] isEqualToString:BBSegueShowExpenseDetailModal]) {
        Expense *expense = sender;
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            expense = [_filteredItemList objectAtIndex:[self.expenseListTableView indexPathForSelectedRow].row];
        }
        
        UINavigationController *navigationController = [segue destinationViewController];
        BBExpenseViewController *expenseViewController = (BBExpenseViewController *)[navigationController topViewController] ;
        expenseViewController.expense = expense;
        expenseViewController.delegate = self;
    }
}

- (IBAction)unwindToExpenseListViewController:(UIStoryboardSegue*)segue
{
    
}


#pragma mark - BBExpenseDelegate

- (void)updateExpense:(id)data {
    [self refreshExpenses];
}

- (void)didEnterBackground:(NSNotification *)notification
{
    [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
}

@end
