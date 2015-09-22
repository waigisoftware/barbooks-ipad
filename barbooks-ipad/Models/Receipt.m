//
//  Receipt.m
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "Receipt.h"
#import "ReceiptAllocation.h"
#import "Matter.h"
#import "Invoice.h"
#import "InterestInvoice.h"
#import "NSDecimalNumber+BBUtil.h"

@implementation Receipt

@dynamic matters;
@dynamic printInformation;
@dynamic printIssuedDate;
@dynamic allocations;

+ (instancetype)newInstanceOfMatter:(Matter *)matter {
    if (matter) {
        Receipt *newReceipt = [Receipt MR_createEntity];
        newReceipt.createdAt = [NSDate date];
        newReceipt.archived = [NSNumber numberWithBool:NO];
        return newReceipt;
    } else {
        Receipt *newReceipt = [Receipt MR_createEntity];
        newReceipt.createdAt = [NSDate date];
        newReceipt.archived = [NSNumber numberWithBool:NO];
        return newReceipt;
    }
}

- (Matter*)matter
{
    if (self.matters.count) {
        return [self.matters objectAtIndex:0];
    }
    return nil;
}

- (NSArray *)matters
{
    NSMutableArray *matters = [NSMutableArray new];
    for (ReceiptAllocation *allocation in self.allocations) {
        
        if (allocation.invoice && allocation.invoice.matter && ![matters containsObject:allocation.invoice.matter]) {
            [matters addObject:allocation.invoice.matter];
        }
    }
    
    return matters;
}

- (NSArray *)invoices
{
    NSMutableArray *invoices = [NSMutableArray new];
    for (ReceiptAllocation *allocation in self.allocations) {
        if (allocation.invoice) {
            [invoices addObject:allocation.invoice];
        }
    }
    
    return invoices;
}

// concaticate all invoices' numbers to display on screen
- (NSString *)invoicesNumber {
    NSMutableString *invoicesNumber =[NSMutableString stringWithString:@""];
    for (int i = 0; i < [self invoices].count; i++) {
        Invoice *invoice = [[self invoices] objectAtIndex:i];
        [invoicesNumber appendFormat:@"%@, ", invoice.entryNumber];
        if (i < [self invoices].count - 1) {
            [invoicesNumber appendString:@", "];
        }
    }
    return invoicesNumber;
}

- (NSString *)mattersDescription {
    NSMutableString *mattersDescription =[NSMutableString stringWithString:@""];
    for (Matter *matter in self.matters) {
        [mattersDescription appendFormat:@"%@, ", matter.name];
    }
    for (int i = 0; i < self.matters.count; i++) {
        Matter *matter = [self.matters objectAtIndex:i];
        [mattersDescription appendFormat:@"%@, ", matter.name];
        if (i < self.matters.count - 1) {
            [mattersDescription appendString:@", "];
        }
    }
    return mattersDescription;
}


// use it to create allocations for all selected invoices
- (NSDecimalNumber*)allocateInvoices:(NSArray*)invoices amount:(NSDecimalNumber*)amount
{
    if (!amount) {
        return [NSDecimalNumber zero];
    }
    NSDecimalNumber * tempAmountPaid = amount;
//    NSDecimalNumber * taxCalcFactor = [NSDecimalNumber ten];
    
//    Account *account = [[[invoices objectAtIndex:0] matter] account];
//    NSDecimalNumber * taxationFactor = [account.tax decimalNumberByDividingBy:taxCalcFactor withBehavior:[NSDecimalNumber accurateRoundingHandler]];
//    taxationFactor = [taxationFactor decimalNumberByAdding:taxCalcFactor withBehavior:[NSDecimalNumber accurateRoundingHandler]];
    
    // Allocate the payment to all the invoices
    NSSortDescriptor *dateSort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    invoices = [invoices sortedArrayUsingDescriptors:@[dateSort]];
    
    for (Invoice *invoice in invoices) {
        if ([invoice.totalOutstanding compare:[NSDecimalNumber zero]] != NSOrderedDescending) { continue; }
        if (tempAmountPaid <= 0) { break; }
        
        NSDecimalNumber * allocationAmountExGst = [NSDecimalNumber zero];
        NSDecimalNumber * allocationAmountGst = [NSDecimalNumber zero];
        
        NSDecimalNumber * outstandingAmountExGst = [invoice totalOutstandingExGst];
        NSDecimalNumber * outstandingAmountGst = [invoice totalOutstandingGst];
        
//        if ([invoice isKindOfClass:[InterestInvoice class]]) {
//            outstandingAmountGst = [invoice totalOutstandingGst];
//            outstandingAmountExGst = [invoice totalOutstandingExGst];
//        }
        
        if ([outstandingAmountGst compare:[NSDecimalNumber zero]] == NSOrderedDescending) {
            NSDecimalNumber * tempAmountPaidExGst = [tempAmountPaid decimalNumberSubtractGST];
            NSDecimalNumber * tempAmountPaidGst = [tempAmountPaid decimalNumberGSTOfInclusiveAmount];
            
            allocationAmountGst = [tempAmountPaidGst compare:outstandingAmountGst] == NSOrderedAscending ? tempAmountPaidGst : outstandingAmountGst;
            
            if ([outstandingAmountGst compare:allocationAmountGst] != NSOrderedAscending && [tempAmountPaidGst compare:allocationAmountGst] == NSOrderedAscending) {
                // GST already paid, more money left for paying the ExGST (this case is possible because of user specified GST values)
                NSDecimalNumber *tmpCalc = [tempAmountPaidGst decimalNumberBySubtracting:allocationAmountGst withBehavior:[NSDecimalNumber accurateRoundingHandler]] ;
                tempAmountPaidExGst = [tempAmountPaidExGst decimalNumberByAdding:tmpCalc withBehavior:[NSDecimalNumber accurateRoundingHandler]];
            }
            
            allocationAmountExGst = [tempAmountPaidGst compare:outstandingAmountGst] == NSOrderedAscending ? tempAmountPaidExGst : outstandingAmountExGst;
            
            
        } else {
            allocationAmountExGst = [tempAmountPaid compare:outstandingAmountExGst] == NSOrderedAscending ? tempAmountPaid : outstandingAmountExGst;
        }
        
        tempAmountPaid = [tempAmountPaid decimalNumberBySubtracting:allocationAmountExGst withBehavior:[NSDecimalNumber accurateRoundingHandler]];
        tempAmountPaid = [tempAmountPaid decimalNumberBySubtracting:allocationAmountGst withBehavior:[NSDecimalNumber accurateRoundingHandler]];
        
        ReceiptAllocation *allocation = [ReceiptAllocation MR_createEntity];
        if ([invoice isKindOfClass:[InterestInvoice class]]) {
            allocation.allocatedExGstAmount = allocationAmountExGst;
            allocation.allocatedGstAmount = [NSDecimalNumber zero];
        } else {
            allocation.allocatedExGstAmount = allocationAmountExGst;
            allocation.allocatedGstAmount = allocationAmountGst;
        }
        allocation.invoice = invoice;
        
        [self addAllocationsObject:allocation];
    }
    
    return tempAmountPaid;
}

@end
