//
//  BBReceiptListViewController.m
//  barbooks-ipad
//
//  Created by Can on 24/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBReceiptListViewController.h"
#import "BBReceiptTableViewCell.h"

@interface BBReceiptListViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *receiptListTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *archiveBarButtonItem;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeight;

@property (strong, nonatomic) NSArray *originalItemList;
@property (strong, nonatomic) NSArray *filteredItemList;
@property (strong, nonatomic) Receipt *selectedReceipt;

- (IBAction)onAdd:(id)sender;
- (IBAction)onArchive:(id)sender;

@end

@implementation BBReceiptListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // tableview
    _receiptListTableView.dataSource = self;
    _receiptListTableView.delegate = self;
    [self registerRefreshControlFor:_receiptListTableView withAction:@selector(refreshReceipts)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshReceipts];
    [_receiptListTableView setContentOffset:CGPointMake(0, _searchBar.frame.size.height)];
    // setup navigation bar and toolbar
    [self setupUI];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Receipt *receipt = [_filteredItemList objectAtIndex:indexPath.row];
    if ([self isMatterReceipts]) {
        [self showReceiptDetail:receipt];
    } else {
        _receiptViewController.receipt = receipt;
    }
}

// handle delete

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Receipt *receiptToDelete = [_filteredItemList objectAtIndex:indexPath.row];
        if ([self isMatterReceipts]) {
//            [self.matter removeReceiptsObject:(Receipt *)receiptToDelete];
        } else {
            [receiptToDelete MR_deleteEntity];
        }
        [self fetchReceipts];
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
        _originalItemList = [Receipt MR_findAllSortedBy:@"date" ascending:NO];
    } else {
        _originalItemList = [Receipt MR_findAllSortedBy:@"date" ascending:NO];
    }
    [self filterContentForSearchText:_searchBar.text scope:nil];
}

- (void)refreshReceipts {
    [self fetchReceipts];
    [_receiptListTableView reloadData];
    [self stopAndUpdateDateOnRefreshControl];
    [_receiptListTableView setContentOffset:CGPointMake(0, _searchBar.frame.size.height) animated:YES];
}

#pragma mark - override

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    if (searchText && [searchText length] > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"info contains[cd] %@", searchText];
        _filteredItemList = [_originalItemList filteredArrayUsingPredicate:predicate];
    } else {
        _filteredItemList = _originalItemList;
    }
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
        [self fetchReceipts];
        [_receiptListTableView selectRowAtIndexPath:[self indexPathOfReceipt:newReceipt] animated:YES scrollPosition:UITableViewScrollPositionTop];
        _receiptViewController.receipt = newReceipt;
    }
}

- (IBAction)onArchive:(id)sender {
}

- (void)onDelete {
    _receiptListTableView.editing = !_receiptListTableView.editing;
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
