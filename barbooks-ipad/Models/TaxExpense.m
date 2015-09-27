//
//  TaxExpense.m
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "TaxExpense.h"
#import "BBCoreDataManager.h"

@implementation TaxExpense

+ (instancetype)newInstanceWithDefaultValue {
    TaxExpense *newExpense = [TaxExpense MR_createEntityInContext:[NSManagedObjectContext MR_rootSavingContext]];
    newExpense.createdAt = [NSDate date];
    newExpense.archived = [NSNumber numberWithBool:NO];
    newExpense.amountExGst = [NSDecimalNumber zero];
    newExpense.amountGst = [NSDecimalNumber zero];
    newExpense.amountIncGst = [NSDecimalNumber zero];
    newExpense.date = [NSDate date];
    newExpense.taxed = [NSNumber numberWithBool:NO];
    newExpense.tax = [NSDecimalNumber zero];
    newExpense.userSpecifiedGst = [NSNumber numberWithBool:NO];
    newExpense.expenseType = BBExpenseTypeExpense;
    newExpense.payee = NSLocalizedString(@"Australian Taxation Office", nil);
    [newExpense.managedObjectContext MR_saveToPersistentStoreAndWait];
    return newExpense;
}

/*
- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    self.payee = NSLocalizedString(@"Australian Taxation Office", nil);
    self.taxed = @NO;
}*/

@end
