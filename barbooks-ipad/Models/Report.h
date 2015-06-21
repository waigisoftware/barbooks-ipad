//
//  Report.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BBManagedObject.h"

@class Account, Attachment;

@interface Report : BBManagedObject

@property (nonatomic, retain) NSString * classDisplayName;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * isAccrual;
@property (nonatomic, retain) NSNumber * reportType;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) Account *account;
@property (nonatomic, retain) Attachment *attachment;

@end
