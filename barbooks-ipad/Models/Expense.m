//
//  Expense.m
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "Expense.h"


@implementation Expense

@dynamic amountExGst;
@dynamic amountGst;
@dynamic amountIncGst;
@dynamic category;
@dynamic classDisplayName;
@dynamic date;
@dynamic expenseType;
@dynamic info;
@dynamic payee;
@dynamic tax;
@dynamic taxed;
@dynamic userSpecifiedGst;

+ (instancetype)newInstanceWithDefaultValue {
    Expense *newExpense = [Expense MR_createEntity];
    newExpense.amountExGst = [NSDecimalNumber zero];
    newExpense.amountGst = [NSDecimalNumber zero];
    newExpense.amountIncGst = [NSDecimalNumber zero];
    newExpense.date = [NSDate date];
    newExpense.taxed = [NSNumber numberWithBool:YES];
    newExpense.tax = [NSDecimalNumber decimalNumberWithString:@"0.1"];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [localContext save:nil];
    } completion:^(BOOL success, NSError *error) {
        NSLog(@"%@", error);
    }];
    return newExpense;
}

@end
