//
//  RegularInvoice.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Invoice.h"

@class Disbursement, Task;

@interface RegularInvoice : Invoice

@property (nonatomic, retain) NSDecimalNumber * disbursementsExGst;
@property (nonatomic, retain) NSDecimalNumber * disbursementsGst;
@property (nonatomic, retain) NSDecimalNumber * professionalFeeExGst;
@property (nonatomic, retain) NSDecimalNumber * professionalFeeGst;
@property (nonatomic, retain) NSSet *disbursements;
@property (nonatomic, retain) NSSet *tasks;
@end

@interface RegularInvoice (CoreDataGeneratedAccessors)

- (void)addDisbursementsObject:(Disbursement *)value;
- (void)removeDisbursementsObject:(Disbursement *)value;
- (void)addDisbursements:(NSSet *)values;
- (void)removeDisbursements:(NSSet *)values;

- (void)addTasksObject:(Task *)value;
- (void)removeTasksObject:(Task *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;

@end
