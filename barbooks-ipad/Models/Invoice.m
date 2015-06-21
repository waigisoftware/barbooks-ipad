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

@end
