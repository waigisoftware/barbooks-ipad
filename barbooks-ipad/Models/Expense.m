//
//  Expense.m
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "Expense.h"
#import "NSDecimalNumber+BBUtil.h"
#import "BBCoreDataManager.h"

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

/*
- (void)awakeFromInsert
{
    [super awakeFromInsert];
    if (!self.date) {
        self.date = [NSDate date];
    }
    self.createdAt = [NSDate date];
    self.archived = [NSNumber numberWithBool:NO];
    self.amountExGst = [NSDecimalNumber zero];
    self.amountGst = [NSDecimalNumber zero];
    self.amountIncGst = [NSDecimalNumber zero];
    self.date = [NSDate date];
    self.taxed = [NSNumber numberWithBool:YES];
    self.tax = [NSDecimalNumber zero];
    self.userSpecifiedGst = [NSNumber numberWithBool:NO];
    self.expenseType = BBExpenseTypeExpense;
}
 */

- (NSNumber *)generateIdentifier
{
    return @0;
}

- (void)setCustomTaxed:(NSNumber *)taxed
{
    NSDecimalNumber *amountGst = [NSDecimalNumber zero];
    
    if (taxed.boolValue && !self.userSpecifiedGst.boolValue && self.tax && self.amountIncGst) {
        NSDecimalNumber *dec10 = [NSDecimalNumber decimalNumberWithString:@"10"];
        NSDecimalNumber *taxFactor = [self.tax decimalNumberByDividingBy:dec10 withBehavior:[NSDecimalNumber accurateRoundingHandler]];
        taxFactor = [taxFactor decimalNumberByAdding:dec10 withBehavior:[NSDecimalNumber accurateRoundingHandler]];
        
        amountGst = [self.amountIncGst decimalNumberByDividingBy:taxFactor withBehavior:[NSDecimalNumber accurateRoundingHandler]];
        
        self.amountGst = amountGst;
    } else if (!taxed.boolValue) {
        self.amountGst = amountGst;
    }
    
    self.taxed = taxed;
}

- (NSNumber *)customTaxed
{
    return self.taxed;
}

- (void)setCustomAmountGst:(NSDecimalNumber *)amountGst
{
    self.amountExGst = [self.amountIncGst decimalNumberBySubtracting:amountGst withBehavior:[NSDecimalNumber accurateRoundingHandler]];
    
    self.amountGst = amountGst;
}

- (NSDecimalNumber *)customAmountGst
{
    return self.amountGst;
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
    return [Expense MR_findAllSortedBy:@"createdAt" ascending:NO inContext:[NSManagedObjectContext MR_rootSavingContext]];
}


+ (NSArray *)unarchivedExpenses {
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"archived == %@", [NSNumber numberWithBool:NO]];
    return [Expense MR_findAllSortedBy:@"createdAt" ascending:NO withPredicate:filter inContext:[NSManagedObjectContext MR_rootSavingContext]];
}

+ (NSArray *)archivedExpenses {
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"archived == %@", [NSNumber numberWithBool:YES]];
    return [Expense MR_findAllSortedBy:@"createdAt" ascending:NO withPredicate:filter inContext:[NSManagedObjectContext MR_rootSavingContext]];
}

+ (instancetype)firstExpense {
    return [[Expense unarchivedExpenses] firstObject];
}

/*
+ (NSArray*)availableExpenseCategoriesWithManagedObjectContext:(NSManagedObjectContext*)moc
{
    NSMutableArray *categories = [NSMutableArray arrayWithArray:[GlobalAttributes expenseCategories]];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Expense" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:@[[entityDescription.propertiesByName objectForKey:@"category"]]];
    
    // Execute the fetch
    NSError *error;
    NSArray *objects = [moc executeFetchRequest:request error:&error];
    NSMutableArray *categoryNames = [NSMutableArray array];
    for( NSDictionary* obj in objects ) {
        if ([obj objectForKey:@"category"]) {
            [categoryNames addObject:[obj objectForKey:@"category"]];
        }
    }
    
    if (categoryNames.count > 0) {
        [categories addObjectsFromArray:categoryNames];
    }
    
    return categories;
}

+ (NSArray*)availablePayeesWithManagedObjectContext:(NSManagedObjectContext*)moc
{
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Expense" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    [request setResultType:NSDictionaryResultType];
    [request setPropertiesToFetch:@[[entityDescription.propertiesByName objectForKey:@"payee"]]];
    [request setReturnsDistinctResults:YES];
    
    // Execute the fetch
    NSError *error;
    NSArray *objects = [moc executeFetchRequest:request error:&error];
    NSMutableArray *payees = [NSMutableArray array];
    for( NSDictionary* obj in objects ) {
        if ([obj objectForKey:@"payee"]) {
            [payees addObject:[obj objectForKey:@"payee"]];
        }
    }
    
    return payees;
}
*/

@end
