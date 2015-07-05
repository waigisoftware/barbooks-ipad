//
//  NSDecimalNumber+BBUtil.h
//  barbooks-ipad
//
//  Created by Can on 20/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDecimalNumber (BBUtil)

+ (instancetype)ten;
+ (instancetype)eleven;
+ (instancetype)oneHundred;
+ (instancetype)decimalNumberWithInt:(int)value;

- (NSString*)currencyAmount;
- (NSString *)roundedAmount;
- (instancetype)decimalNumberAddGST;
- (instancetype)decimalNumberSubtractGST;

@end
