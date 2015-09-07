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
            
            NSDecimalNumberHandler *handler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                                     scale:4
                                                                                          raiseOnExactness:NO
                                                                                           raiseOnOverflow:NO
                                                                                          raiseOnUnderflow:NO
                                                                                       raiseOnDivideByZero:NO];
            
            NSDecimalNumber *discountFactor = [self.value decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"100"] withBehavior:handler];
            amount = [totalAmount decimalNumberByMultiplyingBy:discountFactor withBehavior:[NSDecimalNumber accurateRoundingHandler]];
            
            break;
        }
        case 2:
            amount = [totalAmount decimalNumberBySubtracting:self.value withBehavior:[NSDecimalNumber accurateRoundingHandler]];
            break;
        default:
            return totalAmount;
            break;
    }
    
    return amount;
}

@end
