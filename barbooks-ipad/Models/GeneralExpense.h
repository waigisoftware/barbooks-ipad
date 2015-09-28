//
//  GeneralExpense.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Expense.h"

@class Account;

@interface GeneralExpense : Expense

@property (nonatomic, retain) Account *account;

+ (instancetype)newInstanceWithDefaultValue;

@end
