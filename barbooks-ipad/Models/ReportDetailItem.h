//
//  ReportDetailItem.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BBManagedObject.h"

@class ReportDetail;

@interface ReportDetailItem : BBManagedObject

@property (nonatomic, retain) NSDecimalNumber * amountExGst;
@property (nonatomic, retain) NSDecimalNumber * amountGst;
@property (nonatomic, retain) NSDecimalNumber * amountIncGst;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) NSNumber * itemType;
@property (nonatomic, retain) ReportDetail *relationship;

@end
