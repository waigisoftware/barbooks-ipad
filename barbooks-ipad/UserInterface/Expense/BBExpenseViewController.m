//
//  BBExpenseViewController.m
//  barbooks-ipad
//
//  Created by Can on 10/07/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBExpenseViewController.h"

@interface BBExpenseViewController ()

@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *dateTextField;
@property (weak, nonatomic) IBOutlet CHDropDownTextField *payeeTextField;

- (IBAction)onBackgroundButton:(id)sender;

@end

@implementation BBExpenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupPayeeDropDown];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Setup

- (void)setupPayeeDropDown {
    NSArray *payeeNames = @[@"Can", @"Tom", @"Mark", @"Kim", @"Jonny"];
    _payeeTextField.dropDownTableVisibleRowCount = 4;
    _payeeTextField.dropDownTableTitlesArray = payeeNames;
    _payeeTextField.dropDownDelegate = self;
    
}

- (void)dropDownTextField:(CHDropDownTextField *)dropDownTextField didChooseDropDownOptionAtIndex:(NSUInteger)index {
    NSLog(@"%@, %ul", dropDownTextField.text, (unsigned int)index);
}

#pragma mark - Expense value

- (void)loadExpenseIntoUI {
}

- (void)updateExpenseFromUI {
}


#pragma mark - keyboards

- (void)stopEditing {
    [[UIResponder currentFirstResponder] resignFirstResponder];
    // update Expense object
    [self updateExpenseFromUI];
    // recalculate
//    [_expense recalculate];
    // refresh UI
    [self loadExpenseIntoUI];
}

#pragma mark IBActions

- (IBAction)onBackgroundButton:(id)sender {
    [self stopEditing];
}

@end
