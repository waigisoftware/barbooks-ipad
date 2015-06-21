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

@class ReceiptAllocation;

@interface Receipt : Payment

@property (nonatomic, retain) NSArray * matters;
@property (nonatomic, retain) id printInformation;
@property (nonatomic, retain) NSDate * printIssuedDate;
@property (nonatomic, retain) NSSet *allocations;
@end

@interface Receipt (CoreDataGeneratedAccessors)

- (void)addAllocationsObject:(ReceiptAllocation *)value;
- (void)removeAllocationsObject:(ReceiptAllocation *)value;
- (void)addAllocations:(NSSet *)values;
- (void)removeAllocations:(NSSet *)values;

@end
