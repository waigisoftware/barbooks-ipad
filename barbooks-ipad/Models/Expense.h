//
//  Expense.h
//  ;
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BBManagedObject.h"

typedef NS_ENUM(NSUInteger, BBExpenseTaxType) {
    BBExpenseTaxTypePercentage = 0,
    BBExpenseTaxTypeUserSpecified
};

typedef NS_ENUM(NSUInteger, BBExpenseType) {
    BBExpenseTypeExpense = 0,
    BBExpenseTypeCapital
};

@interface Expense : BBManagedObject

@property (nonatomic, retain) NSDecimalNumber * amountExGst;
@property (nonatomic, retain) NSDecimalNumber * amountGst;
@property (nonatomic, retain) NSDecimalNumber * amountIncGst;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * classDisplayName;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * expenseType;
@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) NSString * payee;
@property (nonatomic, retain) NSDecimalNumber * tax;
@property (nonatomic, retain) NSNumber * taxed;
@property (nonatomic, retain) NSNumber * userSpecifiedGst;

+ (instancetype)newInstanceWithDefaultValue;
// all distinct existing payees
+ (NSArray *)payeeList;

- (void)recalculate;
- (BBExpenseTaxType)taxType;
- (BOOL)isTaxed;

@end
