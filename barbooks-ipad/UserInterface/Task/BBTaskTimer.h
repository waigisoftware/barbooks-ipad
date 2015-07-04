//
//  BBTaskTimer.h
//

//
//  Created by Can on 1/07/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Task.h"

@interface BBTaskTimer : NSObject {
    NSTimer *_timer;
}

@property (strong, nonatomic) Task *currentTask;

+ (instancetype)sharedInstance;
- (void)start;
- (void)pause;
- (void)resume;
- (void)stop;

@end
