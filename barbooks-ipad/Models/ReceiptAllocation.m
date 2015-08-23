//
//  ReceiptAllocation.m
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "ReceiptAllocation.h"
#import "Invoice.h"
#import "Receipt.h"


@implementation ReceiptAllocation

@dynamic allocatedExGstAmount;
@dynamic allocatedGstAmount;
@dynamic allocatedIncGstAmount;
@dynamic invoiceOutstanding;
@dynamic invoiceReceived;
@dynamic invoice;
@dynamic receipt;

+ (NSArray *)allUnlinkedAllocationsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSPredicate *fetchpredicate = [NSPredicate predicateWithFormat:@"invoice == nil OR receipt == nil"];
    
    NSArray *allocations = [ReceiptAllocation MR_findAllWithPredicate:fetchpredicate inContext:managedObjectContext];
    
    return allocations;
}

@end
