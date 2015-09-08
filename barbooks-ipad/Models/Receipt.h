//
//  Receipt.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Payment.h"
#import "Matter.h"

@class ReceiptAllocation;

@interface Receipt : Payment

@property (nonatomic, retain) NSArray * matters;
@property (nonatomic, retain) id printInformation;//not used
@property (nonatomic, retain) NSDate * printIssuedDate;//not used
@property (nonatomic, retain) NSSet *allocations;//ReceiptAllocation(Payment)
@end

@interface Receipt (CoreDataGeneratedAccessors)

- (void)addAllocationsObject:(ReceiptAllocation *)value;
- (void)removeAllocationsObject:(ReceiptAllocation *)value;
- (void)addAllocations:(NSSet *)values;
- (void)removeAllocations:(NSSet *)values;

+ (instancetype)newInstanceOfMatter:(Matter *)matter;

- (NSArray *)invoices;
- (NSString *)invoicesNumber;
- (NSString *)mattersDescription;
- (NSDecimalNumber*)allocateInvoices:(NSArray*)invoices amount:(NSDecimalNumber*)amount;

@end
