//
//  BBTimers.m
//  barbooks-ipad
//
//  Created by Can on 1/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBTimers.h"

@implementation BBTimers

+ (instancetype)sharedInstance {
    static BBTimers* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BBTimers alloc] init];
    });
    return instance;
}

#pragma mark - backgroud Core Data updating timer

const NSTimeInterval BackgroundCoreDataSaveTimerRunningInterval = 600.0;
- (void)runBackgroundCoreDataSaveTimer {
    NSTimer *timer = [NSTimer timerWithTimeInterval:BackgroundCoreDataSaveTimerRunningInterval
                                             target:self
                                           selector:@selector(saveCoreDataIfNeeded)
                                           userInfo:nil
                                            repeats:YES];
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)saveCoreDataIfNeeded {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            NSLog(@"all data saved!");
        }];
    });
}

@end
