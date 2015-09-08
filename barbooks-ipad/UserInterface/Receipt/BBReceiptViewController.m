//
//  BBReceiptViewController.m
//  barbooks-ipad
//
//  Created by Can on 24/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBReceiptViewController.h"
#import "BBReceiptListViewController.h"
#import "Invoice.h"
#import "NSDecimalNumber+BBUtil.h"

@interface BBReceiptViewController ()

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *dateTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *amountTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *typeTextField;
@property (weak, nonatomic) IBOutlet UITableView *invoiceTableView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;

// date picker
@property (weak, nonatomic) IBOutlet UIView *calendarContainerView;
@property (weak, nonatomic) IBOutlet UILabel *pickedDateWeekdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickedDateMonthLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickedDateDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickedDateYearLabel;
@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;
@property (weak, nonatomic) IBOutlet JTCalendarContentView *calendarContentView;
@property (strong, nonatomic) JTCalendar *calendar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonsViewHeightConstraint;

@property (strong, nonatomic) IGLDropDownMenu *receiptTypeDrowdown;
@property (strong, nonatomic) NSArray *originalItemList;
@property (strong, nonatomic) NSArray *filteredItemList;
@property (strong, nonatomic) NSMutableArray *selectedInvoiceList;

- (IBAction)onSelectDate:(id)sender;
- (IBAction)onCancelPickDate:(id)sender;
- (IBAction)onConfirmPickDate:(id)sender;
- (IBAction)onBackgroundButton:(id)sender;
- (IBAction)onClose:(id)sender;
- (IBAction)onSave:(id)sender;

@end

@implementation BBReceiptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"Receipt";
    
    _amountTextField.enabled = NO;
    
    // text field delegate
    _dateTextField.delegate = self;
    _amountTextField.delegate = self;
    _typeTextField.delegate = self;
    
    // table view
    _invoiceTableView.delegate = self;
    _invoiceTableView.dataSource = self;
    
    [self setupCalendarPickingView];
    [self showCloseButtonIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupReceiptTypeDropDown];
    [self loadReceiptIntoUI];
    [self.view bringSubviewToFront:_calendarContainerView];
    [self coverViewIfNeeded];
    [self loadInvoices];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Setup

- (void)coverViewIfNeeded {
    [self.view bringSubviewToFront:_coverView];
    _coverView.hidden = self.receipt ? YES : NO;
}

- (void)showCloseButtonIfNeeded {
    if (self.navigationController) {
        _buttonsView.hidden = YES;
        _buttonsViewHeightConstraint.constant = 0; // displaying in the detail view
    } else {
        _buttonsView.hidden = NO;
        _buttonsViewHeightConstraint.constant = 44;// displaying in the modal view
    }
    [self.view updateConstraintsIfNeeded];
}

- (void)setupCalendarPickingView {
    // set calendar picker
    self.calendar = [JTCalendar new];
    self.calendar.calendarAppearance.dayCircleColorSelected = [UIColor bbPrimaryBlue];
    [self.calendar setMenuMonthsView:self.calendarMenuView];
    [self.calendar setContentView:self.calendarContentView];
    [self.calendar setDataSource:self];
}

- (void)setupReceiptTypeDropDown {
    // setup selection item
    NSMutableArray *dropdownItems = [[NSMutableArray alloc] init];
    IGLDropDownItem *item = [[IGLDropDownItem alloc] init];
    [item setText:@"Full Payment"];
    [dropdownItems addObject:item];
    item = [[IGLDropDownItem alloc] init];
    [item setText:@"Part Payment"];
    [dropdownItems addObject:item];
    
    // setup dropdown selection
    _receiptTypeDrowdown = [[IGLDropDownMenu alloc] init];
    [_receiptTypeDrowdown setFrame:_typeTextField.frame];
    _receiptTypeDrowdown.menuText = @"Choose Receipt Type";
    _receiptTypeDrowdown.menuIconImage = [UIImage imageNamed:@"button-add"];
    _receiptTypeDrowdown.paddingLeft = 15;
    _receiptTypeDrowdown.dropDownItems = dropdownItems;
    _receiptTypeDrowdown.delegate = self;
    _receiptTypeDrowdown.type = IGLDropDownMenuTypeNormal;
    _receiptTypeDrowdown.gutterY = 0;
    [_receiptTypeDrowdown reloadView];
    [self.view addSubview:_receiptTypeDrowdown];
    
    if (_receipt) {
        [_receiptTypeDrowdown selectItemAtIndex:[_receipt.paymentType integerValue]];
    } else {
        [_receiptTypeDrowdown selectItemAtIndex:0];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _filteredItemList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"receiptInvoiceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    Invoice *invoice = [_filteredItemList objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@", invoice.entryNumber.stringValue, [invoice.totalOutstanding currencyAmount]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    Invoice *invoice = [_filteredItemList objectAtIndex:indexPath.row];
//    if (!_selectedInvoiceList) {
//        _selectedInvoiceList = [NSMutableArray array];
//    }
//    [_selectedInvoiceList addObject:invoice];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (void)loadInvoices {
    NSArray *invoices = [[self.matter.invoices filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"totalOutstanding > 0"]] allObjects];
    _filteredItemList = invoices;
}

#pragma mark - Receipt value

- (void)loadReceiptIntoUI {
    [self coverViewIfNeeded];
    if (!_receipt) {
        return;
    }
    
    _dateTextField.text = [_receipt.date toShortDateFormat];
    _amountTextField.text = [_receipt.totalAmount roundedAmount];
    if (_receiptTypeDrowdown.selectedIndex != [_receipt.paymentType integerValue]) {
        [_receiptTypeDrowdown selectItemAtIndex:[_receipt.paymentType integerValue]];
    }
}

- (void)updateReceiptFromUI {
    _receipt.date = [_dateTextField.text fromShortDateFormatToDate];
    _receipt.totalAmount = [NSDecimalNumber decimalNumberWithStringAndValidation:_amountTextField.text];
    _receipt.paymentType = [NSNumber numberWithInteger:_receiptTypeDrowdown.selectedIndex];
}

#pragma mark - preset data

- (void)setReceipt:(Receipt *)receipt {
    _receipt = receipt;
    [self loadReceiptIntoUI];
}

#pragma mark - keyboards

- (void)stopEditing {
    [[UIResponder currentFirstResponder] resignFirstResponder];
    [self onCancelPickDate:nil];
    if (_receiptTypeDrowdown.isExpanding) {
        [_receiptTypeDrowdown selectItemAtIndex:[_receipt.paymentType integerValue]];
    }
    // update Receipt object
    [self updateReceiptFromUI];
    // refresh UI
    [self loadReceiptIntoUI];
}

#pragma mark IBActions

- (IBAction)onSelectDate:(id)sender {
    [self stopEditing];
    _calendarContainerView.hidden = !_calendarContainerView.hidden;
    if (!_calendarContainerView.hidden && !_dateTextField.text) {
        [_calendar setCurrentDate:_receipt.date];
    }
}

- (IBAction)onBackgroundButton:(id)sender {
    [self stopEditing];
}

- (IBAction)onCancelPickDate:(id)sender {
    _calendarContainerView.hidden = YES;
}

- (IBAction)onConfirmPickDate:(id)sender {
    _calendarContainerView.hidden = YES;
    _dateTextField.text = [_calendar.currentDateSelected toShortDateFormat];
    [self stopEditing];
}

- (IBAction)onClose:(id)sender {
    [self.delegate updateReceipt:self.receipt];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onSave:(id)sender {
    NSArray *selectedInvoices = [_invoiceTableView indexPathsForSelectedRows];
    NSDecimalNumber *amountToAllocate = [NSDecimalNumber zero];
    if (_receipt.paymentType == 0) {
        for (Invoice *invoice in selectedInvoices) {
            [amountToAllocate decimalNumberByAccuratelyAdding:invoice.totalOutstanding];
        }
    } else {
        amountToAllocate = [NSDecimalNumber decimalNumberWithString:_amountTextField.text];
    }
    [self.receipt allocateInvoices:selectedInvoices amount:amountToAllocate];
    [self.delegate updateReceipt:self.receipt];
    [self onClose:sender];
}

#pragma mark - Date

// OpenDate JTCalendarDataSource
- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date {
    return NO;
}
- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date {
    [self updateCalendarContainerViewWithDate:date];
}

// Date methods
- (void)updateCalendarContainerViewWithDate:(NSDate *)date {
    _pickedDateWeekdayLabel.text = [date weekday];
    _pickedDateMonthLabel.text = [date month];
    _pickedDateDayLabel.text = [date day];
    _pickedDateYearLabel.text = [date year];
}

#pragma mark - IGLDropDownMenuDelegate

- (void)dropDownMenu:(IGLDropDownMenu *)dropDownMenu selectedItemAtIndex:(NSInteger)index {
    if (dropDownMenu == _receiptTypeDrowdown) {
        _receipt.paymentType = [NSNumber numberWithInteger:index];
        _amountTextField.enabled = [_receipt.paymentType isEqualToNumber:[NSNumber numberWithInt:0]] ? NO : YES;
    }
    [self stopEditing];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self stopEditing];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self updateReceiptFromUI];
    return YES;
}


@end
