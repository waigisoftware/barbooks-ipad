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
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *rateTypeTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *rateAmountIncludeGSTTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *rateAmountExcludeGSTTextField;
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

    _rateAmountIncludeGSTTextField.delegate = self;
    _rateAmountExcludeGSTTextField.delegate = self;
    _rateTypeTableView.dataSource = self;
    _rateTypeTableView.delegate = self;
    
    if (_rate) {
        _titleLabel.text = @"Edit Rate";
        _rateTypeTextField.text = [[GlobalAttributes rateTypes] objectAtIndex:[_rate.type intValue]];
        _rateAmountIncludeGSTTextField.text = [_rate.amountGst stringValue];
        _rateAmountExcludeGSTTextField.text = [_rate.amount stringValue];
        [_rateTypeTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[_rate.type integerValue] inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
        [_doneButton updateBackgroundColourAndSetEnabledTo:YES];
    } else {
        _titleLabel.text = @"New Rate";
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopEditing];
    [_delegate updateMatter:_rate];
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [GlobalAttributes rateTypes].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"selectRateTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [[GlobalAttributes rateTypes] objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _rateTypeTextField.text = [[GlobalAttributes rateTypes] objectAtIndex:indexPath.row];
    [self stopEditing];
}

// show no empty cells
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

#pragma mark IBActions

- (IBAction)onSelectRateType:(id)sender {
    BOOL hidden = _rateTypeContainerView.hidden;
    [self stopEditing];
    _rateTypeContainerView.hidden = !hidden;
}

- (IBAction)onCancel:(id)sender {
    [self stopEditing];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)onDone:(id)sender {
    [self stopEditing];
    // create Rate if applicable
    if (!_rate) {
        _rate = [Rate MR_createEntity];
    }
    _rate.amountGst = [NSDecimalNumber decimalNumberWithString:_rateAmountIncludeGSTTextField.text];
    _rate.amount = [NSDecimalNumber decimalNumberWithString:_rateAmountExcludeGSTTextField.text];
    _rate.type = [NSNumber numberWithUnsignedInteger:[[GlobalAttributes rateTypes] indexOfObject:_rateTypeTextField.text]];
    [self dismissViewControllerAnimated:YES completion:^{}];
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
