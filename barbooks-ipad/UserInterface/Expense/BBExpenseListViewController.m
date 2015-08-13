//
//  BBExpenseListViewController.m
//  barbooks-ipad
//
//  Created by Can on 11/07/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBExpenseListViewController.h"
#import "BBExpenseTableViewCell.h"

@interface BBExpenseListViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *expenseListTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *archiveBarButtonItem;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (strong, nonatomic) NSArray *originalItemList;
@property (strong, nonatomic) NSArray *filteredItemList;

- (IBAction)onAdd:(id)sender;
- (IBAction)onArchive:(id)sender;

@end

@implementation BBExpenseListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // tableview
    _expenseListTableView.dataSource = self;
    _expenseListTableView.delegate = self;
    [self registerRefreshControlFor:_expenseListTableView withAction:@selector(fetchExpenses)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // setup navigation bar and toolbar
    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self fetchExpenses];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // user pressed back button in Navigation Bar
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [self.expenseViewController.navigationController popViewControllerAnimated:YES];
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
    static NSString *reuseIdentifier = @"expenseCell";
    BBExpenseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    Expense *expense = [_filteredItemList objectAtIndex:indexPath.row];
    cell.descriptionLabel.text = expense.info;
    cell.payeeLabel.text = expense.payee;
    cell.dateLabel.text = [expense.date toShortDateFormat];
    cell.amountLabel.text = [expense.amountIncGst currencyAmount];
    cell.typeLabel.text = expense.classDisplayName;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Expense *expense = [_filteredItemList objectAtIndex:indexPath.row];
    _expenseViewController.expense = expense;
}

#pragma mark - TableView helper methods

- (NSIndexPath *)indexPathOfExpense:(Expense *)expense {
    return [NSIndexPath indexPathForRow:[_originalItemList indexOfObject:expense] inSection:0];
}

#pragma mark - Core data

- (void)fetchExpenses {
    // fetch from core data
    if ([self isMatterExpenses]) {
        _originalItemList = [self.matter.disbursements allObjects];
    } else {
        _originalItemList = [Expense MR_findAllSortedBy:@"date" ascending:NO];
    }
    [self filterContentForSearchText:_searchBar.text scope:nil];
    [_expenseListTableView reloadData];
    [self stopAndUpdateDateOnRefreshControl];
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
    Expense *newExpense = [Expense newInstanceWithDefaultValue];
    [self.expenseViewController setExpense:newExpense];
    [self fetchExpenses];
    [_expenseListTableView selectRowAtIndexPath:[self indexPathOfExpense:newExpense] animated:YES scrollPosition:UITableViewScrollPositionTop];
    _expenseViewController.expense = newExpense;
}

- (IBAction)onArchive:(id)sender {
}

- (void)onDelete {
    
}

#pragma mark - UI method

// if the expense list is showing all expenses or a Matter's expenses
- (BOOL)isMatterExpenses {
    return self.matter ? YES : NO;
}

- (void)setupUI {
    if ([self isMatterExpenses]) {
        // hide back button
        self.tabBarController.navigationItem.hidesBackButton = YES;
        self.tabBarController.navigationItem.title = @"Disbursements";
        // add 'Add' & 'Delete' button
        UIImage *imageAdd = [[UIImage imageNamed:@"button_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *imageDelete = [[UIImage imageNamed:@"button_delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:imageAdd style:UIBarButtonItemStylePlain target:self action:@selector(onAdd:)];
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithImage:imageDelete style:UIBarButtonItemStylePlain target:self action:@selector(onDelete)];
        self.tabBarController.navigationItem.rightBarButtonItems = @[deleteButton, addButton];
        // toolbar buttons
        self.toolbar.hidden = YES;
        [self.toolbar removeFromSuperview];
    } else {
        // show back button
        self.navigationItem.hidesBackButton = NO;
        self.navigationItem.title = nil;
        // toolbar buttons
        self.toolbar.hidden = NO;
        UIImage *imageAdd = [[UIImage imageNamed:@"button_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *imageArchive = [[UIImage imageNamed:@"button_archive"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _addBarButtonItem.image = imageAdd;
        _archiveBarButtonItem.image = imageArchive;
    }
}

@end
