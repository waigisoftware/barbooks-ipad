//
//  NSDate+BBUtil.m
//  barbooks-ipad
//
//  Created by Can on 4/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "NSDate+BBUtil.h"
#import "ISO8601DateFormatter.h"
#import "PrefixHeader.pch"

@implementation NSDate (BBUtil)

+(NSDate*) fromIso8601: (NSString*) string{
    ISO8601DateFormatter* formatter =  [[ISO8601DateFormatter alloc] init];
    formatter.includeTime = YES;
    return [formatter dateFromString:string];
}

-(NSString*) toIso8601 {
    ISO8601DateFormatter* formatter =  [[ISO8601DateFormatter alloc] init];
    formatter.includeTime = YES;
    return [formatter stringFromDate:self];
}

-(NSString*) toIso8601WithTimeZone: (NSTimeZone*) timeZone {
    ISO8601DateFormatter* formatter =  [[ISO8601DateFormatter alloc] init];
    formatter.includeTime = YES;
    return [formatter stringFromDate:self timeZone:timeZone];
}

-(NSString *) toShortDateFormat
{
    // create formatter singlton
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:SHORT_DATE_FORMAT];
    });
    
    return [dateFormatter stringFromDate:self];
}

-(NSString *) toShortDateTimeFormat
{
    // create formatter singlton
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:SHORT_DATE_TIME_FORMAT];
    });
    
    return [dateFormatter stringFromDate:self];
}

NSString *DAY_OF_WEEK_FORMAT = @"EEEE";
NSString *DAY_OF_MONTH_FORMAT = @"dd";
NSString *MONTH_FORMAT = @"MMM";
NSString *YEAR_FORMAT = @"yyyy";

- (NSString *)weekday {
    // create formatter singlton
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:DAY_OF_WEEK_FORMAT];
    });
    return [dateFormatter stringFromDate:self];
}

- (NSString *)day {
    // create formatter singlton
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:DAY_OF_MONTH_FORMAT];
    });
    return [dateFormatter stringFromDate:self];
}

- (NSString *)month {
    // create formatter singlton
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:MONTH_FORMAT];
    });
    return [dateFormatter stringFromDate:self];
}

- (NSString *)year {
    // create formatter singlton
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:YEAR_FORMAT];
    });
    return [dateFormatter stringFromDate:self];
}

- (NSDate *)dateAfterMonths:(NSInteger)numberOfMonths {
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.month = numberOfMonths;
    
    NSDate *currentDatePlusMonth = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
    return currentDatePlusMonth;
}

- (NSInteger)financialYear
{
    NSDateComponents *components = [[NSCalendar currentCalendar]
                                    components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                    fromDate:self];
    if (components.month > 6) {
        components.year += 1;
    }
    
    return components.year;
}

@end
