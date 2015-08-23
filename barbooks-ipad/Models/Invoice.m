//
//  Invoice.m
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "Invoice.h"
#import "Discount.h"
#import "Matter.h"
#import "ReceiptAllocation.h"
#import "WriteOff.h"
#import "NSDate+BBUtil.h"


@implementation Invoice

@dynamic amount;
@dynamic amountExGst;
@dynamic amountGst;
@dynamic classDisplayName;
@dynamic colorAccent;
@dynamic date;
@dynamic discountGstRate;
@dynamic discountRAte;
@dynamic dueDate;
@dynamic information;
@dynamic isPaid;
@dynamic isWrittenOff;
@dynamic payor;
@dynamic totalAmount;
@dynamic totalAmountExGst;
@dynamic totalAmountGst;
@dynamic totalOutstanding;
@dynamic totalOutstandingExGst;
@dynamic totalOutstandingGst;
@dynamic totalReceivedExGst;
@dynamic totalReceivedGst;
@dynamic totalReceivedIncGst;
@dynamic totalWrittenOff;
@dynamic totalWrittenOffExGst;
@dynamic totalWrittenOffGst;
@dynamic discount;
@dynamic matter;
@dynamic receiptAllocations;
@dynamic writeOffs;

+ (instancetype)newInstanceOfMatter:(Matter *)matter {
    if (matter) {
        Invoice *newInvoice = [Invoice MR_createEntity];
        newInvoice.createdAt = [NSDate date];
        newInvoice.archived = [NSNumber numberWithBool:NO];
        newInvoice.amount   = [NSDecimalNumber zero];
        newInvoice.amountExGst = [NSDecimalNumber zero];
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

+ (NSArray *)allUnlinkedInvoicesInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    //NSPredicate *fetchpredicate = [NSPredicate predicateWithFormat:@"matter == nil OR totalReceivedIncGst > totalAmount"];
    
    NSArray *invoices = [Invoice MR_findAllInContext:managedObjectContext];
    
    NSPredicate *amountPredicate = [NSPredicate predicateWithFormat:@"totalAmount <= 0 OR matter == nil OR (totalReceivedIncGst > totalAmount AND totalOutstanding > 1) OR (totalWrittenOff > totalAmount AND totalOutstanding > 1) OR (entity.name LIKE 'RegularInvoice' AND professionalFeeExGst < totalAmountExGst)"];
    invoices = [invoices filteredArrayUsingPredicate:amountPredicate];
    
    
    return invoices;
}

@end
