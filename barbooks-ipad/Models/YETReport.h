//
//  YETReport.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Report.h"

@class YETReportItem;

@interface YETReport : Report

@property (nonatomic, retain, readonly) NSArray * capitals;
@property (nonatomic, retain) NSDecimalNumber * capitalTotal;
@property (nonatomic, retain) NSDecimalNumber * capitalTotalExGst;
@property (nonatomic, retain) NSDecimalNumber * capitalTotalGst;
@property (nonatomic, retain, readonly) NSArray * expenses;
@property (nonatomic, retain) NSDecimalNumber * expenseTotal;
@property (nonatomic, retain) NSDecimalNumber * expenseTotalExGst;
@property (nonatomic, retain) NSDecimalNumber * expenseTotalGst;
@property (nonatomic, retain, readonly) NSArray * gstaxes;
@property (nonatomic, retain) NSDecimalNumber * gstTaxTotal;
@property (nonatomic, retain, readonly) NSArray * incomeTaxes;
@property (nonatomic, retain) NSDecimalNumber * incomeTaxTotal;
@property (nonatomic, retain) NSDecimalNumber * incomeTotal;
@property (nonatomic, retain) NSDecimalNumber * incomeTotalExGst;
@property (nonatomic, retain) NSDecimalNumber * incomeTotalGst;
@property (nonatomic, retain) NSDecimalNumber * netcash;
@property (nonatomic, retain) NSDecimalNumber * nonCapitalTotal;
@property (nonatomic, retain) NSDecimalNumber * nonCapitalTotalExGst;
@property (nonatomic, retain) NSDecimalNumber * nonCapitalTotalGst;
@property (nonatomic, retain) NSDecimalNumber * taxTotal;
@property (nonatomic, retain) NSDecimalNumber * writeOffsTotal;
@property (nonatomic, retain) NSDecimalNumber * writeOffsTotalExGst;
@property (nonatomic, retain) NSDecimalNumber * writeOffsTotalGst;
@property (nonatomic, retain) NSSet *entries;
@end

@interface YETReport (CoreDataGeneratedAccessors)

- (void)addEntriesObject:(YETReportItem *)value;
- (void)removeEntriesObject:(YETReportItem *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;

@end
