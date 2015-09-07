//
//  YETReportItem.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BBManagedObject.h"

@class YETReport;

@interface YETReportItem : BBManagedObject

@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) NSDecimalNumber * totalAmount;
@property (nonatomic, retain) NSDecimalNumber * totalAmountExGst;
@property (nonatomic, retain) NSDecimalNumber * totalAmountGst;
@property (nonatomic, retain) NSNumber * itemType;
@property (nonatomic, retain) YETReport *report;

@end
