//
//  BBTimers.h
//  barbooks-ipad
//
//  Created by Can on 1/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBTimers : NSObject

+ (instancetype)sharedInstance;
- (void)runBackgroundCoreDataSaveTimer;

@end
