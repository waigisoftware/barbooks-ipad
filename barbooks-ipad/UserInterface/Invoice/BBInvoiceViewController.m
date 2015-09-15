//
//  BBInvoiceViewController.m
//  barbooks-ipad
//
//  Created by Can on 16/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBInvoiceViewController.h"
#import "BBInvoiceTaskListViewController.h"
#import "BBInvoiceDisbursementListViewController.h"
#import "RegularInvoice.h"
#import "InterestInvoice.h"
#import "BBDiscountViewController.h"

@interface BBInvoiceViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIView *detailsView;
@property (weak, nonatomic) IBOutlet UIView *tasksView;
@property (weak, nonatomic) IBOutlet UIView *disbursmentsView;
@property (weak, nonatomic) IBOutlet UITextField *invoiceNumberTextField;
@property (weak, nonatomic) IBOutlet UILabel *issueDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (weak, nonatomic) IBOutlet UIView *interestContainerView;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *interestAmountTextField;
@property (weak, nonatomic) IBOutlet UILabel *feesExcludeGSTLabel;
@property (weak, nonatomic) IBOutlet UILabel *feesGSTLabel;
@property (weak, nonatomic) IBOutlet UILabel *feesIncludeGSTLabel;
@property (weak, nonatomic) IBOutlet UILabel *tasksDiscountExcludeGSTLabel;
@property (weak, nonatomic) IBOutlet UILabel *tasksDiscountGSTLabel;
@property (weak, nonatomic) IBOutlet UILabel *tasksDiscountIncludeGSTLabel;
@property (weak, nonatomic) IBOutlet UILabel *invoiceDiscountExcludeGSTLabel;
@property (weak, nonatomic) IBOutlet UILabel *invoiceDiscountGSTLabel;
@property (weak, nonatomic) IBOutlet UILabel *invoiceDiscountIncludeGSTLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalExcludeGSTLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalGSTLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalIncludeGSTLabel;
@property (weak, nonatomic) IBOutlet UILabel *paidAmountExcludeGSTLabel;
@property (weak, nonatomic) IBOutlet UILabel *paidAmountGSTLabel;
@property (weak, nonatomic) IBOutlet UILabel *paidAmountIncludeGSTLabel;
@property (weak, nonatomic) IBOutlet UILabel *writtenOffExcludeGSTLabel;
@property (weak, nonatomic) IBOutlet UILabel *writtenOffGSTLabel;
@property (weak, nonatomic) IBOutlet UILabel *writtenOffIncludeGSTLabel;
@property (weak, nonatomic) IBOutlet UILabel *outstandingExcludeGSTLabel;
@property (weak, nonatomic) IBOutlet UILabel *outstandingGSTLabel;
@property (weak, nonatomic) IBOutlet UILabel *outstandingIncludeGSTLabel;
@property (weak, nonatomic) IBOutlet UIButton *discountButton;

@property (weak, nonatomic) IBOutlet UITableView *taskTableView;
@property (weak, nonatomic) IBOutlet UITableView *disbursementTableView;

@property (strong, nonatomic) BBInvoiceTaskListViewController *taskListViewController;
@property (strong, nonatomic) BBInvoiceDisbursementListViewController *disbursementListViewController;

- (IBAction)onSegmentChange:(id)sender;
- (IBAction)onClose:(id)sender;
- (IBAction)onDiscount:(id)sender;

@end

@implementation BBInvoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // details view
    self.preferredContentSize = CGSizeMake(200, 200);
    [self loadInvoiceIntoUI];
    
    // tasks view
    _taskListViewController = [BBInvoiceTaskListViewController new];
    _taskTableView.dataSource = _taskListViewController;
    _taskTableView.delegate = _taskListViewController;
    if ([self.invoice isKindOfClass:[RegularInvoice class]]) {
        _taskListViewController.itemList = ((RegularInvoice *)self.invoice).tasks.allObjects;
    } else {
        _taskListViewController.itemList = [NSArray new];
    }
    
    // disbursements view
    _disbursementListViewController = [BBInvoiceDisbursementListViewController new];
    _disbursementTableView.dataSource = _disbursementListViewController;
    _disbursementTableView.delegate = _disbursementListViewController;
    if ([self.invoice isKindOfClass:[RegularInvoice class]]) {
        _disbursementListViewController.itemList = ((RegularInvoice *)self.invoice).disbursements.allObjects;
    } else {
        _disbursementListViewController.itemList = [NSArray new];
    }
    
    [self showSelectedView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopEditing];
    [_delegate updateInvoice:_invoice];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI update

- (void)showSelectedView {
    _detailsView.hidden = (_segmentedControl.selectedSegmentIndex == 0) ? NO : YES;
    _tasksView.hidden = (_segmentedControl.selectedSegmentIndex == 1) ? NO : YES;
    _disbursmentsView.hidden = (_segmentedControl.selectedSegmentIndex == 2) ? NO : YES;
}

- (void)loadInvoiceIntoUI {
    // preselect detail segment
    _segmentedControl.selectedSegmentIndex = 0;
    _invoiceNumberTextField.text = [_invoice.entryNumber stringValue];
    _issueDateLabel.text = [_invoice.createdAt toShortDateFormat];
    _dueDateLabel.text = [_invoice.dueDate toShortDateFormat];
    if ([self.invoice isKindOfClass:[InterestInvoice class]]) {
        _interestContainerView.hidden = NO;
        _interestAmountTextField.text = [self.invoice.totalOutstandingExGst currencyAmount];
    } else {
        _interestContainerView.hidden = YES;
    }
    _feesExcludeGSTLabel.text = [self.invoice.amountExGst currencyAmount];
    _feesGSTLabel.text = [self.invoice.amountGst currencyAmount];
    _feesIncludeGSTLabel.text = [self.invoice.amount currencyAmount];
    //TODO: tasks discount
    _invoiceDiscountExcludeGSTLabel.text = [self.invoice.discountExGstRate currencyAmount];
    _invoiceDiscountGSTLabel.text = [self.invoice.discountGstRate currencyAmount];
    _invoiceDiscountIncludeGSTLabel.text = [self.invoice.discountRate currencyAmount];
    _totalExcludeGSTLabel.text = [self.invoice.totalAmountExGst currencyAmount];
    _totalGSTLabel.text = [self.invoice.totalAmountGst currencyAmount];
    _totalIncludeGSTLabel.text = [self.invoice.totalAmount currencyAmount];
    _paidAmountExcludeGSTLabel.text = [self.invoice.totalReceivedExGst currencyAmount];
    _paidAmountGSTLabel.text = [self.invoice.totalReceivedGst currencyAmount];
    _paidAmountIncludeGSTLabel.text = [self.invoice.totalReceivedIncGst currencyAmount];
    _writtenOffExcludeGSTLabel.text = [self.invoice.totalWrittenOffExGst currencyAmount];
    _writtenOffGSTLabel.text = [self.invoice.totalWrittenOffGst currencyAmount];
    _writtenOffIncludeGSTLabel.text = [self.invoice.totalWrittenOff currencyAmount];
    _outstandingExcludeGSTLabel.text = [self.invoice.totalOutstandingExGst currencyAmount];
    _outstandingGSTLabel.text = [self.invoice.totalOutstandingGst currencyAmount];
    _outstandingIncludeGSTLabel.text = [self.invoice.totalOutstanding currencyAmount];
}

- (void)updateInvoiceFromUI {
    _invoice.classDisplayName = _invoiceNumberTextField.text;
    if ([self.invoice isKindOfClass:[InterestInvoice class]]) {
        self.invoice.totalOutstandingExGst = [NSDecimalNumber decimalNumberFromCurrencyString:_interestAmountTextField.text];
    }
}

#pragma mark - Actions

- (IBAction)onClose:(id)sender {
    [self.delegate updateInvoice:self.invoice];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onDiscount:(id)sender {
    [self popoverDiscountView];
}

- (IBAction)onSegmentChange:(id)sender {
    [self showSelectedView];
}

#pragma mark - keyboards

- (void)stopEditing {
    [[UIResponder currentFirstResponder] resignFirstResponder];
    // update Invoice object
    [self updateInvoiceFromUI];
    // refresh UI
    [self loadInvoiceIntoUI];
}

#pragma mark - popover

- (void)popoverDiscountView {
    BBDiscountViewController *discountViewController = [self.storyboard instantiateViewControllerWithIdentifier:StoryboardIdBBDiscountViewController];
    discountViewController.delegate = self;
    discountViewController.invoice = self.invoice;
    
    // pop it over
    UIPopoverController * popoverController = [[UIPopoverController alloc] initWithContentViewController:discountViewController];
    popoverController.delegate = self;
    popoverController.popoverContentSize = CGSizeMake(320, 150);
    [popoverController presentPopoverFromRect:self.discountButton.frame
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionLeft
                                     animated:YES];
}

#pragma mark - BBDiscountDelegate

- (void)updateDiscount:(id)data {
    [self loadInvoiceIntoUI];
}

@end
