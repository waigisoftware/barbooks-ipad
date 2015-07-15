//
//  BBExpenseViewController.h
//  barbooks-ipad
//
//  Created by Can on 10/07/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBBaseViewController.h"
#import "Expense.h"
#import <JTCalendar.h>
#import <IGLDropDownMenu/IGLDropDownMenu.h>

@class BBExpenseListViewController;

@interface BBExpenseViewController : BBBaseViewController <CHDropDownTextFieldDelegate, JTCalendarDataSource, IGLDropDownMenuDelegate>

@property (strong, nonatomic) Expense *expense;
@property (weak, nonatomic) BBExpenseListViewController *expenseListViewController;

@end