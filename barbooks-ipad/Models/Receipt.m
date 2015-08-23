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
        return nil;
    }
}

@end
