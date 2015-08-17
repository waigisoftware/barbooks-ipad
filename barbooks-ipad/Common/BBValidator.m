//
//  BBValidator.m
//  barbooks-ipad
//
//  Created by Can on 15/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBValidator.h"

@implementation BBValidator

+ (BOOL)isEmailValid:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

@end
