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


+ (instancetype)newInstanceOfTask:(Task *)task invoice:(Invoice *)invoice {
    Discount *newDiscount = [Discount MR_createEntity];
    newDiscount.discountType = [NSNumber numberWithInt:0];
    newDiscount.value = [NSDecimalNumber zero];
    if (task) {
        task.discount = newDiscount;
        newDiscount.task = task;
    }
    if (invoice) {
        invoice.discount = newDiscount;
        newDiscount.invoice = invoice;
    }
    return newDiscount;
}

- (NSDecimalNumber *)discountedAmountForTotal:(NSDecimalNumber*)totalAmount
{
    NSDecimalNumber *amount = totalAmount;
    
    switch (self.discountType.intValue) {
        case 0:
           
            amount = [totalAmount decimalNumberByAccuratelySubtracting:self.value];
            break;
        case 1:
        {
            NSDecimalNumberHandler *handler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                                     scale:4
                                                                                          raiseOnExactness:NO
                                                                                           raiseOnOverflow:NO
                                                                                          raiseOnUnderflow:NO
                                                                                       raiseOnDivideByZero:NO];
            
            NSDecimalNumber *discountFactor = [self.value decimalNumberByDividingBy:[NSDecimalNumber oneHundred] withBehavior:handler];
            amount = [totalAmount decimalNumberByMultiplyingBy:[[NSDecimalNumber one] decimalNumberByAccuratelySubtracting:discountFactor] withBehavior:[NSDecimalNumber accurateRoundingHandler]];
            break;
        }
        case 2:
            amount = self.value;
            break;
        default:
            return totalAmount;
            break;
    }
    
    
    return amount;
}

- (NSString *)discountTypeDescription {
    switch ([self.discountType intValue]) {
        case 0:
            return @"by amount";
            break;
        case 1:
            return @"by percent";
            break;
        case 2:
            return @"reprice";
            break;
            
        default:
            break;
    }
    return nil;
}

@end
