//
//  Discount.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BBManagedObject.h"

@class Invoice, Task;

@interface Discount : BBManagedObject

@property (nonatomic, retain) NSNumber * discountType;
@property (nonatomic, retain) NSDecimalNumber * value;
@property (nonatomic, retain) Invoice *invoice;
@property (nonatomic, retain) Task *task;

- (NSDecimalNumber *)discountedAmountForTotal:(NSDecimalNumber*)total;

- (NSString *)discountTypeDescription;

+ (instancetype)newInstanceOfTask:(Task *)task invoice:(Invoice *)invoice;

@end
