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
+ (instancetype)ten;
+ (instancetype)eleven;
+ (instancetype)oneHundred;
+ (instancetype)decimalNumberWithInt:(int)value;
+ (instancetype)anHourSeconds;

- (NSString*)currencyAmount;
- (NSString *)roundedAmount;
- (instancetype)decimalNumberAddGST;
- (instancetype)decimalNumberSubtractGST;

+ (NSDecimalNumberHandler*)timeRoundingHandler;
+ (NSDecimalNumberHandler*)timeFractionRoundingHandler;
+ (NSDecimalNumberHandler*)accurateRoundingHandler;
+ (NSDecimalNumberHandler*)currencyRoundingHandler;

@end
