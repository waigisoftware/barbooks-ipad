//
//  BBTaskViewController.m
//  barbooks-ipad
//
//  Created by Can on 23/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBTaskViewController.h"
#import "BBRateListViewController.h"
#import "NSString+BBUtil.h"
#import "BBModalDatePickerViewController.h"
#import "Discount.h"

@interface BBTaskViewController () <BBModalDatePickerViewControllerDelegate, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *taskDateLabel;
@property (weak, nonatomic) IBOutlet UISwitch *taxedSwitch;
@property (weak, nonatomic) IBOutlet UILabel *rateNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *rateAmountTextField;
@property (weak, nonatomic) IBOutlet UITextField *rateAmountInclTextField;
@property (weak, nonatomic) IBOutlet UITextField *rateUnitTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *hoursPickerView;
@property (strong, nonatomic) IBOutlet UISwitch *discountActiveSwitch;
@property (weak, nonatomic) IBOutlet UILabel *discountTypeLabel;
@property (weak, nonatomic) IBOutlet UITextField *discountValueTextField;
@property (strong, nonatomic) BBModalDatePickerViewController *datePickerController;
@property (strong, nonatomic) NSObject *observer;

- (IBAction)onCalendar:(id)sender;
- (IBAction)onDatePicked:(id)sender;
- (IBAction)onTax:(id)sender;

@end

@implementation BBTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[BBTaskTimer sharedInstance] currentTask] == _task) {
        [[BBTaskTimer sharedInstance] pause];
    }
    
    // setting delegates
    _rateAmountTextField.delegate = self;
    _rateUnitTextField.delegate = self;
    
    
    self.tableView.tableFooterView.hidden = self.task.rate.rateType.integerValue != BBRateChargingTypeHourly;

    [self loadTaskIntoUI];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self addTaskTimerObserver];
    [self updateContentSize];

}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopEditing];
    //[_delegate updateTask:_task];
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateContentSize
{
    [self setPreferredContentSize:self.tableView.contentSize];
}

#pragma mark - Task value

- (void)loadTaskIntoUI {
    _taskDateLabel.text = [_task.date toShortDateFormat];
    _taxedSwitch.on = _task.isTaxed;
    _rateNameLabel.text = _task.rate.name;
    _rateAmountTextField.text = [_task.rate.amount currencyAmount];
    _rateAmountInclTextField.text = [_task.rate.amountGst currencyAmount];
    
    if ([_task hourlyRate]) {
        [self.hoursPickerView selectRow:_task.hours.integerValue inComponent:0 animated:NO];
        [self.hoursPickerView selectRow:_task.minutes.integerValue inComponent:1 animated:NO];
    } else {
        _rateUnitTextField.text = [_task.units stringValue];
    }
    
    BOOL discountExists = _task.discount != nil;
    _discountActiveSwitch.on = discountExists;
    if (discountExists) {
        NSNumberFormatter *discountFormatter = [NSNumberFormatter new];
        [discountFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        if (_task.discount.discountType.integerValue == 1) {
            [discountFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        }
        
        _discountTypeLabel.text = [_task.discount discountTypeDescription];

        if (_task.discount.discountType.integerValue == 1) {
            _discountValueTextField.text = [_task.discount.value percentAmount];
        } else {
            _discountValueTextField.text = [_task.discount.value currencyAmount];
        }
    }
}

- (void)updateTaskFromUI {
    _task.taxed = [NSNumber numberWithBool:_taxedSwitch.on];
    NSDecimalNumber *amountInclGst = [NSDecimalNumber decimalNumberFromCurrencyString:_rateAmountInclTextField.text];
    if ([amountInclGst compare:_task.rate.amountGst] != NSOrderedSame) {
        _task.rate.amountGst = [NSDecimalNumber decimalNumberFromCurrencyString:_rateAmountInclTextField.text];
    } else {
        _task.rate.amount = [NSDecimalNumber decimalNumberFromCurrencyString:_rateAmountTextField.text];
    }
    //[self resetRateAmountWithTax];
    if ([_task hourlyRate]) {
        // get time from timer
        NSInteger hours = [self.hoursPickerView selectedRowInComponent:0];
        NSInteger minutes = [self.hoursPickerView selectedRowInComponent:1];
        [_task setHours:[NSDecimalNumber decimalNumberWithInt:(int)hours]];
        [_task setMinutes:[NSDecimalNumber decimalNumberWithInt:(int)minutes]];
    } else {
        if ([_rateUnitTextField.text isNumeric]) {
            _task.units = [NSDecimalNumber decimalNumberWithString:_rateUnitTextField.text];
        }
    }
    
    if (_task.discount) {
        _task.discount.value = [NSDecimalNumber decimalNumberFromCurrencyString:_discountValueTextField.text];
    }
    _rateAmountInclTextField.text = [_task.rate.amountGst currencyAmount];
    _rateAmountTextField.text = [_task.rate.amount currencyAmount];
    if (_task.discount.discountType.integerValue == 1) {
        _discountValueTextField.text = [_task.discount.value percentAmount];
    } else {
        _discountValueTextField.text = [_task.discount.value currencyAmount];
    }
    
    [_task.managedObjectContext MR_saveToPersistentStoreAndWait];
    
    // recalculate
    [self.delegate updateTask:_task];
}

#pragma mark - BBModalDatePicker Delegate

- (void)datePickerControllerDone:(UIDatePicker *)datePicker
{
    [self onDatePicked:datePicker];
}

#pragma mark - UIPickerView Delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self updateTaskFromUI];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0)
        return 24;
    
    return 60;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *columnView = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, _hoursPickerView.frame.size.width/2 - 35, 30)];
    columnView.text = [NSString stringWithFormat:@"%lu", (long) row];
    columnView.textAlignment = NSTextAlignmentLeft;
    
    return columnView;
}

#pragma mark - BBDropDownListDelegate

- (void)updateWithSelection:(id)data {
    Class dataClass = [data class];
    if (dataClass == [Rate class]) {
        // Rate picker
        Rate *selectedRate = data;
        [selectedRate copyValueToRate:_task.rate];
    }
    [self loadTaskIntoUI];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self updateTaskFromUI];
}

- (void)textViewDidChange:(UITextView *)textView {
    CGSize size = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, CGFLOAT_MAX)];
    CGRect frame = textView.frame;
    frame.size.height = size.height;
    [textView setFrame:frame];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    [self updateTaskFromUI];
//    return YES;
//}

#pragma mark - keyboards

- (void)stopEditing {
    [[UIResponder currentFirstResponder] resignFirstResponder];
    // update Task object
//    [self updateTaskFromUI];
    // refresh UI
//    [self loadTaskIntoUI];
}

#pragma mark IBActions

// Date picker
- (IBAction)onCalendar:(id)sender {
    if (!self.datePickerController) {
        self.datePickerController = [BBModalDatePickerViewController defaultPicker];
        [self.datePickerController.view setFrame:self.view.bounds];
        
        [self.datePickerController.datePicker setDate:_task.date];
        self.datePickerController.delegate = self;
    }
    
    [self.view addSubview:self.datePickerController.view];
    [[UIApplication sharedApplication] resignFirstResponder];
    [self.datePickerController run];
}

- (IBAction)onDatePicked:(UIDatePicker*)datePicker {
    _task.date = datePicker.date;
    _taskDateLabel.text = [datePicker.date toShortDateFormat];
    [self updateTaskFromUI];
    [self.delegate updateTask:self.task];
}

- (IBAction)onTax:(id)sender {
    _task.taxed = [NSNumber numberWithBool:_taxedSwitch.on];
    
    //[_rateAmountInclTextField.superview setHidden:!_taxedSwitch.on];
    [_task recalculate];
    [self.delegate updateTask:self.task];
}

- (IBAction)onDiscountSwitched:(id)sender {
    if (_discountActiveSwitch.on) {
        _task.discount = [Discount MR_createEntity];
        _task.discount.value = [NSDecimalNumber zero];
        _task.discount.discountType = @0;
        _discountTypeLabel.text = [_task.discount discountTypeDescription];
        
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1],[NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self loadTaskIntoUI];
        
    } else {
        [_task.discount MR_deleteEntity];
        _task.discount = nil;
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1],[NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
//    [[NSManagedObjectContext MR_rootSavingContext] MR_saveToPersistentStoreAndWait];
}


- (void)startPulsingButton:(UIButton *)button {
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.duration = 2;
    scaleAnimation.repeatCount = HUGE_VAL;
    scaleAnimation.autoreverses = YES;
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1];
    scaleAnimation.toValue = [NSNumber numberWithFloat:2];
    
    [button.imageView.layer addAnimation:scaleAnimation forKey:@"scale"];
}

- (void)stopPulsingButton:(UIButton *)button {
    [button.imageView.layer removeAnimationForKey:@"scale"];
}

- (void)pulsingButtonOnce:(UIButton *)button {
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.duration = 1;
    scaleAnimation.repeatCount = 0;
    scaleAnimation.autoreverses = YES;
    scaleAnimation.fromValue = [NSNumber numberWithFloat:2];
    scaleAnimation.toValue = [NSNumber numberWithFloat:1];
    
    [button.imageView.layer addAnimation:scaleAnimation forKey:@"scale"];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.tableView) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                [self onCalendar:self];
                
            } else if (indexPath.row == 1){
                [self showRateSelectorTable];
            }
        } else {
            if (indexPath.row == 1) {
                [self showDiscountTypeSelectorTable];
            }
        }
        

    } else {
        if (tableView.tag == 0) {
            Rate *selectedRate = [self.task.matter.ratesArray objectAtIndex:indexPath.row];
            _task.rate.name = [selectedRate.name copy];
            _task.rate.rateType = [selectedRate.rateType copy];
            _task.rate.amount = [selectedRate.amount copy];
            
            [self loadTaskIntoUI];
            [self.delegate updateTask:_task];
            
            self.tableView.tableFooterView.hidden = selectedRate.rateType.integerValue != BBRateChargingTypeHourly;
        } else {
            _task.discount.discountType = @(indexPath.row);
            [self updateTaskFromUI];
        }
        
        [self.tableView reloadData];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        NSInteger rows = [super tableView:tableView numberOfRowsInSection:section];
        if (_task.rate.rateType.integerValue != BBRateChargingTypeUnit && section == 0) {
            rows--;
        } else if (section == 1 && !_task.discount) {
            rows -= 2;
        }
        
        return rows;
    } else if (tableView.tag == 1) {
        return 3;
    }
    NSInteger count = self.task.matter.rates.count;
    return count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        return [super numberOfSectionsInTableView:tableView];
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.tableView) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    } else if (tableView.tag == 0) {
        static NSString *reuseIdentifier = @"rateCell";
        UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        }
        Rate *rate = [self.task.matter.ratesArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [rate name];
        if ([rate.name isEqualToString:_task.rate.name]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        
        return cell;
    } else if (tableView.tag == 1) {
        static NSString *reuseIdentifier = @"rateCell";
        UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        }
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Amount";
                break;
            case 1:
                cell.textLabel.text = @"Percent";
                break;
            case 2:
                cell.textLabel.text = @"Reprice";
                break;
            default:
                break;
        }
        if (_task.discount && _task.discount.discountType.integerValue == indexPath.row) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
    
    return 0;
}

- (IBAction)onDone:(id)sender {
    [self.delegate updateTask:_task];
    [_task.managedObjectContext MR_saveToPersistentStoreAndWait];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
#pragma mark - Navigation
- (UITableViewController *)newTableViewController {
    UITableViewController *tableviewController = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    tableviewController.tableView.dataSource = self;
    tableviewController.tableView.delegate = self;
    tableviewController.view.backgroundColor = self.view.backgroundColor;
    tableviewController.tableView.backgroundColor = self.tableView.backgroundColor;
    tableviewController.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    tableviewController.tableView.rowHeight = self.tableView.rowHeight;
    
    return tableviewController;
}

- (void)showRateSelectorTable {
    UITableViewController *ratesTableViewController = [self newTableViewController];
    ratesTableViewController.title = @"Rates";
    ratesTableViewController.tableView.tag = 0;
    
    [self.navigationController showViewController:ratesTableViewController sender:nil];
}

- (void)showDiscountTypeSelectorTable {
    UITableViewController *tableViewController = [self newTableViewController];
    tableViewController.title = @"Discount Type";
    tableViewController.tableView.tag = 1;
    
    [self.navigationController showViewController:tableViewController sender:nil];
}


#pragma mark - Observers
-(void) addTaskTimerObserver {
    __weak BBTaskViewController* weakSelf = self;
    self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:BBNotificationTaskTimerUpdate
                                                                      object:nil
                                                                       queue:[NSOperationQueue mainQueue]
                                                                  usingBlock:^(NSNotification *notification) {
                                                                      weakSelf.rateUnitTextField.text = [[BBTaskTimer sharedInstance].currentTask durationToFormattedString];
                                                                  }];
}




@end
