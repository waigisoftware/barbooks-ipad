//
//  DateTimeUtility.h
//  BarBooks
//
//  Created by Eric on 17/11/2014.
//  Copyright (c) 2014 Censea Software Corporation Pty Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateTimeUtility : NSObject

+ (NSComparisonResult) compareDate:(NSDate*)date1 toDate:(NSDate*)date2;
+ (NSDate*)dateByAddingDays:(NSInteger)days toDate:(NSDate*)date;
+ (NSDate*)dateByAddingYears:(NSInteger)years toDate:(NSDate*)date;
+ (NSDate*)dateByRemovingTimeFromDate:(NSDate*)date;
+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
+ (NSInteger)yearsBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
+ (BOOL)isDateInToday:(NSDate*)date;
+ (NSString*)stringFromDate:(NSDate*)date;
+ (NSDate*)endOfDate:(NSDate*)date;
+ (NSInteger)financialYearForDate:(NSDate *)date;

+ (NSDate *)financialYearStartingForDate:(NSDate *)date;
+ (NSDate *)financialYearEndingForDate:(NSDate *)date;

@end
