//
//  Rate.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BBManagedObject.h"
#import "GlobalAttributes.h"
#import "NSDecimalNumber+BBUtil.h"

@class Account, Matter, Task;

typedef NS_ENUM(NSUInteger, BBRateChargingType) {
    BBRateChargingTypeHourly,
    BBRateChargingTypeUnit,
    BBRateChargingTypeFixed
};

@interface Rate : BBManagedObject

@property (nonatomic, retain) NSDecimalNumber * amount; // amount exclude GST
@property (nonatomic, retain) NSDecimalNumber * amountGst;  // amount include GST
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) Account *account;
@property (nonatomic, retain) Matter *matter;
@property (nonatomic, retain) Task *task;

- (NSString *)typeDescription;
- (BBRateChargingType)rateChargingType;
- (NSDecimalNumber *)gst;
// copy amount/name/type into given rate object
- (void)copyValueToRate:(Rate *)rate;

+ (NSArray *)rateTypes;

@end
