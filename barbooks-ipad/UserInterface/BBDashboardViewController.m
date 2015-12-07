//
//  BBDashboardViewController.m
//  barbooks-ipad
//
//  Created by Eric on 23/09/2015.
//  Copyright © 2015 Censea. All rights reserved.
//

#import "BBDashboardViewController.h"
#import "Expense.h"
#import "Receipt.h"
#import "Task.h"
#import "Rate.h"
#import "NSDate+BBUtil.h"
#import "BBModalDatePickerViewController.h"

@interface BBDashboardViewController () <UITableViewDataSource, UITableViewDelegate, BBModalDatePickerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *mattersTotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *unbilledTotalsLabel;
@property (weak, nonatomic) IBOutlet UILabel *uninvoicedTotalsLabel;
@property (weak, nonatomic) IBOutlet UIButton *fromDateButton;
@property (weak, nonatomic) IBOutlet UIButton *toDateButton;

@property (strong, nonatomic) NSOperationQueue *totalsCalculationOperation;
@property (strong, nonatomic) NSMutableDictionary *timeUnitsSummary;
@property (strong, nonatomic) NSMutableDictionary *expensesSummary;
@property (strong, nonatomic) NSMutableDictionary *receiptsSummary;
@property (strong, nonatomic) NSDate *fromDate;
@property (strong, nonatomic) NSDate *toDate;
@property (strong, nonatomic) BBModalDatePickerViewController *datePickerController;

@end

@implementation BBDashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _totalsCalculationOperation = [NSOperationQueue new];
    _toDate = [NSDate date];
    _fromDate = [_toDate dateByAddingDays:-7];
    _timeUnitsSummary = [NSMutableDictionary new];
    _expensesSummary = [NSMutableDictionary new];
    _receiptsSummary = [NSMutableDictionary new];
    self.tableView.alpha = 0;
    
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    [dateFormat setDateStyle:NSDateFormatterShortStyle];

    [_fromDateButton setTitle:[NSString stringWithFormat:@"From: %@",[dateFormat stringFromDate:_fromDate]] forState:UIControlStateNormal];
    [_toDateButton setTitle:[NSString stringWithFormat:@"To: %@",[dateFormat stringFromDate:_toDate]] forState:UIControlStateNormal];
    [self refreshUI];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_totalsCalculationOperation cancelAllOperations];
}

- (void)refreshUI {
    
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    [dateFormat setDateStyle:NSDateFormatterShortStyle];
    
    [_fromDateButton setTitle:[NSString stringWithFormat:@"From: %@",[dateFormat stringFromDate:_fromDate]] forState:UIControlStateNormal];
    [_toDateButton setTitle:[NSString stringWithFormat:@"To: %@",[dateFormat stringFromDate:_toDate]] forState:UIControlStateNormal];
    
    
    _unbilledTotalsLabel.text = @"Calculating";
    _mattersTotalLabel.text = @"...";
    _uninvoicedTotalsLabel.text = @"...";
    [_timeUnitsSummary removeAllObjects];
    [_expensesSummary removeAllObjects];
    [self.totalsCalculationOperation addOperationWithBlock:^{
        
        NSArray *matters = [Matter MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"date >= %@ AND date <= %@",[_fromDate startOfDay], [_toDate endOfDay]]];
        NSArray *expenses = [Expense MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"self.entity.name != 'Disbursement' AND date >= %@ AND date <= %@", [_fromDate startOfDay], [_toDate endOfDay]]];
        //NSArray *payments = [Payment MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"self.entity.name != 'Receipt'"]];
        
        NSDecimalNumber *outstandingTasks = [NSDecimalNumber zero];
        NSDecimalNumber *outstandingInvoices = [NSDecimalNumber zero];
        NSDecimalNumber *totalMatters = [NSDecimalNumber zero];
        
        
        for (Expense *expense in expenses) {
            NSString *category = expense.category;
            if (!category) {
                category = @"Uncategorised";
            }
            if (![_expensesSummary objectForKey:category]) {
                [_expensesSummary setObject:expense.amountIncGst forKey:category];
            } else {
                NSDecimalNumber *sum = [_expensesSummary objectForKey:category];
                sum = [sum decimalNumberByAccuratelyAdding:expense.amountIncGst];
                [_expensesSummary setObject:sum forKey:category];
            }
        }
        
        for (Matter *matter in matters) {
            for (Task *task in matter.tasks) {
                if (task.rate.rateType.integerValue == BBRateChargingTypeFixed) {
                    continue;
                }
                
                NSString *categoryName = task.rate.name;
                if ([categoryName hasSuffix:@"ly"]) {
                    categoryName = [categoryName stringByReplacingCharactersInRange:NSMakeRange(categoryName.length-2, 2) withString:@""];
                }
                if ([categoryName hasSuffix:@"i"]) {
                    categoryName = [categoryName stringByReplacingCharactersInRange:NSMakeRange(categoryName.length-1, 1) withString:@"y"];
                }
                if (![categoryName hasSuffix:@"s"] && ![categoryName hasSuffix:@"ng"]) {
                    categoryName = [categoryName stringByAppendingString:@"s"];
                }
                categoryName = [categoryName capitalizedString];
                if (!categoryName) {
                    categoryName = @"Uncategorised";
                }
                if (![_timeUnitsSummary objectForKey:categoryName]) {
                    if (task.rate.rateType.integerValue == BBRateChargingTypeHourly) {
                        NSDecimalNumber *sum = task.hours;
                        sum = [sum decimalNumberByAccuratelyAdding:[task.minutes decimalNumberByAccuratelyDividingBy:[NSDecimalNumber sixty]]];

                        [_timeUnitsSummary setObject:sum forKey:categoryName];
                    } else if (task.rate.rateType.integerValue == BBRateChargingTypeHourly) {
                        [_timeUnitsSummary setObject:task.units forKey:categoryName];
                    }
                } else {
                    NSDecimalNumber *sum = [_timeUnitsSummary objectForKey:categoryName];
                    if (task.rate.rateType.integerValue == BBRateChargingTypeHourly) {
                    
                        sum = [sum decimalNumberByAccuratelyAdding:task.hours];
                        sum = [sum decimalNumberByAccuratelyAdding:[task.minutes decimalNumberByAccuratelyDividingBy:[NSDecimalNumber sixty]]];
                    } else {
                        sum = [sum decimalNumberByAccuratelyAdding:task.units];
                    }
                    
                    [_timeUnitsSummary setObject:sum forKey:categoryName];
                }
            }
            
            outstandingTasks = [outstandingTasks decimalNumberByAccuratelyAdding:[matter amountUnbilledTasks]];
            outstandingInvoices = [outstandingInvoices decimalNumberByAccuratelyAdding:[matter amountOutstandingInvoices]];
            totalMatters = [totalMatters decimalNumberByAccuratelyAdding:[matter valueForKeyPath:@"invoices.@sum.totalAmount"]];
            totalMatters = [totalMatters decimalNumberByAccuratelyAdding:[matter valueForKeyPath:@"tasks.@sum.totalFeesIncGst"]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _mattersTotalLabel.text = [totalMatters currencyAmount];
            _unbilledTotalsLabel.text = [outstandingTasks currencyAmount];
            _uninvoicedTotalsLabel.text = [outstandingInvoices currencyAmount];
            
            [self.tableView reloadData];
            if (self.tableView.alpha == 0) {
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     self.tableView.alpha = 1;
                                 }];
            }
        });
    }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return (BOOL)_timeUnitsSummary.count + (BOOL)_expensesSummary.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _timeUnitsSummary.count;
    } else if (section == 1) {
        return _expensesSummary.count;
    }
    
    return _receiptsSummary.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Time Spent";
    } else {
        return @"Expenses";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSString *title = @"";
    NSString *amount = @"";
    
    if (indexPath.section == 0) {
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:2];
        
        title = [[_timeUnitsSummary.allKeys sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]] objectAtIndex:indexPath.row];
        amount = [formatter stringFromNumber:[_timeUnitsSummary objectForKey:title]];
    } else {
        title = [[_expensesSummary.allKeys sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]] objectAtIndex:indexPath.row];
        amount = [(NSDecimalNumber*)[_expensesSummary objectForKey:title] currencyAmount];
    }
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = amount;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UITableViewHeaderFooterView *)view forSection:(NSInteger)section
{
    view.textLabel.textColor = [UIColor grayColor];
    view.backgroundView.backgroundColor = [UIColor whiteColor];
}

#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // maybe expand for more info?
}

#pragma mark - Date Picker

- (IBAction)onPickDate:(id)sender {
    if (!self.datePickerController) {
        self.datePickerController = [BBModalDatePickerViewController defaultPicker];
        [self.datePickerController.view setFrame:self.view.bounds];
        
        self.datePickerController.delegate = self;
    }
    if (sender == _fromDateButton) {
        _toDateButton.enabled = NO;
        [self.datePickerController.datePicker setDate:_fromDate];
        [self.datePickerController.datePicker setMaximumDate:_toDate];
        [self.datePickerController.datePicker setMinimumDate:nil];
    } else {
        _fromDateButton.enabled = NO;
        [self.datePickerController.datePicker setDate:_toDate];
        [self.datePickerController.datePicker setMinimumDate:_fromDate];
        [self.datePickerController.datePicker setMaximumDate:nil];
    }
    
    [self.view addSubview:self.datePickerController.view];
    [[UIApplication sharedApplication] resignFirstResponder];
    [self.datePickerController run];
}

- (void)datePickerControllerDone:(UIDatePicker *)datePicker
{
    if (_toDateButton.enabled) {
        _fromDateButton.enabled = YES;
        _toDate = datePicker.date;
    } else {
        _toDateButton.enabled = YES;
        _fromDate = datePicker.date;
    }
    [_totalsCalculationOperation cancelAllOperations];
    [self refreshUI];
}

@end
