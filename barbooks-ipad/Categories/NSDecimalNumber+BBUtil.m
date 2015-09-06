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

// convert string value amount from $100.0 or 100.0 format to NSDecimalNumber
+ (NSDecimalNumber *)decimalNumberFromCurrencyString:(NSString *)numberValue {
    if ([numberValue isNumeric]) {
        return [NSDecimalNumber decimalNumberWithString:numberValue];
    } else {
        NSString *formattedString = [numberValue stringByReplacingOccurrencesOfString:@"$" withString:@""];
        if ([numberValue isNumeric]) {
            return [NSDecimalNumber decimalNumberWithString:formattedString];
        }
        return [NSDecimalNumber zero];
    }
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

// get GST inclusive amount of a GST exclusive amount
- (instancetype)decimalNumberAddGST {
    return [self decimalNumberByMultiplyingBy:[NSDecimalNumber onePointOne] withBehavior:[NSDecimalNumber accurateRoundingHandler]];
}

// get GST exclusive amount of a GST inclusive amount
- (instancetype)decimalNumberSubtractGST {
    return [[self decimalNumberByMultiplyingBy:[NSDecimalNumber ten] withBehavior:[NSDecimalNumber accurateRoundingHandler]] decimalNumberByDividingBy:[NSDecimalNumber eleven] withBehavior:[NSDecimalNumber accurateRoundingHandler]];
}

// get GST amount of a GST inclusive amount
- (instancetype)decimalNumberGSTOfInclusiveAmount {
    return [[self decimalNumberByMultiplyingBy:[NSDecimalNumber one] withBehavior:[NSDecimalNumber accurateRoundingHandler]] decimalNumberByDividingBy:[NSDecimalNumber eleven] withBehavior:[NSDecimalNumber accurateRoundingHandler]];
}

// get GST amount of a GST exclusive amount
- (instancetype)decimalNumberGSTOfExclusiveAmount {
    return [[self decimalNumberByMultiplyingBy:[NSDecimalNumber one] withBehavior:[NSDecimalNumber accurateRoundingHandler]] decimalNumberByDividingBy:[NSDecimalNumber ten] withBehavior:[NSDecimalNumber accurateRoundingHandler]];
}

- (instancetype)decimalNumberByAccuratelyAdding:(NSDecimalNumber *)decimalNumber {
    return [self decimalNumberByAdding:decimalNumber withBehavior:[NSDecimalNumber accurateRoundingHandler]];
}

- (instancetype)decimalNumberByAccuratelySubtracting:(NSDecimalNumber *)decimalNumber {
    return [self decimalNumberBySubtracting:decimalNumber withBehavior:[NSDecimalNumber accurateRoundingHandler]];
}

- (instancetype)decimalNumberByAccuratelyMultiplyingBy:(NSDecimalNumber *)decimalNumber {
    return [self decimalNumberByMultiplyingBy:decimalNumber withBehavior:[NSDecimalNumber accurateRoundingHandler]];
}

- (instancetype)decimalNumberByAccuratelyDividingBy:(NSDecimalNumber *)decimalNumber {
    return [self decimalNumberByDividingBy:decimalNumber withBehavior:[NSDecimalNumber accurateRoundingHandler]];
}

// rounding handlers

+ (NSDecimalNumberHandler*)currencyRoundingHandler
{
    NSDecimalNumberHandler *handler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers
                                                                                             scale:2
                                                                                  raiseOnExactness:NO
                                                                                   raiseOnOverflow:NO
                                                                                  raiseOnUnderflow:NO
                                                                               raiseOnDivideByZero:NO];
    return handler;
}


+ (NSDecimalNumberHandler*)timeRoundingHandler
{
    NSDecimalNumberHandler *handler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown
                                                                                             scale:0
                                                                                  raiseOnExactness:NO
                                                                                   raiseOnOverflow:NO
                                                                                  raiseOnUnderflow:NO
                                                                               raiseOnDivideByZero:NO];
    return handler;
}


+ (NSDecimalNumberHandler*)timeFractionRoundingHandler
{
    NSDecimalNumberHandler *handler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                             scale:5
                                                                                  raiseOnExactness:NO
                                                                                   raiseOnOverflow:NO
                                                                                  raiseOnUnderflow:NO
                                                                               raiseOnDivideByZero:NO];
    return handler;
}

+ (NSDecimalNumberHandler*)accurateRoundingHandler
{
    NSDecimalNumberHandler *handler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown
                                                                                             scale:6
                                                                                  raiseOnExactness:NO
                                                                                   raiseOnOverflow:NO
                                                                                  raiseOnUnderflow:NO
                                                                               raiseOnDivideByZero:NO];
    return handler;
}

@end
