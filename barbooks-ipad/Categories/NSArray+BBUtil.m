//
//  NSArray+BBUtil.m
//  barbooks-ipad
//
//  Created by Can on 21/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "NSArray+BBUtil.h"

@implementation NSArray (BBUtil)

- (NSUInteger)indexOfSameValueNumericObject:(NSDecimalNumber *)anObject {
    for (int i = 0; i < self.count; i++) {
        NSDecimalNumber *number = [self objectAtIndex:i];
        if ([number compare:anObject] == NSOrderedSame) {
            return i;
        }
    }
    return 0;
}

@end
