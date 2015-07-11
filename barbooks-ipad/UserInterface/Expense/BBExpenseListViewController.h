//
//  BBExpenseListViewController.h
//  barbooks-ipad
//
//  Created by Can on 11/07/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBBaseTableViewController.h"
#import "BBExpenseViewController.h"

@interface BBExpenseListViewController : BBBaseTableViewController

@property (strong, nonatomic) Expense *expense;
@property (weak, nonatomic) BBExpenseViewController *expenseViewController;

@end
