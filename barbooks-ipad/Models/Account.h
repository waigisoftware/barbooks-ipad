//
//  Account.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Contact.h"

@class GeneralExpense, Matter, Payment, Rate, Template, Report;

@interface Account : Contact

@property (nonatomic, retain) NSNumber * accountingType;
@property (nonatomic, retain) NSString * businessnumber;
@property (nonatomic, retain) NSString * chambername;
@property (nonatomic, retain) NSNumber * defaultDueDate;
@property (nonatomic, retain) NSData * signatureImage;
@property (nonatomic, retain) NSDecimalNumber * tax;
@property (nonatomic, retain) NSSet *expenses;
@property (nonatomic, retain) NSSet *matters;
@property (nonatomic, retain) NSSet *rates;
@property (nonatomic, retain) NSSet *receipts;
@property (nonatomic, retain) NSSet *reports;
@property (nonatomic, retain) NSSet *templates;

@end

@interface Account (CoreDataGeneratedAccessors)

- (void)addExpensesObject:(GeneralExpense *)value;
- (void)removeExpensesObject:(GeneralExpense *)value;
- (void)addExpenses:(NSSet *)values;
- (void)removeExpenses:(NSSet *)values;

- (void)addMattersObject:(Matter *)value;
- (void)removeMattersObject:(Matter *)value;
- (void)addMatters:(NSSet *)values;
- (void)removeMatters:(NSSet *)values;

- (void)addRatesObject:(Rate *)value;
- (void)removeRatesObject:(Rate *)value;
- (void)addRates:(NSSet *)values;
- (void)removeRates:(NSSet *)values;

- (void)addReceiptsObject:(Payment *)value;
- (void)removeReceiptsObject:(Payment *)value;
- (void)addReceipts:(NSSet *)values;
- (void)removeReceipts:(NSSet *)values;

- (void)addReportsObject:(Report *)value;
- (void)removeReportsObject:(Report *)value;
- (void)addReports:(NSSet *)values;
- (void)removeReports:(NSSet *)values;


- (void)addTemplatesObject:(Template *)value;
- (void)removeTemplatesObject:(Template *)value;
- (void)addTemplates:(NSSet *)values;
- (void)removeTemplates:(NSSet *)values;

@end
