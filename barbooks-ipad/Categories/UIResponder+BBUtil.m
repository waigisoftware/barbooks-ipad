//
//  UIResponder+BBUtil.m
//  barbooks-ipad
//
//  Created by Can on 15/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "UIResponder+BBUtil.h"

static __weak id currentFirstResponder;

@implementation UIResponder (BBUtil)

+ (id)currentFirstResponder {
    currentFirstResponder = nil;
    [[UIApplication sharedApplication] sendAction:@selector(findFirstResponder:) to:nil from:nil forEvent:nil];
    return currentFirstResponder;
}

- (void)findFirstResponder:(id)sender {
    currentFirstResponder = self;
}

@end
