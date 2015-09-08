//
//  Invoice.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BBManagedObject.h"

@class Discount, Matter, ReceiptAllocation, WriteOff;

@interface Invoice : BBManagedObject

@property (nonatomic, retain) NSDecimalNumber * amount;
@property (nonatomic, retain) NSDecimalNumber * amountExGst;
@property (nonatomic, retain) NSDecimalNumber * amountGst;
@property (nonatomic, retain) NSString * classDisplayName;
@property (nonatomic, retain) id colorAccent;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDecimalNumber * discountGstRate;
@property (nonatomic, retain) NSDecimalNumber * discountRAte;
@property (nonatomic, retain) NSDate * dueDate;
@property (nonatomic, retain) id information;
@property (nonatomic, retain) NSNumber * isPaid;
@property (nonatomic, retain) NSNumber * isWrittenOff;
@property (nonatomic, retain) id payor;
@property (nonatomic, retain) NSDecimalNumber * totalAmount;
@property (nonatomic, retain) NSDecimalNumber * totalAmountExGst;
@property (nonatomic, retain) NSDecimalNumber * totalAmountGst;
@property (nonatomic, retain) NSDecimalNumber * totalOutstanding;
@property (nonatomic, retain) NSDecimalNumber * totalOutstandingExGst;
@property (nonatomic, retain) NSDecimalNumber * totalOutstandingGst;
@property (nonatomic, retain) NSDecimalNumber * totalReceivedExGst;
@property (nonatomic, retain) NSDecimalNumber * totalReceivedGst;
@property (nonatomic, retain) NSDecimalNumber * totalReceivedIncGst;
@property (nonatomic, retain) NSDecimalNumber * totalWrittenOff;
@property (nonatomic, retain) NSDecimalNumber * totalWrittenOffExGst;
@property (nonatomic, retain) NSDecimalNumber * totalWrittenOffGst;
@property (nonatomic, retain) Discount *discount;
@property (nonatomic, retain) Matter *matter;
@property (nonatomic, retain) NSSet *receiptAllocations;
@property (nonatomic, retain) NSSet *writeOffs;
@end

@interface Invoice (CoreDataGeneratedAccessors)

- (void)addReceiptAllocationsObject:(ReceiptAllocation *)value;
- (void)removeReceiptAllocationsObject:(ReceiptAllocation *)value;
- (void)addReceiptAllocations:(NSSet *)values;
- (void)removeReceiptAllocations:(NSSet *)values;

- (void)addWriteOffsObject:(WriteOff *)value;
- (void)removeWriteOffsObject:(WriteOff *)value;
- (void)addWriteOffs:(NSSet *)values;
- (void)removeWriteOffs:(NSSet *)values;

+ (instancetype)newInstanceOfMatter:(Matter *)matter;

@end
