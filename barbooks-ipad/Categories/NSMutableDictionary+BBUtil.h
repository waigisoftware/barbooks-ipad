//
//  NSMutableDictionary+BBUtil.h
//  barbooks-ipad
//
//  Created by Can on 17/09/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (BBUtil)

-(void) setNullSafeObject:(id)objectOrNil forKey:(NSString *)key;
-(void) setBool:(BOOL)value forKey:(NSString *)key;

@end
