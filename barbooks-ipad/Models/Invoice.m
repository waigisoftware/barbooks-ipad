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
    NSDecimalNumberHandler *currencyHandler = [NSDecimalNumber accurateRoundingHandler];
    
    NSDecimalNumber *dec10 = [NSDecimalNumber decimalNumberWithString:@"10"];
    NSDecimalNumber *taxFactor = [self.matter.tax decimalNumberByDividingBy:dec10 withBehavior:currencyHandler];
    taxFactor = [taxFactor decimalNumberByAdding:dec10 withBehavior:currencyHandler];
    
    NSDecimalNumber *discountGstAmount = [discountTotal decimalNumberByDividingBy:taxFactor];
    
    if ([discountGstAmount compare:self.amountGst] == NSOrderedDescending) {
        discountGstAmount = self.amountGst;
    }
    return discountGstAmount;
}


+ (NSSet *)keyPathsForValuesAffectingDiscountGstRate
{
    return [NSSet setWithObjects:@"discount", @"discount.value", @"discount.type",@"amountGst", nil];
}


- (NSDecimalNumber *)discountExGstRate
{
    if (!self.discount) {
        return [NSDecimalNumber zero];
    }
    NSDecimalNumber *discountExGst = [self.discountRate decimalNumberBySubtracting:self.discountGstRate withBehavior:[NSDecimalNumber accurateRoundingHandler]];
    
    return discountExGst;
}


+ (NSSet *)keyPathsForValuesAffectingDiscountExGstRate
{
    return [NSSet setWithObjects:@"discountRate",@"discountGstRate", nil];
}


- (NSDecimalNumber *)discountRate
{
    if (!self.discount) {
        return [NSDecimalNumber zero];
    }
    
    return [self.discount discountedAmountForTotal:self.amount];
}


+ (NSSet *)keyPathsForValuesAffectingDiscountRate
{
    return [NSSet setWithObjects:@"discount", @"discount.value", @"discount.type", nil];
}

- (NSNumber *)isPayable
{
    return @(self.totalOutstanding.intValue > 1 && !self.isPaid.boolValue && !self.isWrittenOff.boolValue);
}

+ (NSSet *)keyPathsForValuesAffectingIsPayable {
    return [NSSet setWithObject:@"self.totalOutstanding"];
}

- (NSDecimalNumber *)totalAmountExGst
{
    if (!self.discount) {
        return self.amountExGst;
    }
    
    NSDecimalNumberHandler *currencyHandler = [NSDecimalNumber accurateRoundingHandler];
    
    NSDecimalNumber *discountTotal = [self.discount discountedAmountForTotal:self.amount];
    
    NSDecimalNumber *discountExGst = [discountTotal decimalNumberBySubtracting:[self discountGstRate] withBehavior:currencyHandler];
    
    return [self.amountExGst decimalNumberBySubtracting:discountExGst withBehavior:currencyHandler];
}

+ (NSSet *)keyPathsForValuesAffectingAmountExGst
{
    return [NSSet setWithObjects:@"discount", @"discount.value", @"discount.type", nil];
}

- (NSDecimalNumber *)totalAmountGst
{
    
    if (!self.discount || [self.amountGst compare:[NSDecimalNumber zero]] == NSOrderedSame) {
        
        return self.amountGst ? self.amountGst : [NSDecimalNumber zero];
    }
    
    return [self.amountGst decimalNumberBySubtracting:[self discountGstRate] withBehavior:[NSDecimalNumber accurateRoundingHandler]];
}

+ (NSSet *)keyPathsForValuesAffectingAmountGst
{
    return [NSSet setWithObjects:@"discount", @"discount.value", @"discount.type", nil];
}

- (NSDecimalNumber *)totalAmount
{
    NSDecimalNumber *amountExGst = [self.totalAmountExGst decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber currencyRoundingHandler]];
    NSDecimalNumber *amountGst = [self.totalAmountGst decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber currencyRoundingHandler]];
    
    if (self.totalOutstanding.integerValue == 0) {
        return [self.totalReceivedIncGst decimalNumberByAdding:self.totalWrittenOff withBehavior:[NSDecimalNumber accurateRoundingHandler]];
    }
    
    return [amountExGst decimalNumberByAdding:amountGst withBehavior:[NSDecimalNumber accurateRoundingHandler]];
}

+ (NSSet *)keyPathsForValuesAffectingTotalAmount
{
    return [NSSet setWithObjects:@"amountExGst", @"amountGst", @"discount", @"discount.value", @"discount.type", nil];
}

- (NSDecimalNumber *)amount
{
    NSNumberFormatter *currency = [NSNumberFormatter new];
    [currency setMinimumFractionDigits:6];
    
    NSDecimalNumber *amountExGst = [self.amountExGst decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber currencyRoundingHandler]];
    NSDecimalNumber *amountGst = [self.amountGst decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber currencyRoundingHandler]];
    
    
    NSDecimalNumber *total = [amountExGst decimalNumberByAdding:amountGst withBehavior:[NSDecimalNumber accurateRoundingHandler]];
    
    return total;
}

+ (NSSet *)keyPathsForValuesAffectingAmount
{
    return [NSSet setWithObjects:@"amountExGst", @"amountGst", nil];
}


#pragma mark - Receiving Money
- (NSNumber *)isPaid
{
    NSDecimalNumberHandler *handler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers
                                                                                             scale:0
                                                                                  raiseOnExactness:NO
                                                                                   raiseOnOverflow:NO
                                                                                  raiseOnUnderflow:NO
                                                                               raiseOnDivideByZero:NO];
    
    
    NSDecimalNumber *total = [self.totalAmount decimalNumberByRoundingAccordingToBehavior:handler];
    NSDecimalNumber *received = [self.totalReceivedIncGst decimalNumberByRoundingAccordingToBehavior:handler];
    
    BOOL fullPaid = abs(total.intValue-received.intValue) <= 1;
    
    return @(fullPaid);
}

- (NSNumber *)isWrittenOff
{
    NSDecimalNumberHandler *handler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers
                                                                                             scale:0
                                                                                  raiseOnExactness:NO
                                                                                   raiseOnOverflow:NO
                                                                                  raiseOnUnderflow:NO
                                                                               raiseOnDivideByZero:NO];
    
    
    NSDecimalNumber *total = [self.totalAmount decimalNumberByRoundingAccordingToBehavior:handler];
    NSDecimalNumber *writtenOff = [self.totalWrittenOff decimalNumberByRoundingAccordingToBehavior:handler];
    
    BOOL fullWrittenOff = abs(total.intValue-writtenOff.intValue) <= 1;
    
    return @(fullWrittenOff);
}

+ (NSSet *)keyPathsForValuesAffectingIsWrittenOff
{
    return [NSSet setWithObjects:@"writeOffs", @"totalAmount", @"isPaid", nil];
}


+ (NSSet *)keyPathsForValuesAffectingIsPaid
{
    return [NSSet setWithObjects:@"receiptAllocations",  @"writeOffs", @"totalAmount", nil];
}


- (NSNumber *)totalReceivedExGst
{
    if (self.receiptAllocations.count == 0) {
        return [NSDecimalNumber zero];
    }
    NSDecimalNumber * amount = [self.receiptAllocations valueForKeyPath:@"@sum.allocatedExGstAmount"];
    
    return [amount decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber accurateRoundingHandler]];
}


+ (NSSet *)keyPathsForValuesAffectingTotalReceivedExGst
{
    return [NSSet setWithObjects:@"receiptAllocations", @"totalAmount", nil];
}

- (NSDecimalNumber *)totalReceivedGst
{
    if (self.receiptAllocations.count == 0) {
        return [NSDecimalNumber zero];
    }
    NSDecimalNumber * amount = [self.receiptAllocations valueForKeyPath:@"@sum.allocatedGstAmount"];
    
    return [amount decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber accurateRoundingHandler]];
}

+ (NSSet *)keyPathsForValuesAffectingTotalReceivedGst
{
    return [NSSet setWithObjects:@"receiptAllocations", @"totalAmount", nil];
}


- (NSDecimalNumber *)totalReceivedIncGst
{
    return [[self.receiptAllocations valueForKeyPath:@"@sum.allocatedIncGstAmount"] decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber accurateRoundingHandler]];
}

+ (NSSet *)keyPathsForValuesAffectingTotalReceivedIncGst
{
    return [NSSet setWithObjects:@"receiptAllocations", @"totalAmount", nil];
}

#pragma mark - Write-Offs

- (NSDecimalNumber *)totalWrittenOff
{
    if (self.writeOffs.count == 0) {
        return [NSDecimalNumber zero];
    }
    NSDecimalNumber *amountExGst = [self.totalWrittenOffExGst decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber currencyRoundingHandler]];
    NSDecimalNumber *amountGst = [self.totalWrittenOffGst decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber currencyRoundingHandler]];
    
    NSDecimalNumber *amount = [amountExGst decimalNumberByAdding:amountGst withBehavior:[NSDecimalNumber accurateRoundingHandler]];
    
    return amount;
}

+ (NSSet *)keyPathsForValuesAffectingTotalWrittenOff
{
    return [NSSet setWithObjects:@"writeOffs", @"totalAmount", nil];
}

- (NSNumber *)totalWrittenOffExGst
{
    if (self.writeOffs.count == 0) {
        return [NSDecimalNumber zero];
    }
    NSDecimalNumber *amount = [self.writeOffs valueForKeyPath:@"@sum.amountExGst"];
    
    return [amount decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber accurateRoundingHandler]];
}

+ (NSSet *)keyPathsForValuesAffectingTotalWrittenOffExGst
{
    return [NSSet setWithObjects:@"writeOffs", @"totalAmount", nil];
}

- (NSNumber *)totalWrittenOffGst
{
    if (self.writeOffs.count == 0) {
        return [NSDecimalNumber zero];
    }
    NSDecimalNumber *amount = [self.writeOffs valueForKeyPath:@"@sum.amountGst"];
    
    return [amount decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber accurateRoundingHandler]];
}

+ (NSSet *)keyPathsForValuesAffectingTotalWrittenOffGst
{
    return [NSSet setWithObjects:@"writeOffs", @"totalAmount", nil];
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

@end
