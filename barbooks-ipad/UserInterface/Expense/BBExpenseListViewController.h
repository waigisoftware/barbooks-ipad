//
//  BBExpenseListViewController.h
//  barbooks-ipad
//
//  Created by Can on 11/07/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBBaseTableViewController.h"
#import "BBExpenseViewController.h"
#import "BBExpenseDelegate.h"

@interface BBExpenseListViewController : BBBaseTableViewController <BBExpenseDelegate>

@property (strong, nonatomic) Expense *expense;
@property (strong, nonatomic) BBExpenseViewController *expenseViewController;

- (void)fetchExpenses;

@end
