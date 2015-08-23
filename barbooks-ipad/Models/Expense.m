//
//  Expense.m
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "Expense.h"
#import "NSDecimalNumber+BBUtil.h"


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
    newExpense.createdAt = [NSDate date];
    newExpense.archived = [NSNumber numberWithBool:NO];
    newExpense.amountExGst = [NSDecimalNumber zero];
    newExpense.amountGst = [NSDecimalNumber zero];
    newExpense.amountIncGst = [NSDecimalNumber zero];
    newExpense.date = [NSDate date];
    newExpense.taxed = [NSNumber numberWithBool:YES];
    newExpense.tax = [NSDecimalNumber zero];
    newExpense.userSpecifiedGst = [NSNumber numberWithBool:NO];
    newExpense.expenseType = BBExpenseTypeExpense;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [localContext save:nil];
    } completion:^(BOOL success, NSError *error) {
        NSLog(@"%@", error);
    }];
    return newExpense;
}

#pragma mark - calculations

- (void)recalculate {
    [self recalculateFees];
}

- (void)recalculateFees {
    if (self.isTaxed) {
        if (self.taxType == BBExpenseTaxTypePercentage) {
            self.amountExGst = [self.amountIncGst decimalNumberSubtractGST];
            self.amountGst = [self.amountIncGst decimalNumberBySubtracting:self.amountExGst];
        } else {
            self.amountGst = self.tax;
            self.amountExGst = [self.amountIncGst decimalNumberBySubtracting:self.amountGst];
        }
    } else {
        self.amountExGst = self.amountIncGst;
        self.amountGst = [NSDecimalNumber zero];
    }
}

#pragma mark - convenient methods

- (BBExpenseTaxType)taxType {
    return [self.userSpecifiedGst boolValue] ? BBExpenseTaxTypeUserSpecified : BBExpenseTaxTypePercentage;
}

- (BOOL)isTaxed {
    return [self.taxed boolValue];
}

+ (NSArray *)payeeList {
    NSMutableSet *set = [NSMutableSet setWithArray:[[Expense MR_findAll] valueForKey:@"payee"]];
    [set removeObject:[NSNull null]];
    [set removeObject:@""];
    return [set allObjects];
}

+ (NSArray *)categoryList {
    NSMutableSet *set = [NSMutableSet setWithArray:[[Expense MR_findAll] valueForKey:@"category"]];
    [set removeObject:[NSNull null]];
    [set removeObject:@""];
    return [set allObjects];
}

@end
