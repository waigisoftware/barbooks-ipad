//
//  BBDiscountViewController.m
//  barbooks-ipad
//
//  Created by Can on 13/09/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBDiscountViewController.h"

@interface BBDiscountViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *discountSwitch;
@property (weak, nonatomic) IBOutlet UILabel *discountTypeLabel;
@property (weak, nonatomic) IBOutlet UITableView *discountTypeTableView;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *discountAmountTextField;

- (IBAction)onSwitch:(id)sender;

@end

@implementation BBDiscountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _discountTypeTableView.dataSource = self;
    _discountTypeTableView.delegate = self;
    
    [self loadDiscountIntoUI];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopEditing];
    [self updateDiscountFromUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Discount value

- (void)loadDiscountIntoUI {
    // values
    if (self.discount) {
        _discountSwitch.on = YES;
        _discountTypeLabel.text = self.discount.discountTypeDescription;
        _discountAmountTextField.text = [self.discount.value currencyAmount];
        [_discountTypeTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    } else {
        _discountSwitch.on = NO;
        _discountTypeLabel.text = @"";
        _discountAmountTextField.text = [[NSDecimalNumber zero] currencyAmount];
    }
    
    // visibility
    _discountTypeLabel.enabled = self.discount ? : NO;
    _discountAmountTextField.enabled = self.discount ? : NO;
    _discountTypeTableView.hidden = self.discount ? : NO;
}

- (void)updateDiscountFromUI {
    if (self.discount) {
        if (_discountSwitch.on) {
            self.discount.discountType = [NSNumber numberWithInteger:[_discountTypeTableView indexPathForSelectedRow].row];
            self.discount.value = [NSDecimalNumber decimalNumberFromCurrencyString: _discountAmountTextField.text];
        } else {
            [self.discount MR_deleteEntity];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self updateDiscountFromUI];
    return YES;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"discountTypeCell"];
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"by amount";
            break;
        case 1:
            cell.textLabel.text = @"by percent";
            break;
        case 2:
            cell.textLabel.text = @"reprice";
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    _discountTypeLabel.text = cell.textLabel.text;
    self.discount.discountType = [NSNumber numberWithInteger:indexPath.row];
}

#pragma mark - Switch

- (IBAction)onSwitch:(id)sender {
    if (_discountSwitch.on && !self.discount) {
        self.discount = [Discount newInstanceOfTask:self.task invoice:self.invoice];
    } else if (!_discountSwitch.on && self.discount) {
        [self.discount MR_deleteEntity];
    }
}

#pragma mark - keyboards

- (void)stopEditing {
    [[UIResponder currentFirstResponder] resignFirstResponder];
}

@end
