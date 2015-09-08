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
@dynamic rateType;
@dynamic account;
@dynamic matter;
@dynamic task;

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ - %@ (include GST) - %@ (exclude GST)", self.name, [[Rate rateTypes] objectAtIndex:[self.rateType integerValue]], [self.amountGst currencyAmount], [self.amount currencyAmount]];
}

- (NSString *)typeDescription {
    return [[Rate rateTypes] objectAtIndex:[self.rateType intValue]];
}

- (BBRateChargingType)rateChargingType {
    switch ([self.rateType integerValue]) {
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



- (void)setAmountGst:(NSDecimalNumber *)amountIncGst
{
    float tax = 0;
    if ([self matter]) {
        tax = [[[self matter] tax] floatValue];
    } else if ([self account]) {
        tax = [[[self account] tax] floatValue];
    } else if ([self task]) {
        tax = [[[[self task] matter] tax] floatValue];
    } else {
        return;
    }
    
    
    NSString *taxfactor = [NSString stringWithFormat:@"%.2f",(1+tax/100.0)];
    
    NSDecimalNumber *newRate = [amountIncGst decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:taxfactor] withBehavior:[NSDecimalNumber accurateRoundingHandler]];
    
    [self willChangeValueForKey:@"amount"];
    [self setPrimitiveValue:newRate forKey:@"amount"];
    [self didChangeValueForKey:@"amount"];
}


- (NSDecimalNumber *)amountGst
{
    float tax = 0;
    if ([self matter]) {
        tax = [[[self matter] tax] floatValue];
    } else if ([self task]) {
        tax = [[[[self task] matter] tax] floatValue];
    } else if ([self account]) {
        tax = [[[self account] tax] floatValue];
    }
    NSString *taxfactor = [NSString stringWithFormat:@"%.2f",(1+tax/100.0)];
    
    NSDecimalNumber *amount = [self amount];
    
    NSDecimalNumber *gstRate = [amount decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:taxfactor] withBehavior:[NSDecimalNumber accurateRoundingHandler]];
    
    return gstRate;
}


+ (NSSet *)keyPathsForValuesAffectingAmountGst
{
    return [NSSet setWithObjects:@"matter",@"account",@"amount",@"task", nil];
}


- (void)copyValueToRate:(Rate *)rate {
    rate.amount = [self.amount copy];
    rate.name = [self.name copy];
    rate.rateType = [self.rateType copy];
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






