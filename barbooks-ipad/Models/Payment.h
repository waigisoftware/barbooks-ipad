//
//  Payment.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BBManagedObject.h"

@class Account;

@interface Payment : BBManagedObject

@property (nonatomic, retain) NSString * affiliationDescription;
@property (nonatomic, retain) NSDecimalNumber * amountExGst;
@property (nonatomic, retain) NSDecimalNumber * amountGst;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) NSNumber * paymentType;
@property (nonatomic, retain) NSNumber * printoutGenerateable;
@property (nonatomic, retain) NSNumber * printoutViewable;
@property (nonatomic, retain) id relatedAccount;
@property (nonatomic, retain) NSDecimalNumber * totalAmount;
@property (nonatomic, retain) Account *account;

@end
