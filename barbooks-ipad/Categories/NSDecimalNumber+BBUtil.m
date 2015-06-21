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

@end
