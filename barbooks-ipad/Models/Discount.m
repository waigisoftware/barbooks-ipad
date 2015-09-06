//
//  Discount.m
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "Discount.h"
#import "Invoice.h"
#import "Task.h"
#import "NSDecimalNumber+BBUtil.h"

@implementation Discount

@dynamic discountType;
@dynamic value;
@dynamic invoice;
@dynamic task;

- (NSDecimalNumber *)discountedAmountForTotal:(NSDecimalNumber*)totalAmount
{
    NSDecimalNumber *amount = totalAmount;
    
    switch (self.discountType.intValue) {
        case 0:
            
            amount = self.value;
            
            break;
        case 1:
        {
            NSDecimalNumber *discountFactor = [self.value decimalNumberByAccuratelyDividingBy:[NSDecimalNumber oneHundred]];
            amount = [totalAmount decimalNumberByAccuratelyMultiplyingBy:discountFactor];
            
            break;
        }
        case 2:
            amount = [totalAmount decimalNumberByAccuratelySubtracting:self.value];
            break;
        default:
            return totalAmount;
            break;
    }
    
    return amount;
}

@end
