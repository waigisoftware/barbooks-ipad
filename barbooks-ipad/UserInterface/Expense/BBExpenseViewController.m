//
//  BBExpenseViewController.m
//  barbooks-ipad
//
//  Created by Can on 10/07/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBExpenseViewController.h"
#import "Contact.h"

@interface BBExpenseViewController ()

@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *dateTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *amountTextField;
@property (weak, nonatomic) IBOutlet CHDropDownTextField *payeeTextField;
@property (weak, nonatomic) IBOutlet UISwitch *taxedSwitch;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *taxTypeTextField;
@property (weak, nonatomic) IBOutlet UILabel *taxAmountLabel;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *gstTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *typeTextField;
@property (weak, nonatomic) IBOutlet CHDropDownTextField *categoryTextField;

// date picker
@property (weak, nonatomic) IBOutlet UIView *calendarContainerView;
@property (weak, nonatomic) IBOutlet UILabel *pickedDateWeekdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickedDateMonthLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickedDateDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickedDateYearLabel;
@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;
@property (weak, nonatomic) IBOutlet JTCalendarContentView *calendarContentView;
@property (strong, nonatomic) JTCalendar *calendar;

@property (strong, nonatomic) IGLDropDownMenu *gstTypeDrowdown;
@property (strong, nonatomic) IGLDropDownMenu *expenseTypeDrowdown;
@property (strong, nonatomic) NSArray *payeeList;

- (IBAction)onSelectDate:(id)sender;
- (IBAction)onTax:(id)sender;
- (IBAction)onCancelPickDate:(id)sender;
- (IBAction)onConfirmPickDate:(id)sender;
- (IBAction)onBackgroundButton:(id)sender;
- (IBAction)onEditingPayee:(id)sender;

@end

@implementation BBExpenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"Expense";

    [self setupPayeeDropDown];
    [self setupCalendarPickingView];
}

- (void)viewDidAppear:(BOOL)animated {
    [self setupExpenseTypeDropDown];
    [self setupTaxTypeDropDown];
    [self loadExpenseIntoUI];
    [self.view bringSubviewToFront:_payeeTextField];
    [self.view bringSubviewToFront:_calendarContainerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Setup

- (void)setupPayeeDropDown {
    NSArray *payeeNames = [Expense payeeList];
    _payeeTextField.dropDownTableVisibleRowCount = 4;
    _payeeTextField.dropDownTableTitlesArray = payeeNames;
    _payeeTextField.dropDownDelegate = self;
}

- (void)setupCalendarPickingView {
    // set calendar picker
    self.calendar = [JTCalendar new];
    self.calendar.calendarAppearance.dayCircleColorSelected = [UIColor bbPrimaryBlue];
    [self.calendar setMenuMonthsView:self.calendarMenuView];
    [self.calendar setContentView:self.calendarContentView];
    [self.calendar setDataSource:self];
}

- (void)setupTaxTypeDropDown {
    // setup selection item
    NSMutableArray *dropdownItems = [[NSMutableArray alloc] init];
    IGLDropDownItem *item = [[IGLDropDownItem alloc] init];
    [item setText:@"10%"];
    [dropdownItems addObject:item];
    item = [[IGLDropDownItem alloc] init];
    [item setText:@"Specify:"];
    [dropdownItems addObject:item];
    
    // setup dropdown selection
    _gstTypeDrowdown = [[IGLDropDownMenu alloc] init];
    [_gstTypeDrowdown setFrame:_taxTypeTextField.frame];
    _gstTypeDrowdown.menuText = @"Choose Tax Type";
    _gstTypeDrowdown.menuIconImage = [UIImage imageNamed:@"button-add.png"];
    _gstTypeDrowdown.paddingLeft = 15;
    _gstTypeDrowdown.dropDownItems = dropdownItems;
    _gstTypeDrowdown.delegate = self;
    _gstTypeDrowdown.type = IGLDropDownMenuTypeNormal;
    _gstTypeDrowdown.gutterY = 0;
    [_gstTypeDrowdown reloadView];
    [self.view addSubview:_gstTypeDrowdown];
//    [self.view bringSubviewToFront:_gstTypeDrowdown];
    
    if (_expense) {
        [_gstTypeDrowdown selectItemAtIndex:_expense.taxType];
    } else {
        [_gstTypeDrowdown selectItemAtIndex:0];
    }
    
}

- (void)setupExpenseTypeDropDown {
    // setup selection item
    NSMutableArray *dropdownItems = [[NSMutableArray alloc] init];
    IGLDropDownItem *item = [[IGLDropDownItem alloc] init];
    [item setText:@"expense"];
    [dropdownItems addObject:item];
    item = [[IGLDropDownItem alloc] init];
    [item setText:@"capital"];
    [dropdownItems addObject:item];
    
    // setup dropdown selection
    _expenseTypeDrowdown = [[IGLDropDownMenu alloc] init];
    [_expenseTypeDrowdown setFrame:_typeTextField.frame];
    _expenseTypeDrowdown.menuText = @"Choose Expense Type";
    _expenseTypeDrowdown.menuIconImage = [UIImage imageNamed:@"button-add.png"];
    _expenseTypeDrowdown.paddingLeft = 15;
    _expenseTypeDrowdown.dropDownItems = dropdownItems;
    _expenseTypeDrowdown.delegate = self;
    _expenseTypeDrowdown.type = IGLDropDownMenuTypeNormal;
    _expenseTypeDrowdown.gutterY = 0;
    [_expenseTypeDrowdown reloadView];
    [self.view addSubview:_expenseTypeDrowdown];
//    [self.view bringSubviewToFront:_expenseTypeDrowdown];
    
    if (_expense) {
        [_expenseTypeDrowdown selectItemAtIndex:[_expense.expenseType integerValue]];
    } else {
        [_expenseTypeDrowdown selectItemAtIndex:0];
    }
    
}

- (void)setupTextFields {
    // UIFloatLabelTextField setup
    [self.descriptionTextField applyBottomBorderStyle];
    [self.dateTextField applyBottomBorderStyle];
}

- (void)dropDownTextField:(CHDropDownTextField *)dropDownTextField didChooseDropDownOptionAtIndex:(NSUInteger)index {
    NSLog(@"%@, %ul", dropDownTextField.text, (unsigned int)index);
}

#pragma mark - Expense value

- (void)loadExpenseIntoUI {
    _descriptionTextField.text = _expense.info;
    _dateTextField.text = [_expense.date toShortDateFormat];
    _amountTextField.text = [_expense.amountIncGst currencyAmount];
    _payeeTextField.text = _expense.payee;
    _categoryTextField.text = _expense.category;
    _taxedSwitch.on = _expense.isTaxed;
    if (_expense.isTaxed) {
        _gstTypeDrowdown.hidden = NO;
        _gstTextField.hidden = NO;
        _taxAmountLabel.hidden = NO;
    } else {
        _gstTypeDrowdown.hidden = YES;
        _gstTextField.hidden = YES;
        _taxAmountLabel.hidden = YES;
    }
    _taxAmountLabel.text = [_expense.amountGst currencyAmount];
    _gstTextField.text = [_expense.tax currencyAmount];
    if (_expense.taxType == BBExpenseTaxTypePercentage) {
        _taxAmountLabel.hidden = NO;
        _gstTextField.hidden = !_taxAmountLabel.hidden;
    } else {
        _taxAmountLabel.hidden = YES;
        _gstTextField.hidden = !_taxAmountLabel.hidden;
    }
    if (_gstTypeDrowdown.selectedIndex != _expense.taxType) {
        [_gstTypeDrowdown selectItemAtIndex:_expense.taxType];
    }
    if (_expenseTypeDrowdown.selectedIndex != [_expense.expenseType integerValue]) {
        [_expenseTypeDrowdown selectItemAtIndex:[_expense.expenseType integerValue]];
    }
    _categoryTextField.text = _expense.category;
}

- (void)updateExpenseFromUI {
    _expense.info = _descriptionTextField.text;
    _expense.date = [_dateTextField.text fromShortDateFormatToDate];
    _expense.amountIncGst = [NSDecimalNumber decimalNumberWithStringAndValidation:_amountTextField.text];
    _expense.payee = _payeeTextField.text;
    _expense.taxed = [NSNumber numberWithBool:_taxedSwitch.on];
    _expense.tax = [NSDecimalNumber decimalNumberWithStringAndValidation:_gstTextField.text];
    _expense.category = _categoryTextField.text;
    if (_gstTypeDrowdown.selectedIndex == 0) {
        _expense.userSpecifiedGst = [NSNumber numberWithBool:NO];
    } else {
        _expense.userSpecifiedGst = [NSNumber numberWithBool:YES];
    }
    _expense.expenseType = [NSNumber numberWithInteger:_expenseTypeDrowdown.selectedIndex];
    [_expense recalculate];
    // refresh matter list accordingly
//    [self.expenseListViewController fetchExpenses];
}

#pragma mark - preset data

- (void)setExpense:(Expense *)expense {
    _expense = expense;
    [self loadExpenseIntoUI];
}

#pragma mark - keyboards

- (void)stopEditing {
    [[UIResponder currentFirstResponder] resignFirstResponder];
    [self onCancelPickDate:nil];
    if (_gstTypeDrowdown.isExpanding) {
        [_gstTypeDrowdown selectItemAtIndex:_expense.taxType];
    }
    if (_expenseTypeDrowdown.isExpanding) {
        [_expenseTypeDrowdown selectItemAtIndex:[_expense.expenseType integerValue]];
    }
    // update Expense object
    [self updateExpenseFromUI];
    // refresh UI
    [self loadExpenseIntoUI];
}

#pragma mark IBActions

- (IBAction)onSelectDate:(id)sender {
    [self stopEditing];
    _calendarContainerView.hidden = !_calendarContainerView.hidden;
    if (!_calendarContainerView.hidden && !_dateTextField.text) {
        [_calendar setCurrentDate:_expense.date];
    }
}

- (IBAction)onTax:(id)sender {
    _expense.taxed = [NSNumber numberWithBool:_taxedSwitch.on];
    [self loadExpenseIntoUI];
}

- (IBAction)onBackgroundButton:(id)sender {
    [self stopEditing];
}

- (IBAction)onEditingPayee:(id)sender {
}

- (IBAction)onCancelPickDate:(id)sender {
    _calendarContainerView.hidden = YES;
}

- (IBAction)onConfirmPickDate:(id)sender {
    _calendarContainerView.hidden = YES;
    _expense.date = _calendar.currentDateSelected;
    [self loadExpenseIntoUI];
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
    if (dropDownMenu == _gstTypeDrowdown) {
        _expense.userSpecifiedGst = (index == BBExpenseTaxTypeUserSpecified) ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];
    } else {
        _expense.expenseType = [NSNumber numberWithInteger:index];
    }
    [self stopEditing];
}

#pragma mark - Core data


@end