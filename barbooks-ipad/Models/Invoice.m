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
#import "NSDecimalNumber+BBUtil.h"
#import "RegularInvoice.h"
#import "InterestInvoice.h"


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

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    self.createdAt = [NSDate date];
    self.date = [NSDate date];
    self.entryNumber = [self generateIdentifier];
}

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

- (NSNumber*)generateIdentifier
{
    if (self.importedObject.boolValue ) {
        return nil;
    }
    
    NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"self != %@", self];
    NSSortDescriptor *descending = [[NSSortDescriptor alloc] initWithKey:@"entryNumber" ascending:NO];

    NSArray *objects = [[Invoice MR_findAllWithPredicate:filterPredicate] sortedArrayUsingDescriptors:@[descending]];
    
    int lastID = MAX(self.entryNumber.intValue,1);
    
    if (objects.count > 0) {
        Invoice *invoice = [objects objectAtIndex:0];
        if ((self.entryNumber.intValue == invoice.entryNumber.intValue && [self.createdAt compare:[[objects objectAtIndex:0] createdAt]] == NSOrderedDescending) ||
            [self.createdAt compare:[[objects objectAtIndex:0] createdAt]] == NSOrderedDescending)
        {
            lastID = MAX(lastID, [[objects objectAtIndex:0] entryNumber].intValue);
            lastID++;
        }
    }
    
    return [NSNumber numberWithInt:lastID];
}

#pragma mark - Totals and Discounts

- (NSDecimalNumber *)discountGstRate
{
    if (!self.discount) {
        return [NSDecimalNumber zero];
    }
    NSDecimalNumber *discountTotal = [self.discount discountedAmountForTotal:self.amount];
    
    NSDecimalNumber *taxFactor = [self.matter.tax decimalNumberByAccuratelyDividingBy:[NSDecimalNumber ten]];
    taxFactor = [taxFactor decimalNumberByAccuratelyAdding:[NSDecimalNumber ten]];
    
    NSDecimalNumber *discountGstAmount = [discountTotal decimalNumberByAccuratelyDividingBy:taxFactor];
    
    if ([discountGstAmount compare:self.amountGst] == NSOrderedDescending) {
        discountGstAmount = self.amountGst;
    }
    return discountGstAmount;
}

- (NSDecimalNumber *)discountExGstRate
{
    if (!self.discount) {
        return [NSDecimalNumber zero];
    }
    NSDecimalNumber *discountExGst = [self.discountRate decimalNumberByAccuratelySubtracting:self.discountGstRate];
    
    return discountExGst;
}

- (NSDecimalNumber *)discountRate
{
    if (!self.discount) {
        return [NSDecimalNumber zero];
    }
    
    return [self.discount discountedAmountForTotal:self.amount];
}

- (NSNumber *)isPayable
{
    return @(self.totalOutstanding.intValue > 1 && !self.isPaid.boolValue && !self.isWrittenOff.boolValue);
}

- (NSDecimalNumber *)totalAmountExGst
{
    if (!self.discount) {
        return self.amountExGst;
    }
    
    NSDecimalNumber *discountTotal = [self.discount discountedAmountForTotal:self.amount];
    
    NSDecimalNumber *discountExGst = [discountTotal decimalNumberByAccuratelySubtracting:[self discountGstRate]];
    
    return [self.amountExGst decimalNumberByAccuratelySubtracting:discountExGst];
}

- (NSDecimalNumber *)totalAmountGst
{
    if (!self.discount || [self.amountGst compare:[NSDecimalNumber zero]] == NSOrderedSame) {
        return self.amountGst ? self.amountGst : [NSDecimalNumber zero];
    }
    
    return [self.amountGst decimalNumberByAccuratelySubtracting:[self discountGstRate]];
}

- (NSDecimalNumber *)totalAmount
{
    if (self.totalOutstanding.integerValue == 0) {
        return [self.totalReceivedIncGst decimalNumberByAccuratelyAdding:self.totalWrittenOff];
    }
    
    return [self.totalAmountExGst decimalNumberByAccuratelyAdding:self.totalAmountGst];
}

- (NSDecimalNumber *)amount
{
    NSDecimalNumber *total = [self.amountExGst decimalNumberByAccuratelyAdding:self.amountGst];
    return total;
}

#pragma mark - Receiving Money

- (NSNumber *)isPaid
{
    NSDecimalNumber *total = [self.totalAmount decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber bankersRoundingHandler]];
    NSDecimalNumber *received = [self.totalReceivedIncGst decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber bankersRoundingHandler]];
    
    BOOL fullPaid = abs(total.intValue-received.intValue) <= 1;
    
    return @(fullPaid);
}

- (NSNumber *)isWrittenOff
{
    NSDecimalNumber *total = [self.totalAmount decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber bankersRoundingHandler]];
    NSDecimalNumber *writtenOff = [self.totalWrittenOff decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber bankersRoundingHandler]];
    
    BOOL fullWrittenOff = abs(total.intValue-writtenOff.intValue) <= 1;
    
    return @(fullWrittenOff);
}


- (NSNumber *)totalReceivedExGst
{
    if (self.receiptAllocations.count == 0) {
        return [NSDecimalNumber zero];
    }
    NSDecimalNumber * amount = [self.receiptAllocations valueForKeyPath:@"@sum.allocatedExGstAmount"];
    
    return [amount decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber accurateRoundingHandler]];
}

- (NSDecimalNumber *)totalReceivedGst
{
    if (self.receiptAllocations.count == 0) {
        return [NSDecimalNumber zero];
    }
    NSDecimalNumber * amount = [self.receiptAllocations valueForKeyPath:@"@sum.allocatedGstAmount"];
    
    return [amount decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber accurateRoundingHandler]];
}

- (NSDecimalNumber *)totalReceivedIncGst
{
    return [[self.receiptAllocations valueForKeyPath:@"@sum.allocatedIncGstAmount"] decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber accurateRoundingHandler]];
}

#pragma mark - Outstanding Amounts


- (NSDecimalNumber *)totalOutstanding
{
    NSDecimalNumber *threshhold = [NSDecimalNumber decimalNumberWithString:@"0.99"];
    
    NSDecimalNumber *amount = [self.totalOutstandingExGst decimalNumberByAccuratelyAdding:self.totalOutstandingGst];
    if ([amount compare:threshhold] == NSOrderedAscending) { // everything below threshold will be fixed to 0
        amount = [NSDecimalNumber zero];
    }
    return amount;
}

- (NSDecimalNumber *)totalOutstandingExGst
{
    NSDecimalNumber *received = [self.totalReceivedExGst decimalNumberByAccuratelyAdding:self.totalWrittenOffExGst];
    NSDecimalNumber *amount = [self.totalAmountExGst decimalNumberByAccuratelySubtracting:received];
    
    if (amount.intValue < 0) {
        amount = [NSDecimalNumber zero];
    }
    
    return amount;
}

- (NSDecimalNumber *)totalOutstandingGst
{
    NSDecimalNumber *received = [self.totalReceivedGst decimalNumberByAccuratelyAdding:self.totalWrittenOffGst];
    NSDecimalNumber *amount = [self.totalAmountGst decimalNumberByAccuratelySubtracting:received];
    
    if (amount.intValue < 0) {
        amount = [NSDecimalNumber zero];
    }
    
    return amount;
}

#pragma mark - Write-Offs

- (NSDecimalNumber *)totalWrittenOff
{
    if (self.writeOffs.count == 0) {
        return [NSDecimalNumber zero];
    }
    
    NSDecimalNumber *amount = [self.totalWrittenOffExGst decimalNumberByAccuratelyAdding:self.totalWrittenOffGst];
    
    return amount;
}

- (NSNumber *)totalWrittenOffExGst
{
    if (self.writeOffs.count == 0) {
        return [NSDecimalNumber zero];
    }
    NSDecimalNumber *amount = [self.writeOffs valueForKeyPath:@"@sum.amountExGst"];
    
    return [amount decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber accurateRoundingHandler]];
}

- (NSNumber *)totalWrittenOffGst
{
    if (self.writeOffs.count == 0) {
        return [NSDecimalNumber zero];
    }
    NSDecimalNumber *amount = [self.writeOffs valueForKeyPath:@"@sum.amountGst"];
    
    return [amount decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber accurateRoundingHandler]];
}



@end
