//
//  BBTaskTimer.m
//  barbooks-ipad
//
//  Created by Can on 1/07/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBTaskTimer.h"

@implementation BBTaskTimer

+ (instancetype)sharedInstance {
    static BBTaskTimer* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [BBTaskTimer new];
    });
    return instance;
}

- (void)start {
    if (self.currentTask) {
        if (!_timer) {
            _timer = [NSTimer timerWithTimeInterval:ONE_SECOND
                                            target:self
                                          selector:@selector(addOneSecondToCurrentTask)
                                          userInfo:nil
                                            repeats:YES];
            NSRunLoop *runner = [NSRunLoop currentRunLoop];
            [runner addTimer:_timer forMode:NSDefaultRunLoopMode];
        }
    }
}

- (void)pause {
    
}

- (void)resume {
    
}

- (void)stop {
    
}

- (void)addOneSecondToCurrentTask {
    self.currentTask.duration = [self.currentTask.duration decimalNumberByAdding:[NSDecimalNumber one]];
    [[NSNotificationCenter defaultCenter] postNotificationName:BBNotificationTaskTimerUpdate object:nil];
}

@end
