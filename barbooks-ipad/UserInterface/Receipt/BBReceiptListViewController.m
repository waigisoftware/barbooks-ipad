//
//  BBReceiptListViewController.m
//  barbooks-ipad
//
//  Created by Can on 24/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBReceiptListViewController.h"
#import "BBReceiptTableViewCell.h"

@interface BBReceiptListViewController () {
    BOOL _showUnarchived;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *receiptListTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *archiveBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *filterButtonItem;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeight;

@property (strong, nonatomic) NSMutableArray *originalItemList;
@property (strong, nonatomic) NSMutableArray *filteredItemList;
@property (strong, nonatomic) Receipt *selectedReceipt;

- (IBAction)onAdd:(id)sender;
- (IBAction)onArchive:(id)sender;
- (IBAction)onDelete:(id)sender;
- (IBAction)onFilterReceipts:(id)sender;

@end

@implementation BBReceiptListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _showUnarchived = YES;
    
    // tableview
    _receiptListTableView.dataSource = self;
    _receiptListTableView.delegate = self;
    _receiptListTableView.estimatedRowHeight = _receiptListTableView.rowHeight;
    _receiptListTableView.rowHeight = UITableViewAutomaticDimension;
    
    [self registerRefreshControlFor:_receiptListTableView withAction:@selector(refreshReceipts)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // setup navigation bar and toolbar
    [self setupUI];
    [_receiptListTableView setContentOffset:CGPointMake(0, _searchBar.frame.size.height)];
    [self refreshReceipts];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // user pressed back button in Navigation Bar
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [self.receiptViewController.navigationController popViewControllerAnimated:YES];
    }
    _receiptListTableView.editing = NO;
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
    static NSString *reuseIdentifier = @"receiptCell";
    BBReceiptTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    Receipt *receipt = [_filteredItemList objectAtIndex:indexPath.row];
    cell.receiptNumberLabel.text = [receipt.entryNumber stringValue];
    cell.paidAmountLabel.text = [receipt.totalAmount currencyAmount];
    cell.paidDateLabel.text = [receipt.date toShortDateFormat];
    cell.invoiceNumberLabel.text = receipt.invoicesNumber;
    cell.matterDescriptionLabel.text = receipt.mattersDescription;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    Receipt *receipt = [_filteredItemList objectAtIndex:indexPath.row];
    if ([self isMatterReceipts]) {
        [self showReceiptDetail:receipt];
    } else {
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Receipt *receipt = [_filteredItemList objectAtIndex:indexPath.row];
    if ([self isMatterReceipts]) {
        [self showReceiptDetail:receipt];
    } else {
        _receiptViewController.receipt = receipt;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Receipt *receipt = [self.filteredItemList objectAtIndex:indexPath.row];
    BBReceiptTableViewCell *cell = (id)[tableView cellForRowAtIndexPath:indexPath];
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:15]};
    // NSString class method: boundingRectWithSize:options:attributes:context is
    // available only on ios7.0 sdk.
    CGRect rect = [receipt.info boundingRectWithSize:CGSizeMake(cell.matterDescriptionLabel.frame.size.width, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:attributes
                                             context:nil];
    
    CGSize size = rect.size;
    size.height += tableView.estimatedRowHeight;
    
    return MAX(size.height, tableView.estimatedRowHeight);
    return tableView.estimatedRowHeight;
}

// handle delete

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Receipt *receiptToDelete = [_filteredItemList objectAtIndex:indexPath.row];
        [receiptToDelete MR_deleteEntity];
        [receiptToDelete.managedObjectContext MR_saveToPersistentStoreAndWait];
        [self fetchReceipts];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
}

#pragma mark - TableView helper methods

- (NSIndexPath *)indexPathOfReceipt:(Receipt *)receipt {
    return [NSIndexPath indexPathForRow:[_filteredItemList indexOfObject:receipt] inSection:0];
}

#pragma mark - Core data

- (void)fetchReceipts {
    // fetch from core data
    if ([self isMatterReceipts]) {
//        NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"matter == %@", @[self.matter]];
        //        _originalItemList = [Receipt MR_findAllSortedBy:@"date" ascending:NO withPredicate:fetchPredicate];
        NSArray *objects = _showUnarchived ? [Receipt unarchivedReceipts] : [Receipt archivedReceipts];
        _originalItemList = [NSMutableArray arrayWithArray:objects];
    } else {
        NSArray *objects = _showUnarchived ? [Receipt unarchivedReceipts] : [Receipt archivedReceipts];
        _originalItemList = [NSMutableArray arrayWithArray:objects];
    }
    [self filterContentForSearchText:_searchBar.text scope:nil];
}

- (void)refreshReceipts {
    [self fetchReceipts];
    [_receiptListTableView reloadData];
    [self stopAndUpdateDateOnRefreshControl];
//    [_receiptListTableView setContentOffset:CGPointMake(0, _searchBar.frame.size.height) animated:YES];
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
    NSIndexPath *indexPath = [_receiptListTableView indexPathForCell:cell];
    
    Receipt *receipt = [self.filteredItemList objectAtIndex:indexPath.row];
    receipt.info = textView.text;
    
    [UIView setAnimationsEnabled:NO];
    [_receiptListTableView beginUpdates];
    [_receiptListTableView endUpdates];
    [UIView setAnimationsEnabled:YES];
    
    CGRect rect = [_receiptListTableView rectForRowAtIndexPath:indexPath];
    [_receiptListTableView scrollRectToVisible:rect animated:NO];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    id cell = textView.superview.superview;
    NSIndexPath *indexPath = [_receiptListTableView indexPathForCell:cell];
    
    Task *task = [self.filteredItemList objectAtIndex:indexPath.row];
    [task.managedObjectContext MR_saveToPersistentStoreAndWait];
}

#pragma mark - IBActions

- (IBAction)onAdd:(id)sender {
    if ([self isMatterReceipts]) {
        Receipt *newReceipt = [Receipt newInstanceOfMatter:self.matter];
        [self fetchReceipts];
//        [_receiptListTableView selectRowAtIndexPath:[self indexPathOfReceipt:newReceipt] animated:YES scrollPosition:UITableViewScrollPositionTop];
        [self showReceiptDetail:newReceipt];
    } else {
        Receipt *newReceipt = [Receipt newInstanceOfMatter:nil];
        [self.receiptViewController setReceipt:newReceipt];
        [self refreshReceipts];
        [_receiptListTableView selectRowAtIndexPath:[self indexPathOfReceipt:newReceipt] animated:YES scrollPosition:UITableViewScrollPositionTop];
        _receiptViewController.receipt = newReceipt;
    }
}

- (IBAction)onArchive:(id)sender {
    Receipt *selectedReceipt = [_filteredItemList objectAtIndex:_receiptListTableView.indexPathForSelectedRow.row];
    NSIndexPath *indexPath = [self indexPathOfReceipt:selectedReceipt];
    selectedReceipt.archived = [NSNumber numberWithBool:YES];
    [_filteredItemList removeObject:selectedReceipt];
    [_receiptListTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
}

- (void)onDelete {
    //    _receiptListTableView.editing = !_receiptListTableView.editing;
//    Receipt *selectedReceipt = [_filteredItemList objectAtIndex:_receiptListTableView.indexPathForSelectedRow.row];
//    [selectedReceipt MR_deleteEntity];
//    [self fetchReceipts];
    [self animateDeleteForSelections];
}

- (void)animateDeleteForSelections
{
    NSArray *selections = [_receiptListTableView indexPathsForSelectedRows];
    [_receiptListTableView deleteRowsAtIndexPaths:selections withRowAnimation:UITableViewRowAnimationTop];
}

- (void)onEdit {
    if (_receiptListTableView.editing) {
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
    
    [_receiptListTableView setEditing:!_receiptListTableView.editing animated:YES];
}

- (IBAction)onDelete:(id)sender {
    Receipt *selectedReceipt = [_filteredItemList objectAtIndex:_receiptListTableView.indexPathForSelectedRow.row];
    [selectedReceipt MR_deleteEntity];
    [self fetchReceipts];
    [self animateDeleteForSelections];
}

- (IBAction)onFilterReceipts:(id)sender {
    _showUnarchived = !_showUnarchived;
    _filterButtonItem.title = _showUnarchived ? @"Archived" : @"Unarchived";
    
    // toggle other bar buttons
    [_archiveBarButtonItem setTintColor:_showUnarchived ? [UIColor blackColor] : [UIColor clearColor]];
    [_archiveBarButtonItem setEnabled:_showUnarchived];
    [_archiveBarButtonItem setImage:_showUnarchived ? [[UIImage imageNamed:@"button_archive"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] : nil];
    [_deleteBarButtonItem setTintColor:!_showUnarchived ? [UIColor blackColor] : [UIColor clearColor]];
    [_deleteBarButtonItem setEnabled:!_showUnarchived];
    [_deleteBarButtonItem setImage:!_showUnarchived ? [[UIImage imageNamed:@"button_delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] : nil];
    
    [self refreshReceipts];
}

#pragma mark - UI method

// if the receipt list is showing all receipts or a Matter's receipts
- (BOOL)isMatterReceipts {
    return self.matter ? YES : NO;
}

- (void)setupUI {
    if ([self isMatterReceipts]) {
        // hide back button
        self.tabBarController.navigationItem.hidesBackButton = YES;
        self.tabBarController.navigationItem.title = @"Receipts";
        // add 'Add' & 'Delete' button
        UIImage *imageAdd = [[UIImage imageNamed:@"button_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *imageDelete = [[UIImage imageNamed:@"button_delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:imageAdd style:UIBarButtonItemStylePlain target:self action:@selector(onAdd:)];
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithImage:imageDelete style:UIBarButtonItemStylePlain target:self action:@selector(onDelete)];
        self.tabBarController.navigationItem.rightBarButtonItems = @[deleteButton, addButton];
        // toolbar buttons
        self.toolbarHeight.constant = 0;
        self.toolbar.hidden = YES;
        
        [self.view updateConstraintsIfNeeded];
    } else {
        // show back button
        self.navigationItem.hidesBackButton = NO;
        self.navigationItem.title = nil;
        // toolbar buttons
        self.toolbarHeight.constant = 44;
        self.toolbar.hidden = NO;
        UIImage *imageAdd = [[UIImage imageNamed:@"button_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *imageArchive = [[UIImage imageNamed:@"button_archive"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _addBarButtonItem.image = imageAdd;
        _archiveBarButtonItem.image = imageArchive;
        
        [self.view updateConstraintsIfNeeded];
    }
}

#pragma mark - Navigation

- (void)showReceiptDetail:(Receipt *)receipt {
    self.selectedReceipt = receipt;
    [self performSegueWithIdentifier:BBSegueShowReceiptDetail sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:BBSegueShowReceiptDetail]) {
        BBReceiptViewController *receiptViewController = (BBReceiptViewController *)[segue destinationViewController];
        receiptViewController.receipt = self.selectedReceipt;
        receiptViewController.matter = self.matter;
        receiptViewController.delegate = self;
    }
}


#pragma mark - BBReceiptDelegate

- (void)updateReceipt:(id)data {
    [self fetchReceipts];
}

@end
