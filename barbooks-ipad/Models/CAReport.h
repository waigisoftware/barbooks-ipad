//
//  CAReport.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Report.h"


@interface CAReport : Report

@property (nonatomic, retain) NSDecimalNumber * capitalsTotal;
@property (nonatomic, retain) NSDecimalNumber * expensesTotal;
@property (nonatomic, retain) NSDecimalNumber * invoicedTasksTotal;
@property (nonatomic, retain) NSDecimalNumber * invoicesTotal;
@property (nonatomic, retain) NSDecimalNumber * netCashTotal;
@property (nonatomic, retain) NSDecimalNumber * paymentsTotal;
@property (nonatomic, retain) NSDecimalNumber * tasksSubtotal;
@property (nonatomic, retain) NSDecimalNumber * taxesTotal;
@property (nonatomic, retain) NSDecimalNumber * uninvoicedTasksTotal;
@property (nonatomic, retain) NSDecimalNumber * writeOffsTotal;

@end
