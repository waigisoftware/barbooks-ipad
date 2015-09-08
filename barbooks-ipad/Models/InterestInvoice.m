//
//  InterestInvoice.m
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "InterestInvoice.h"
#import "Matter.h"
#import "NSDate+BBUtil.h"
#import "NSDecimalNumber+BBUtil.h"
#import "Discount.h"


@implementation InterestInvoice

@dynamic additionalInformation;
@dynamic additionalInformationFootnote;
@dynamic affectedInvoiceNumber;
@dynamic affectedOutstandingAmount;
@dynamic days;
@dynamic rate;
@dynamic startDate;

+ (instancetype)newInstanceOfMatter:(Matter *)matter {
    if (matter) {
        InterestInvoice *newInvoice = [InterestInvoice MR_createEntity];
        newInvoice.createdAt = [NSDate date];
        newInvoice.archived = [NSNumber numberWithBool:NO];
        newInvoice.amount   = [NSDecimalNumber zero];
        newInvoice.amountExGst = [NSDecimalNumber oneHundred];
        newInvoice.amountGst = [NSDecimalNumber zero];
        newInvoice.totalAmount = [NSDecimalNumber zero];
        newInvoice.totalAmountExGst = [NSDecimalNumber zero];
        newInvoice.totalAmountGst   = [NSDecimalNumber zero];
        newInvoice.totalOutstanding = [NSDecimalNumber zero];
        newInvoice.totalOutstandingExGst = [NSDecimalNumber zero];
        newInvoice.totalOutstandingGst   = [NSDecimalNumber zero];
        newInvoice.totalReceivedExGst = [NSDecimalNumber zero];
        newInvoice.totalReceivedGst = [NSDecimalNumber zero];
        newInvoice.totalReceivedIncGst   = [NSDecimalNumber zero];
        newInvoice.totalWrittenOff = [NSDecimalNumber zero];
        newInvoice.totalWrittenOffExGst = [NSDecimalNumber zero];
        newInvoice.totalWrittenOffGst   = [NSDecimalNumber zero];
        newInvoice.createdAt = [NSDate date];
        newInvoice.dueDate = [newInvoice.createdAt dateAfterMonths:1];
        newInvoice.isPaid = [NSNumber numberWithBool:NO];
        newInvoice.isWrittenOff = [NSNumber numberWithBool:NO];
        newInvoice.matter = matter;
        [matter addInvoicesObject:newInvoice];
        return newInvoice;
    } else {
        return nil;
    }
}

- (NSDecimalNumber *)totalAmountExGst
{
    if (!self.discount) {
        return self.amountExGst;
    }
    
    return [self.discount discountedAmountForTotal:self.amountExGst];
}

@end
