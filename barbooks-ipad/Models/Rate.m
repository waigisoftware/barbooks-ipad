//
//  Rate.m
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "Rate.h"
#import "Account.h"
#import "Matter.h"
#import "Task.h"


@implementation Rate

@dynamic amount;
@dynamic amountGst;
@dynamic name;
@dynamic type;
@dynamic account;
@dynamic matter;
@dynamic task;

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ - %@ (include GST) - %@ (exclude GST)", self.name, [[Rate rateTypes] objectAtIndex:[self.type integerValue]], [self.amountGst currencyAmount], [self.amount currencyAmount]];
}

- (NSString *)typeDescription {
    return [[Rate rateTypes] objectAtIndex:[self.type intValue]];
}

- (BBRateChargingType)rateChargingType {
    switch ([self.type integerValue]) {
        case BBRateChargingTypeHourly:
            return BBRateChargingTypeHourly;
            break;
        case BBRateChargingTypeUnit:
            return BBRateChargingTypeUnit;
            break;
        case BBRateChargingTypeFixed:
            return BBRateChargingTypeFixed;
            break;
        default:
            return BBRateChargingTypeHourly;
            break;
    }
}

- (NSDecimalNumber *)gst {
    return (self.amount && self.amountGst) ? [self.amountGst decimalNumberBySubtracting:self.amount] : [NSDecimalNumber zero];
}

- (void)copyValueToRate:(Rate *)rate {
    rate.amount = [self.amount copy];
    rate.amountGst = [self.amountGst copy];
    rate.name = [self.name copy];
    rate.type = [self.type copy];
}

+ (NSArray *)rateTypes
{
    return @[NSLocalizedString(@"hourly", nil),
             NSLocalizedString(@"unit", nil),
             NSLocalizedString(@"fixed", nil),
             ];
}

+ (NSArray *)allUnlinkedAllocationsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSArray *rates = [Rate MR_findAllInContext:managedObjectContext];
    
    rates = [rates filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"matter == nil"]];
    rates = [rates filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"task == nil"]];
    rates = [rates filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"account == nil"]];
    
    
    return rates;
}

@end






