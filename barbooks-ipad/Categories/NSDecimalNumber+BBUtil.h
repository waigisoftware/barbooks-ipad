//
//  NSDecimalNumber+BBUtil.h
//  barbooks-ipad
//
//  Created by Can on 20/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDecimalNumber (BBUtil)

+ (NSDecimalNumber *)decimalNumberWithStringAndValidation:(NSString *)numberValue ;
+ (NSDecimalNumber *)decimalNumberFromCurrencyString:(NSString *)numberValue;
+ (instancetype)ten;
+ (instancetype)eleven;
+ (instancetype)oneHundred;
+ (instancetype)decimalNumberWithInt:(int)value;
+ (instancetype)anHourSeconds;

- (NSString*)currencyAmount;
- (NSString *)roundedAmount;
- (instancetype)decimalNumberAddGST;
- (instancetype)decimalNumberSubtractGST;
- (instancetype)decimalNumberGSTOfInclusiveAmount;
- (instancetype)decimalNumberGSTOfExclusiveAmount;
- (instancetype)decimalNumberByAccuratelyAdding:(NSDecimalNumber *)decimalNumber;
- (instancetype)decimalNumberByAccuratelySubtracting:(NSDecimalNumber *)decimalNumber;
- (instancetype)decimalNumberByAccuratelyMultiplyingBy:(NSDecimalNumber *)decimalNumber;
- (instancetype)decimalNumberByAccuratelyDividingBy:(NSDecimalNumber *)decimalNumber;

+ (NSDecimalNumberHandler*)timeRoundingHandler;
+ (NSDecimalNumberHandler*)timeFractionRoundingHandler;
+ (NSDecimalNumberHandler*)accurateRoundingHandler;
+ (NSDecimalNumberHandler*)currencyRoundingHandler;

@end
