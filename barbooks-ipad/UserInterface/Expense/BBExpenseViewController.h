//
//  BBExpenseViewController.h
//  barbooks-ipad
//
//  Created by Can on 10/07/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBBaseViewController.h"
#import "Expense.h"
#import <IGLDropDownMenu/IGLDropDownMenu.h>
#import "BBExpenseDelegate.h"

@class BBExpenseListViewController;

@interface BBExpenseViewController : BBBaseViewController <CHDropDownTextFieldDelegate, IGLDropDownMenuDelegate, UITextFieldDelegate>

@property (strong, nonatomic) Expense *expense;
@property (weak, nonatomic) BBExpenseListViewController *expenseListViewController;
@property (weak, nonatomic) id<BBExpenseDelegate> delegate;

@property BOOL showCloseButton;

@end