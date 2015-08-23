//
//  ReceiptAllocation.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BBManagedObject.h"

@class Invoice, Receipt;

@interface ReceiptAllocation : BBManagedObject

@property (nonatomic, retain) NSDecimalNumber * allocatedExGstAmount;
@property (nonatomic, retain) NSDecimalNumber * allocatedGstAmount;
@property (nonatomic, retain) NSDecimalNumber * allocatedIncGstAmount;
@property (nonatomic, retain) NSDecimalNumber * invoiceOutstanding;
@property (nonatomic, retain) NSDecimalNumber * invoiceReceived;
@property (nonatomic, retain) Invoice *invoice;
@property (nonatomic, retain) Receipt *receipt;

+ (NSArray *)allUnlinkedAllocationsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
