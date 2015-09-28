//
//  GeneralExpense.m
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "GeneralExpense.h"
#import "Account.h"
#import "BBCoreDataManager.h"

@implementation GeneralExpense

@dynamic account;

+ (instancetype)newInstanceWithDefaultValue {
    GeneralExpense *newExpense = [GeneralExpense MR_createEntityInContext:[NSManagedObjectContext MR_rootSavingContext]];
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
    [newExpense.managedObjectContext MR_saveToPersistentStoreAndWait];
    return newExpense;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
}

@end
