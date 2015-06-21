//
//  OutstandingAmount.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BBManagedObject.h"

@class OutstandingFees;

@interface OutstandingAmount : BBManagedObject

@property (nonatomic, retain) NSDecimalNumber * amountOutstanding;
@property (nonatomic, retain) NSDecimalNumber * amountReceived;
@property (nonatomic, retain) NSDecimalNumber * amountTotal;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) OutstandingFees *outstandingFee;

@end
