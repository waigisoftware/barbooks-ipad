//
//  BBInvoiceListViewController.m
//  barbooks-ipad
//
//  Created by Can on 16/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBInvoiceListViewController.h"
#import "BBInvoiceViewController.h"
#import "BBInvoiceTableViewCell.h"
#import "Invoice.h"
#import "InterestInvoice.h"

@interface BBInvoiceListViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *invoicesTableView;

@property (strong, nonatomic) NSArray *originalItemList;
@property (strong, nonatomic) NSArray *filteredItemList;

@property (strong, nonatomic) Invoice *selectedInvoice;

@end

@implementation BBInvoiceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGRect rect = _invoicesTableView.frame;
    rect = self.view.frame;
    rect = self.view.superview.frame;

    [_invoicesTableView setContentOffset:CGPointMake(0, _searchBar.frame.size.height)];
    // setup navigation bar and toolbar
    [self setupNavigationBar];
    [self refreshInvoices];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _invoicesTableView.editing = NO;
}

- (void)setupNavigationBar {
    // title
    self.tabBarController.navigationItem.title = @"Invoices";
    
    // hide back button
    self.tabBarController.navigationItem.hidesBackButton = YES;
    
    // add 'Add' & 'Delete' button
    UIImage *imageAdd = [[UIImage imageNamed:@"button_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onEdit)];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:imageAdd style:UIBarButtonItemStylePlain target:self action:@selector(onAddInvoice)];
    self.tabBarController.navigationItem.rightBarButtonItems = @[addButton,editButton];
}

#pragma mark - Button actions

- (void)onAddInvoice {
    
    // first choose which invoice type
    // then choose the content
    
    
    Invoice *newInvoice = [InterestInvoice newInstanceOfMatter:self.matter];
    [self fetchInvoices];
    [_invoicesTableView insertRowsAtIndexPaths:@[[self indexPathOfInvoice:newInvoice]] withRowAnimation:UITableViewRowAnimationTop];
    [_invoicesTableView selectRowAtIndexPath:[self indexPathOfInvoice:newInvoice] animated:YES scrollPosition:UITableViewScrollPositionTop];
    [self showInvoiceDetail:newInvoice];
}


- (void)onEdit {
    if (_invoicesTableView.editing) {
        UIImage *imageAdd = [[UIImage imageNamed:@"button_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:imageAdd style:UIBarButtonItemStylePlain target:self action:@selector(onAddInvoice)];
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onEdit)];
        
        [self.tabBarController.navigationItem setRightBarButtonItems:@[addButton,editButton] animated:YES];
        
    } else {
        UIImage *imageDelete = [[UIImage imageNamed:@"button_delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIBarButtonItem *removeButton = [[UIBarButtonItem alloc] initWithImage:imageDelete style:UIBarButtonItemStylePlain target:self action:@selector(onDeleteInvoice)];
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onEdit)];
        
        [self.tabBarController.navigationItem setRightBarButtonItems:@[removeButton,editButton] animated:YES];
    }
    
    [_invoicesTableView setEditing:!_invoicesTableView.editing animated:YES];
}


- (void)onDeleteInvoice {
    NSArray *selections = [_invoicesTableView indexPathsForSelectedRows];
    NSArray *tasks = self.matter.tasksArray;
    
    for (NSIndexPath *selection in selections) {
        [self.matter removeTasksObject:[tasks objectAtIndex:selection.row]];
    }
    
    [self.matter.managedObjectContext MR_saveToPersistentStoreAndWait];
    [self fetchInvoices];
    [_invoicesTableView beginUpdates];
    [_invoicesTableView deleteRowsAtIndexPaths:selections withRowAnimation:UITableViewRowAnimationTop];
    [_invoicesTableView endUpdates];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _filteredItemList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"invoiceCell";
    BBInvoiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    Invoice *invoice = [_filteredItemList objectAtIndex:indexPath.row];
    cell.invoiceNumberLabel.text = [invoice.entryNumber stringValue];
    cell.totalAmountLabel.text = [invoice.totalAmountExGst currencyAmount];
    cell.outstandingAmountLabel.text = [invoice.totalOutstanding currencyAmount];
    cell.dueDateLabel.text = [invoice.dueDate toShortDateFormat];
    cell.matterDescriptionLabel.text = invoice.matter.name;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!tableView.editing) {
        Invoice *invoice = [_filteredItemList objectAtIndex:indexPath.row];
        [self showInvoiceDetail:invoice];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130;
}

// handle delete

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Invoice *invoiceToDelete = [_originalItemList objectAtIndex:indexPath.row];
        [self.matter removeInvoicesObject:invoiceToDelete];
        [self fetchInvoices];
    }
}

#pragma mark - TableView helper methods

- (NSIndexPath *)indexPathOfInvoice:(Invoice *)invoice {
    return [NSIndexPath indexPathForRow:[_originalItemList indexOfObject:invoice] inSection:0];
}

#pragma mark - Core data

- (void)fetchInvoices {
    [[NSManagedObjectContext MR_rootSavingContext] processPendingChanges];
    
    _originalItemList = self.matter.invoicesArray;
    [self filterContentForSearchText:_searchBar.text scope:nil];
}

- (void)refreshInvoices {
    [self fetchInvoices];
    [_invoicesTableView reloadData];
    [self stopAndUpdateDateOnRefreshControl];
    [_invoicesTableView setContentOffset:CGPointMake(0, _searchBar.frame.size.height) animated:YES];
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

#pragma mark - BBInvoiceDelegate

- (void)updateInvoice:(id)data {
    [self fetchInvoices];
    
    // refresh matter list accordingly
//    [self.matterListViewController fetchMatters];
}

#pragma mark - Navigation

- (void)showInvoiceDetail:(Invoice *)invoice {
    self.selectedInvoice = invoice;
    [self performSegueWithIdentifier:BBSegueShowInvoiceDetail sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:BBSegueShowInvoiceDetail]) {
        BBInvoiceViewController *invoiceViewController = (BBInvoiceViewController *)[segue destinationViewController];
        invoiceViewController.invoice = self.selectedInvoice;
        invoiceViewController.delegate = self;
    }
}

@end
