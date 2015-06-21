//
//  ReportDetail.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Attachment.h"

@class ReportDetailItem;

@interface ReportDetail : Attachment

@property (nonatomic, retain) NSDecimalNumber * expenseExGstTotal;
@property (nonatomic, retain) NSDecimalNumber * expenseGstTotal;
@property (nonatomic, retain) NSDecimalNumber * expenseTotal;
@property (nonatomic, retain) NSDecimalNumber * incomeExGstTotal;
@property (nonatomic, retain) NSDecimalNumber * incomeGstTotal;
@property (nonatomic, retain) NSDecimalNumber * incomeTotal;
@property (nonatomic, retain) NSDecimalNumber * profitLossExGst;
@property (nonatomic, retain) NSDecimalNumber * profitLossGst;
@property (nonatomic, retain) NSDecimalNumber * profitLossTotal;
@property (nonatomic, retain) NSSet *items;
@end

@interface ReportDetail (CoreDataGeneratedAccessors)

- (void)addItemsObject:(ReportDetailItem *)value;
- (void)removeItemsObject:(ReportDetailItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
