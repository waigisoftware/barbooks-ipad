//
//  NSString+BBUtil.h
//  barbooks-ipad
//
//  Created by Can on 15/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (BBUtil)

- (NSDate *)fromShortDateFormatToDate;

- (NSNumber *)numberValue;

- (BOOL)isNumeric;

- (BOOL)isAllDigits;

@end
