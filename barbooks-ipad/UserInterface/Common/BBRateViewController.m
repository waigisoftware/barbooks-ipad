//
//  BBRateViewController.m
//  barbooks-ipad
//
//  Created by Can on 4/07/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBRateViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface BBRateViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *rateNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *rateTypeLabel;
@property (weak, nonatomic) IBOutlet UITextField *rateAmountIncludeGSTTextField;
@property (weak, nonatomic) IBOutlet UITextField *rateAmountExcludeGSTTextField;
@property (weak, nonatomic) IBOutlet UIView *rateTypeContainerView;
@property (weak, nonatomic) IBOutlet UITableView *rateTypeTableView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

- (IBAction)onSelectRateType:(id)sender;
- (IBAction)onCancel:(id)sender;
- (IBAction)onDone:(id)sender;
- (IBAction)onBackgroundButton:(id)sender;

@end

@implementation BBRateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureRACOnButton];

    _rateNameTextField.delegate = self;
    _rateAmountIncludeGSTTextField.delegate = self;
    _rateAmountExcludeGSTTextField.delegate = self;
    _rateTypeTableView.dataSource = self;
    _rateTypeTableView.delegate = self;
    [self.tableView setContentInset:UIEdgeInsetsMake(-35, 0, 0, 0)];

    if (_rate) {
        self.title = @"Edit Rate";
        [_rateTypeTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[_rate.type integerValue] inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
        [_doneButton updateBackgroundColourAndSetEnabledTo:YES];
    } else {
        _rate = [Rate MR_createEntity];
        _rate.amount = [NSDecimalNumber oneHundred];
        _rate.matter = self.matter;
        self.title = @"New Rate";
    }
    
    _rateNameTextField.text = _rate.name;
    _rateTypeLabel.text = [[Rate rateTypes] objectAtIndex:[_rate.type intValue]];
    _rateAmountExcludeGSTTextField.text = [_rate.amount stringValue];
    _rateAmountIncludeGSTTextField.text = [_rate.amountGst stringValue];
    

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopEditing];
    [_delegate updateRate:_rate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (_rateAmountIncludeGSTTextField == textField && [textField.text isNumeric]) {
        _rateAmountExcludeGSTTextField.text = [[[NSDecimalNumber decimalNumberWithString:_rateAmountIncludeGSTTextField.text] decimalNumberSubtractGST] roundedAmount];
    } else if (_rateAmountExcludeGSTTextField == textField && [textField.text isNumeric]) {
        _rateAmountIncludeGSTTextField.text = [[[NSDecimalNumber decimalNumberWithString:_rateAmountExcludeGSTTextField.text] decimalNumberAddGST] roundedAmount];
    }
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        if (indexPath.section == 0) {
            if (indexPath.row == 1) {
                [self showRateSelectorTable];
            }
        } else {
            [self onDone:self];
        }
    } else {
        
        _rate.type = @(indexPath.row);
        _rateTypeLabel.text = [[Rate rateTypes] objectAtIndex:indexPath.row];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    return [Rate rateTypes].count;
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
    }
    
    NSArray *types = [Rate rateTypes];
    
    static NSString *reuseIdentifier = @"rateCell";
    UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }

    cell.textLabel.text = [types objectAtIndex:indexPath.row];
    if (indexPath.row == _rate.type.integerValue) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    return cell;
}


#pragma mark - Navigation
- (void)showRateSelectorTable {
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    tableViewController.tableView.dataSource = self;
    tableViewController.tableView.delegate = self;
    tableViewController.title = @"Rate Types";
    tableViewController.view.backgroundColor = self.view.backgroundColor;
    tableViewController.tableView.backgroundColor = self.tableView.backgroundColor;
    
    [self.navigationController showViewController:tableViewController sender:nil];
    [tableViewController.tableView reloadData];
}


#pragma mark IBActions

- (IBAction)onSelectRateType:(id)sender {
    BOOL hidden = _rateTypeContainerView.hidden;
    [self stopEditing];
    _rateTypeContainerView.hidden = !hidden;
}

- (IBAction)onCancel:(id)sender {
    [self stopEditing];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onDone:(id)sender {
    [self stopEditing];
    // create Rate if applicable
    _rate.name = _rateNameTextField.text;
    //_rate.amountGst = [NSDecimalNumber decimalNumberWithString:_rateAmountIncludeGSTTextField.text];
    _rate.amount = [NSDecimalNumber decimalNumberWithString:_rateAmountExcludeGSTTextField.text];
    _rate.type = [NSNumber numberWithUnsignedInteger:[[Rate rateTypes] indexOfObject:_rateTypeLabel.text]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onBackgroundButton:(id)sender {
    [self stopEditing];
}

#pragma mark - resignFirstResponders and hide all popup views

- (void)stopEditing {
    [[UIResponder currentFirstResponder] resignFirstResponder];
    _rateTypeContainerView.hidden = YES;
}

#pragma mark - Setup/Config

- (void) configureRACOnButton{
    RACSignal* signal =
    [RACSignal combineLatest:@[self.rateAmountIncludeGSTTextField.rac_textSignal, self.rateAmountExcludeGSTTextField.rac_textSignal]
                      reduce:^(NSString *amountGst, NSString *amount) {
                          return @(
                          [amountGst isNumeric] || [amount isNumeric]
                          );
                      }];
    
    [signal subscribeNext:^(NSNumber* isEnabled) {
        [self.doneButton updateBackgroundColourAndSetEnabledTo:[isEnabled boolValue]];
    }];
}

@end
