//
//  NSDecimalNumber+BBUtil.m
//  barbooks-ipad
//
//  Created by Can on 20/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "NSDecimalNumber+BBUtil.h"

@implementation NSDecimalNumber (BBUtil)

+ (instancetype)ten {
    return [NSDecimalNumber decimalNumberWithString:@"10"];
}

+ (instancetype)oneHundred {
    return [NSDecimalNumber decimalNumberWithString:@"100"];
}

+ (instancetype)decimalNumberWithInt:(int)value {
    return [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%d", value]];
}

- (NSString*)currencyAmount {
    NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
    [nf setMinimumFractionDigits:2];
    [nf setMaximumFractionDigits:2];
    [nf setMinimumIntegerDigits: 1];
    return [NSString stringWithFormat:@"$%@", [nf stringFromNumber: self]];
}

@end
