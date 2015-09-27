//
//  BBTaskTimer.h
//

//
//  Created by Can on 1/07/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Task.h"

#define kTimerActivatedNotification @"kTimerActivatedNotification"
#define kTimerDeactivatedNotification @"kTimerDeactivatedNotification"
#define kTimerUpdatedNotification @"kTimerUpdatedNotification"
#define kTimerPausedNotification @"kTimerPausedNotification"
#define kTimerResumedNotification @"kTimerResumedNotification"


@interface BBTaskTimer : NSObject {
    NSTimer *_timer;
}

@property (strong, nonatomic) Task *currentTask;

@property (assign) CFAbsoluteTime startStamp;

+ (instancetype)sharedInstance;

- (void)startWithTask:(Task *)task sender:(id)sender;
- (void)stop;
- (void)resume;
- (void)pause;

- (BOOL)active;

@end
