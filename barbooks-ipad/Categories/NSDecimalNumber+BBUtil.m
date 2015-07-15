//
//  NSDecimalNumber+BBUtil.m
//  barbooks-ipad
//
//  Created by Can on 20/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "NSDecimalNumber+BBUtil.h"
#import "NSString+BBUtil.h"

@implementation NSDecimalNumber (BBUtil)

// return zero if input string is not a number
+ (NSDecimalNumber *)decimalNumberWithStringAndValidation:(NSString *)numberValue {
    if ([numberValue isNumeric]) {
        return [NSDecimalNumber decimalNumberWithString:numberValue];
    } else {
        return [NSDecimalNumber zero];
    }
}

+ (instancetype)onePointOne {
    return [NSDecimalNumber decimalNumberWithString:@"1.1"];
}

+ (instancetype)ten {
    return [NSDecimalNumber decimalNumberWithString:@"10"];
}

+ (instancetype)eleven {
    return [NSDecimalNumber decimalNumberWithString:@"11"];
}

+ (instancetype)oneHundred {
    return [NSDecimalNumber decimalNumberWithString:@"100"];
}

+ (instancetype)anHourSeconds {
    return [NSDecimalNumber decimalNumberWithString:@"3600"];
}

+ (instancetype)decimalNumberWithInt:(int)value {
    return [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%d", value]];
}

- (NSString *)currencyAmount {
    NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
    [nf setMinimumFractionDigits:2];
    [nf setMaximumFractionDigits:2];
    [nf setMinimumIntegerDigits: 1];
    return [NSString stringWithFormat:@"$%@", [nf stringFromNumber: self]];
}

- (NSString *)roundedAmount {
    NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
    [nf setMinimumFractionDigits:2];
    [nf setMaximumFractionDigits:2];
    [nf setMinimumIntegerDigits: 1];
    return [NSString stringWithFormat:@"%@", [nf stringFromNumber: self]];
}

- (instancetype)decimalNumberAddGST {
    NSDecimalNumberHandler *roundPlain = [NSDecimalNumberHandler
                                          decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                          scale:2
                                          raiseOnExactness:NO
                                          raiseOnOverflow:NO
                                          raiseOnUnderflow:NO
                                          raiseOnDivideByZero:YES];
    return [self decimalNumberByMultiplyingBy:[NSDecimalNumber onePointOne] withBehavior:roundPlain];
}

- (instancetype)decimalNumberSubtractGST {
    NSDecimalNumberHandler *roundPlain = [NSDecimalNumberHandler
                                          decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                          scale:2
                                          raiseOnExactness:NO
                                          raiseOnOverflow:NO
                                          raiseOnUnderflow:NO
                                          raiseOnDivideByZero:YES];
    return [[self decimalNumberByMultiplyingBy:[NSDecimalNumber ten]] decimalNumberByDividingBy:[NSDecimalNumber eleven] withBehavior:roundPlain];
}

@end
