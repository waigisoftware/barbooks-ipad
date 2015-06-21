//
//  DateTimeUtility.m
//  BarBooks
//
//  Created by Eric on 17/11/2014.
//  Copyright (c) 2014 Censea Software Corporation Pty Limited. All rights reserved.
//

#import "DateTimeUtility.h"

@implementation DateTimeUtility

+ (NSComparisonResult) compareDate:(NSDate*)date1 toDate:(NSDate*)date2
{
    if (!date1 || !date2) {
        return -1;
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger comps = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear);
    
    NSDateComponents *date1Components = [calendar components:comps
                                                    fromDate: date1];
    NSDateComponents *date2Components = [calendar components:comps
                                                    fromDate: date2];
    
    date1 = [calendar dateFromComponents:date1Components];
    date2 = [calendar dateFromComponents:date2Components];
    
    NSComparisonResult result = [date1 compare:date2];
    
    return result;
}

+ (NSDate*)dateByAddingYears:(NSInteger)years toDate:(NSDate*)date
{
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.year = years;
    
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDate *nextDate = [theCalendar dateByAddingComponents:dayComponent toDate:date options:0];
    
    return nextDate;
}


+ (NSDate*)endOfDate:(NSDate*)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger comps = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute);
    
    NSDateComponents *dateComponents = [calendar components:comps
                                                    fromDate: date];
    dateComponents.hour = 23;
    dateComponents.minute = 59;
    
    return [calendar dateFromComponents:dateComponents];
}


+ (NSDate*)dateByAddingDays:(NSInteger)days toDate:(NSDate*)date
{
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = days;
    
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDate *nextDate = [theCalendar dateByAddingComponents:dayComponent toDate:date options:0];
    
    return nextDate;
}

+ (NSDate *)dateByRemovingTimeFromDate:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar]
                                    components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                    fromDate:date];
    
    NSDate *dateWithoutDays = [[NSCalendar currentCalendar]
                         dateFromComponents:components];
    
    return dateWithoutDays;
}


+ (NSDate *)financialYearStartingForDate:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar]
                                    components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                    fromDate:date];
    components.day = 1;
    
    if (components.month < 7) {
        components.year -= 1;
    }
    
    components.month = 7;
    
    NSDate *dateWithoutDays = [[NSCalendar currentCalendar]
                               dateFromComponents:components];
    
    return dateWithoutDays;
}

+ (NSDate *)financialYearEndingForDate:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar]
                                    components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                    fromDate:date];
    components.day = 30;
    
    if (components.month > 6) {
        components.year += 1;
    }
    
    components.month = 6;
    
    NSDate *dateWithoutDays = [[NSCalendar currentCalendar]
                               dateFromComponents:components];
    
    return dateWithoutDays;
}


+ (NSInteger)financialYearForDate:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar]
                                    components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                    fromDate:date];
    if (components.month > 6) {
        components.year += 1;
    }
    
    return components.year;
}


+ (NSInteger)yearsBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitYear startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitYear startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitYear
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference year];
}


+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

+ (BOOL)isDateInToday:(NSDate *)date
{
    if (!date) {
        return NO;
    }
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    return [today isEqualToDate:otherDate];
}

+ (NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
}

@end
