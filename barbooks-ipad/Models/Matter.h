//
//  Matter.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BBManagedObject.h"

@class Account, CostsAgreement, Disbursement, Invoice, OutstandingFees, Rate, Solicitor, Task, VariationOfFees;

@interface Matter : BBManagedObject

@property (nonatomic, retain) NSDecimalNumber * amountOutstandingInvoices;
@property (nonatomic, retain) NSDecimalNumber * amountUnbilledTasks;
@property (nonatomic, retain) NSString * courtName;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * dueDate;
@property (nonatomic, retain) NSString * endClientName;
@property (nonatomic, retain) NSNumber * invoicesOverdue;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * natureOfBrief;
@property (nonatomic, retain) id payor;
@property (nonatomic, retain) NSString * reference;
@property (nonatomic, retain) NSString * registry;
@property (nonatomic, retain) NSNumber * roundingType;
@property (nonatomic, retain) NSDecimalNumber * tax;
@property (nonatomic, retain) NSNumber * taxed;
@property (nonatomic, retain) Account *account;
@property (nonatomic, retain) CostsAgreement *costsAgreement;
@property (nonatomic, retain) NSSet *disbursements;
@property (nonatomic, retain) NSSet *invoices;
@property (nonatomic, retain) NSSet *outstandingFees;
@property (nonatomic, retain) NSSet *rates;
@property (nonatomic, retain) Solicitor *solicitor;
@property (nonatomic, retain) NSSet *tasks;
@property (nonatomic, retain) VariationOfFees *variationOfFees;
@end

@interface Matter (CoreDataGeneratedAccessors)

- (void)addDisbursementsObject:(Disbursement *)value;
- (void)removeDisbursementsObject:(Disbursement *)value;
- (void)addDisbursements:(NSSet *)values;
- (void)removeDisbursements:(NSSet *)values;

- (void)addInvoicesObject:(Invoice *)value;
- (void)removeInvoicesObject:(Invoice *)value;
- (void)addInvoices:(NSSet *)values;
- (void)removeInvoices:(NSSet *)values;

- (void)addOutstandingFeesObject:(OutstandingFees *)value;
- (void)removeOutstandingFeesObject:(OutstandingFees *)value;
- (void)addOutstandingFees:(NSSet *)values;
- (void)removeOutstandingFees:(NSSet *)values;

- (void)addRatesObject:(Rate *)value;
- (void)removeRatesObject:(Rate *)value;
- (void)addRates:(NSSet *)values;
- (void)removeRates:(NSSet *)values;

- (void)addTasksObject:(Task *)value;
- (void)removeTasksObject:(Task *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;

+ (instancetype)newInstanceInManagedObjectContext:(NSManagedObjectContext*)context;
+ (instancetype)newInstanceInDefaultManagedObjectContext;
+ (instancetype)newInstanceWithDefaultValue;

@end
