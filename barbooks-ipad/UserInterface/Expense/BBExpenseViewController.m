//
//  BBExpenseViewController.m
//  barbooks-ipad
//
//  Created by Can on 10/07/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBExpenseViewController.h"
#import "BBExpenseListViewController.h"
#import "Contact.h"
#import "Disbursement.h"
#import "BBModalDatePickerViewController.h"

@interface BBExpenseViewController () <BBModalDatePickerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet CHDropDownTextField *payeeTextField;
@property (weak, nonatomic) IBOutlet UISwitch *taxedSwitch;
@property (weak, nonatomic) IBOutlet UILabel *taxAmountLabel;
@property (weak, nonatomic) IBOutlet UITextField *gstTextField;
@property (weak, nonatomic) IBOutlet CHDropDownTextField *categoryTextField;
@property (weak, nonatomic) IBOutlet UIView *gstTypeDropdownContainer;
@property (weak, nonatomic) IBOutlet UIView *expenseTypeDropdownContainer;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IGLDropDownMenu *gstTypeDrowdown;
@property (strong, nonatomic) IGLDropDownMenu *expenseTypeDrowdown;
@property (strong, nonatomic) NSArray *payees;
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) BBModalDatePickerViewController *datePickerController;

- (IBAction)onTax:(id)sender;
- (IBAction)onBackgroundButton:(id)sender;
- (IBAction)onEditingPayee:(id)sender;
- (IBAction)onClose:(id)sender;

@end

@implementation BBExpenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"Expense";

    // text field delegate
    _descriptionTextField.delegate = self;
    _dateTextField.delegate = self;
    _amountTextField.delegate = self;
    _payeeTextField.delegate = self;
    _gstTextField.delegate = self;
    _categoryTextField.delegate = self;
    
    [self setupPayeeDropDown];
    [self setupCategoryDropDown];
    [self showCloseButtonIfNeeded];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupExpenseTypeDropDown];
    [self setupTaxTypeDropDown];

    [self loadExpenseIntoUI];
    [self.view bringSubviewToFront:_payeeTextField];
    [self coverViewIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopEditing];
    [_delegate updateExpense:self.expense];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Setup

- (void)coverViewIfNeeded {
    [self.view bringSubviewToFront:_coverView];
    _coverView.hidden = self.expense ? YES : NO;
}

- (void)showCloseButtonIfNeeded {
    if (self.navigationController) {
        [self.navigationBar setHidden:YES];
    } else {
        [self.navigationBar setHidden:NO];
    }
    [self.view updateConstraintsIfNeeded];
}

- (void)setupPayeeDropDown {
    _payees = [Expense payeeList];
    _payeeTextField.dropDownTableVisibleRowCount = MIN(MAX_COUNT_IN_DROPDOWN, _payees.count);
    _payeeTextField.dropDownTableTitlesArray = _payees;
    _payeeTextField.dropDownDelegate = self;
}

- (void)setupCategoryDropDown {
    _categories = [Expense categoryList];
    _categoryTextField.dropDownTableVisibleRowCount = MIN(MAX_COUNT_IN_DROPDOWN, _categories.count);
    _categoryTextField.dropDownTableTitlesArray = _categories;
    _categoryTextField.dropDownDelegate = self;
}


- (void)setupTaxTypeDropDown {
    // setup selection item
    NSMutableArray *dropdownItems = [[NSMutableArray alloc] init];
    IGLDropDownItem *item = [[IGLDropDownItem alloc] init];
    [self setupDropDownItem:item];

    [item setText:@"10%"];
    [dropdownItems addObject:item];
    item = [[IGLDropDownItem alloc] init];
    [self setupDropDownItem:item];

    [item setText:@"Specify:"];
    [dropdownItems addObject:item];

    // setup dropdown selection
    _gstTypeDrowdown = [[IGLDropDownMenu alloc] init];
    [self setupDropDownItem:_gstTypeDrowdown.menuButton];
    [_gstTypeDrowdown setFrame:_gstTypeDropdownContainer.frame];
    for (NSLayoutConstraint *constraint in _gstTypeDropdownContainer.constraints) {
        
        id firstItem = constraint.firstItem == _gstTypeDropdownContainer ? _gstTypeDrowdown : constraint.firstItem;
        id secondItem = constraint.secondItem == _gstTypeDropdownContainer ? _gstTypeDrowdown : constraint.secondItem;
        
        [_gstTypeDrowdown addConstraint:[NSLayoutConstraint constraintWithItem:firstItem
                                                                         attribute:constraint.firstAttribute
                                                                         relatedBy:constraint.relation
                                                                            toItem:secondItem
                                                                         attribute:constraint.secondAttribute
                                                                        multiplier:constraint.multiplier
                                                                          constant:constraint.constant]];
    }
    _gstTypeDrowdown.menuText = @"Choose Tax Type";
    _gstTypeDrowdown.menuIconImage = [UIImage imageNamed:@"button-add"];
    _gstTypeDrowdown.paddingLeft = 8;
    _gstTypeDrowdown.dropDownItems = dropdownItems;
    _gstTypeDrowdown.delegate = self;
    _gstTypeDrowdown.type = IGLDropDownMenuTypeNormal;
    _gstTypeDrowdown.gutterY = 0;
    [_gstTypeDrowdown reloadView];
    [_gstTypeDropdownContainer.superview addSubview:_gstTypeDrowdown];
    [_gstTypeDrowdown.menuButton addTarget:self action:@selector(dropDownMenuItemSelected:) forControlEvents:UIControlEventTouchUpInside];

    if (_expense) {
        [_gstTypeDrowdown selectItemAtIndex:_expense.taxType];
    } else {
        [_gstTypeDrowdown selectItemAtIndex:0];
    }
}

- (void)setupDropDownItem:(IGLDropDownItem*)item
{
    UIView *bgView = [[item subviews] objectAtIndex:0];
    bgView.layer.shadowOpacity = 0;
    bgView.layer.shadowOffset = CGSizeMake(0, 0);
    bgView.layer.shadowRadius = 0;
    bgView.layer.cornerRadius = 5;
    bgView.layer.shouldRasterize = NO;
    bgView.layer.borderWidth = 0.25;
    bgView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
}

- (void)setupExpenseTypeDropDown {
    // setup selection item
    NSMutableArray *dropdownItems = [[NSMutableArray alloc] init];
    IGLDropDownItem *item = [[IGLDropDownItem alloc] init];
    [self setupDropDownItem:item];

    [item setText:@"expense"];
    [dropdownItems addObject:item];
    item = [[IGLDropDownItem alloc] init];
    [self setupDropDownItem:item];
    
    [item setText:@"capital"];
    [dropdownItems addObject:item];
    
    // setup dropdown selection
    _expenseTypeDrowdown = [[IGLDropDownMenu alloc] init];
    [self setupDropDownItem:_expenseTypeDrowdown.menuButton];
    [_expenseTypeDrowdown setFrame:_expenseTypeDropdownContainer.frame];
    for (NSLayoutConstraint *constraint in _expenseTypeDropdownContainer.constraints) {
        
        id firstItem = constraint.firstItem == _expenseTypeDropdownContainer ? _expenseTypeDrowdown : constraint.firstItem;
        id secondItem = constraint.secondItem == _expenseTypeDropdownContainer ? _expenseTypeDrowdown : constraint.secondItem;
        
        [_expenseTypeDrowdown addConstraint:[NSLayoutConstraint constraintWithItem:firstItem
                                                                         attribute:constraint.firstAttribute
                                                                         relatedBy:constraint.relation
                                                                            toItem:secondItem
                                                                         attribute:constraint.secondAttribute
                                                                        multiplier:constraint.multiplier
                                                                          constant:constraint.constant]];
    }
    _expenseTypeDrowdown.menuText = @"Choose Expense Type";
    _expenseTypeDrowdown.menuIconImage = [UIImage imageNamed:@"button-add"];
    _expenseTypeDrowdown.paddingLeft = 8;
    _expenseTypeDrowdown.dropDownItems = dropdownItems;
    _expenseTypeDrowdown.delegate = self;
    _expenseTypeDrowdown.type = IGLDropDownMenuTypeNormal;
    _expenseTypeDrowdown.gutterY = 0;
    [_expenseTypeDrowdown reloadView];

    [_expenseTypeDropdownContainer.superview addSubview:_expenseTypeDrowdown];
    [_expenseTypeDrowdown.menuButton addTarget:self action:@selector(dropDownMenuItemSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    if (_expense) {
        [_expenseTypeDrowdown selectItemAtIndex:[_expense.expenseType integerValue]];
    } else {
        [_expenseTypeDrowdown selectItemAtIndex:0];
    }
    
}

#pragma mark - Expense value

- (void)loadExpenseIntoUI {
    [self coverViewIfNeeded];
    if (!_expense) {
        return;
    }
    
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
        // tax related fields
//        _taxAmountLabel.text = [_expense.amountGst currencyAmount];
//        _gstTextField.text = [_expense.tax roundedAmount];
        if (_expense.userSpecifiedGst.boolValue) {
            _taxAmountLabel.hidden = YES;
            _gstTextField.hidden = !_taxAmountLabel.hidden;
            _gstTextField.text = [_expense.tax currencyAmount];
        } else {
            _taxAmountLabel.hidden = NO;
            _gstTextField.hidden = !_taxAmountLabel.hidden;
            _taxAmountLabel.text = [_expense.amountGst currencyAmount];
        }
        if (_gstTypeDrowdown.selectedIndex != _expense.taxType) {
            [_gstTypeDrowdown selectItemAtIndex:_expense.taxType];
        }
    } else {
        _gstTypeDrowdown.hidden = YES;
        _gstTextField.hidden = YES;
        _taxAmountLabel.hidden = YES;
    }
    if (_expenseTypeDrowdown.selectedIndex != [_expense.expenseType integerValue]) {
        [_expenseTypeDrowdown selectItemAtIndex:[_expense.expenseType integerValue]];
    }
    _categoryTextField.text = _expense.category;
    // refresh dropdown text field
    [self setupPayeeDropDown];
    [self setupCategoryDropDown];
}

- (void)updateExpenseFromUI {
    _expense.info = _descriptionTextField.text;
    _expense.date = [_dateTextField.text fromShortDateFormatToDate];
    [self recalculateTax];
    /*
    NSDecimalNumber *amountIncGst = [NSDecimalNumber decimalNumberFromCurrencyString:_amountTextField.text];
    _expense.taxed = [NSNumber numberWithBool:_taxedSwitch.on];
    if ([_expense.taxed boolValue]) {
        if (_gstTypeDrowdown.selectedIndex == 0) {
            _expense.userSpecifiedGst = [NSNumber numberWithBool:NO];
        } else {
            _expense.userSpecifiedGst = [NSNumber numberWithBool:YES];
        }
        if (_expense.userSpecifiedGst.boolValue) {
            _expense.tax = [NSDecimalNumber decimalNumberFromCurrencyString:_gstTextField.text];
            _expense.amountExGst = [amountIncGst decimalNumberByAccuratelySubtracting:_expense.tax];
            _expense.amountGst = [NSDecimalNumber zero];
        } else {
            _expense.amountExGst = [amountIncGst decimalNumberSubtractGST];
            _expense.amountGst = [amountIncGst decimalNumberGSTOfInclusiveAmount];
            _expense.tax = [NSDecimalNumber zero];
        }
    } else {
        _expense.amountExGst = amountIncGst;
        _expense.amountGst = [NSDecimalNumber zero];
        _expense.tax = [NSDecimalNumber zero];
    }
     */
    _expense.payee = _payeeTextField.text;
    _expense.category = _categoryTextField.text;
    _expense.expenseType = [NSNumber numberWithInteger:_expenseTypeDrowdown.selectedIndex];
    
//    [_expense recalculate];
    // refresh matter list accordingly
//    [self.expenseListViewController fetchExpenses];
}

- (void)recalculateTax {
    NSDecimalNumber *amountIncGst = [NSDecimalNumber decimalNumberFromCurrencyString:_amountTextField.text];
    _expense.taxed = [NSNumber numberWithBool:_taxedSwitch.on];
    if ([_expense.taxed boolValue]) {
        if (_expense.userSpecifiedGst.boolValue) {
            _expense.tax = [NSDecimalNumber decimalNumberFromCurrencyString:_gstTextField.text];
            _expense.amountExGst = [amountIncGst decimalNumberByAccuratelySubtracting:_expense.tax];
            _expense.amountGst = [NSDecimalNumber zero];
        } else {
            _expense.amountExGst = [amountIncGst decimalNumberSubtractGST];
            _expense.amountGst = [amountIncGst decimalNumberGSTOfInclusiveAmount];
            _expense.tax = [NSDecimalNumber zero];
        }
    } else {
        _expense.amountExGst = amountIncGst;
        _expense.amountGst = [NSDecimalNumber zero];
        _expense.tax = [NSDecimalNumber zero];
    }
}

#pragma mark - preset data

- (void)setExpense:(Expense *)expense {
    _expense = expense;
    [self loadExpenseIntoUI];
}

#pragma mark - keyboards

- (void)stopEditing {
    [[UIResponder currentFirstResponder] resignFirstResponder];
    if (_gstTypeDrowdown.isExpanding) {
        [_gstTypeDrowdown selectItemAtIndex:_expense.taxType];
    }
    if (_expenseTypeDrowdown.isExpanding) {
        [_expenseTypeDrowdown selectItemAtIndex:[_expense.expenseType integerValue]];
    }
    [_gstTypeDrowdown setEnabled:YES];
    [_expenseTypeDrowdown setEnabled:YES];
    [_categoryTextField setEnabled:YES];

    // update Expense object
    [self updateExpenseFromUI];
    // refresh UI
    [self loadExpenseIntoUI];
}

#pragma mark IBActions

- (IBAction)onTax:(id)sender {
    _expense.taxed = [NSNumber numberWithBool:_taxedSwitch.on];
    [self recalculateTax];
    [self loadExpenseIntoUI];
}

- (IBAction)onBackgroundButton:(id)sender {
    [self stopEditing];
}

- (IBAction)onEditingPayee:(id)sender {
}


#pragma mark - Date
- (IBAction)onSelectDate:(id)sender {
    if (!self.datePickerController) {
        self.datePickerController = [BBModalDatePickerViewController defaultPicker];
        [self.datePickerController.view setFrame:self.view.bounds];
        
        [self.datePickerController.datePicker setDate:_expense.date];
        self.datePickerController.delegate = self;
        
    }
    
    [self.scrollView addSubview:self.datePickerController.view];
    [[UIApplication sharedApplication] resignFirstResponder];
    [self.datePickerController run];
}

- (IBAction)onDatePicked:(UIDatePicker*)datePicker {
    _expense.date = datePicker.date;
    _dateTextField.text = [datePicker.date toShortDateFormat];
    [self updateExpenseFromUI];
    [self.delegate updateExpense:_expense];
}


#pragma mark - CHDropDownTextFieldDelegate
- (void)dropDownTextField:(CHDropDownTextField *)dropDownTextField didChooseDropDownOptionAtIndex:(NSUInteger)index {
    if (dropDownTextField == _payeeTextField) {
        _payeeTextField.text = [_payees objectAtIndex:index];
    } else {
        _categoryTextField.text = [_categories objectAtIndex:index];
    }
    [self stopEditing];
}

#pragma mark - IGLDropDownMenuDelegate

- (void)dropDownMenu:(IGLDropDownMenu *)dropDownMenu selectedItemAtIndex:(NSInteger)index {
    if (dropDownMenu == _gstTypeDrowdown) {
//        if (_gstTypeDrowdown.selectedIndex == BBExpenseTaxTypePercentage) {
//            _expense.userSpecifiedGst = [NSNumber numberWithBool:NO];
//        } else {
//            _expense.userSpecifiedGst = [NSNumber numberWithBool:YES];
//        }
        _expense.userSpecifiedGst = (index == BBExpenseTaxTypeUserSpecified) ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];
        [self recalculateTax];
    } else {
        _expense.expenseType = [NSNumber numberWithInteger:index];
    }
    
    [self stopEditing];
}

- (void)dropDownMenuItemSelected:(IGLDropDownItem*)item
{
    if (item == _expenseTypeDrowdown.menuButton && _expenseTypeDrowdown.isExpanding) {
        [_gstTypeDrowdown setEnabled:NO];
        [_categoryTextField setEnabled:NO];
    } else if (_gstTypeDrowdown.isExpanding) {
        [_expenseTypeDrowdown setEnabled:NO];
        [_categoryTextField setEnabled:NO];
    } else {
        [self stopEditing];
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self stopEditing];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [_expenseTypeDrowdown setExpanding:NO];
    [_gstTypeDrowdown setExpanding:NO];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self updateExpenseFromUI];
    return YES;
}

#pragma mark - Core data



#pragma mark - Actions

- (IBAction)onClose:(id)sender {
    [self.delegate updateExpense:self.expense];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
