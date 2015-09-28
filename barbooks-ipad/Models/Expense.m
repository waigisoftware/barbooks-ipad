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
//
//- (NSDecimalNumber *)amountIncGst {
//    if (self.userSpecifiedGst.boolValue) {
//        return [self.amountExGst decimalNumberByAccuratelyAdding:self.tax];
//    } else {
//        return [self.amountExGst decimalNumberByAccuratelyAdding:self.amountGst];
//    }
//}

#pragma mark - calculations
/*
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
*/


- (void)setAmountIncGst:(NSDecimalNumber *)amountIncGst
{
    if (self.userSpecifiedGst.boolValue)
    {
        
    } else if(self.taxed.boolValue)
    {
        NSDecimalNumber *dec10 = [NSDecimalNumber decimalNumberWithString:@"10"];
        NSDecimalNumber *taxFactor = [self.tax decimalNumberByDividingBy:dec10 withBehavior:[NSDecimalNumber accurateRoundingHandler]];
        taxFactor = [taxFactor decimalNumberByAdding:dec10 withBehavior:[NSDecimalNumber accurateRoundingHandler]];
        
        if ([taxFactor compare:[NSDecimalNumber zero]] == NSOrderedSame) {
            self.amountGst = [NSDecimalNumber zero];
        } else {
            self.amountGst = [amountIncGst decimalNumberByDividingBy:taxFactor withBehavior:[NSDecimalNumber accurateRoundingHandler]];
        }
    }
    
    self.amountExGst = [amountIncGst decimalNumberBySubtracting:self.amountGst withBehavior:[NSDecimalNumber accurateRoundingHandler]];
    
}

- (NSDecimalNumber *)amountIncGst
{
    /*
     NSDecimalNumber *amountGst = [NSDecimalNumber zero];
     
     if (self.userSpecifiedGst.boolValue) {
     amountGst = self.amountGst;
     } else if (self.taxed.boolValue) {
     NSDecimalNumber *division = [NSDecimalNumber decimalNumberWithString:@"100"];
     NSDecimalNumber *taxFactor = [self.tax decimalNumberByDividingBy:division withBehavior:[BBManagedObject roundingHandler]];
     
     amountGst = [self.amountExGst decimalNumberByMultiplyingBy:taxFactor withBehavior:[BBManagedObject roundingHandler]];
     }
     */
    
    NSDecimalNumber *exGst = [self.amountExGst decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber currencyRoundingHandler]];
    NSDecimalNumber *gst = [self.amountGst decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber currencyRoundingHandler]];
    
    return [exGst decimalNumberByAdding:gst withBehavior:[NSDecimalNumber accurateRoundingHandler]];
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

#pragma mark - Core Data

+ (NSArray *)allExpenses {
    return [Expense MR_findAllSortedBy:@"createdAt" ascending:NO];
}


+ (NSArray *)unarchivedExpenses {
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"archived == %@", [NSNumber numberWithBool:NO]];
    return [Expense MR_findAllSortedBy:@"createdAt" ascending:NO withPredicate:filter];
}

+ (NSArray *)archivedExpenses {
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"archived == %@", [NSNumber numberWithBool:YES]];
    return [Expense MR_findAllSortedBy:@"createdAt" ascending:NO withPredicate:filter];
}

+ (instancetype)firstExpense {
    return [[Expense unarchivedExpenses] firstObject];
}

@end
