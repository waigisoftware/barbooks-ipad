//
//  NSString+BBUtil.m
//  barbooks-ipad
//
//  Created by Can on 15/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "NSString+BBUtil.h"

@implementation NSString (BBUtil)

- (NSDate *)fromShortDateFormatToDate {
    // create formatter singlton
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:SHORT_DATE_FORMAT];
    });
    
    return [dateFormatter dateFromString:self];
}

- (NSNumber *)numberValue {
    return [NSNumber numberWithInteger:[self integerValue]];
}

- (BOOL)isNumeric {
    NSScanner *sc = [NSScanner scannerWithString:self];
    if ([sc scanFloat:NULL]) {
        return [sc isAtEnd];
    }
    sc = [NSScanner scannerWithString:self];
    if ([sc scanInteger:NULL]) {
        return [sc isAtEnd];
    }
    return NO;
}

- (BOOL)isAllDigits {
    NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [self rangeOfCharacterFromSet: nonNumbers];
    return r.location == NSNotFound;
}

@end
