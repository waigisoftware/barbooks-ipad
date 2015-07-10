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
@dynamic type;
@dynamic account;
@dynamic matter;
@dynamic task;

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ (include GST) - %@ (exclude GST)", [[GlobalAttributes rateTypes] objectAtIndex: [self.type intValue]], [self.amountGst currencyAmount], [self.amount currencyAmount]];
}

- (NSString *)typeDescription {
    return [[GlobalAttributes rateTypes] objectAtIndex:[self.type intValue]];
}

@end
