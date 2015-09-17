//
//  NSMutableDictionary+BBUtil.m
//  barbooks-ipad
//
//  Created by Can on 17/09/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "NSMutableDictionary+BBUtil.h"

@implementation NSMutableDictionary (BBUtil)

-(void) setNullSafeObject:(id)objectOrNil forKey:(NSString *)key {
    if(objectOrNil) {
        [self setValue:objectOrNil forKeyPath:key];
    }
}

-(void) setBool:(BOOL)value forKey:(NSString *)key {
    [self setValue:[NSNumber numberWithBool:value] forKeyPath:key];
}

@end
