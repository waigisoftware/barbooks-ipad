//
//  GeneralReceipt.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Payment.h"


@interface GeneralReceipt : Payment

@property (nonatomic, retain) NSString * payee;
@property (nonatomic, retain) NSNumber * receiptClass;
@property (nonatomic, retain) NSNumber * taxed;
@property (nonatomic, retain) NSNumber * userSpecifiedGst;

@end
