//
//  InterestInvoice.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Invoice.h"


@interface InterestInvoice : Invoice

@property (nonatomic, retain) id additionalInformation;
@property (nonatomic, retain) NSString * additionalInformationFootnote;
@property (nonatomic, retain) NSString * affectedInvoiceNumber;
@property (nonatomic, retain) NSDecimalNumber * affectedOutstandingAmount;
@property (nonatomic, retain) NSNumber * days;
@property (nonatomic, retain) NSDecimalNumber * rate;
@property (nonatomic, retain) NSDate * startDate;

@end
