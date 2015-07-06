//
//  NSDate+BBUtil.h
//  barbooks-ipad
//
//  Created by Can on 4/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (BBUtil)

+(NSDate*) fromIso8601: (NSString*) string;
-(NSString*) toIso8601;
-(NSString*) toIso8601WithTimeZone: (NSTimeZone*) timeZone;
-(NSString*) toShortDateFormat;
-(NSString*) toShortDateTimeFormat;
- (NSString *)weekday;
- (NSString *)day;
- (NSString *)month;
- (NSString *)year;

@end
