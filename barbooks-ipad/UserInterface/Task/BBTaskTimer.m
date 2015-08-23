//
//  BBTaskTimer.m
//  barbooks-ipad
//
//  Created by Can on 1/07/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBTaskTimer.h"
#import "GlobalAttributes.h"
#import "Matter.h"
#import "NSDecimalNumber+BBUtil.h"

#define kTimerUpdateInterval 1.0

@interface BBTaskTimer ()


@property (assign) BOOL timerActive;
@property (strong) id sender;

@property (strong) NSTimer *refreshTimer;
@property (strong) NSTimer *remindTimer;
@property (strong) NSDecimalNumberHandler *handler;
@property (assign) CFAbsoluteTime startStamp;
@property (strong) NSDecimalNumber *startDuration;


@end

@implementation BBTaskTimer

+ (instancetype)sharedInstance {
    static BBTaskTimer* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [BBTaskTimer new];
    });
    return instance;
}
//
//- (void)start {
//    if (self.currentTask) {
//        if (!_timer) {
//            _timer = [NSTimer timerWithTimeInterval:ONE_SECOND
//                                            target:self
//                                          selector:@selector(addOneSecondToCurrentTask)
//                                          userInfo:nil
//                                            repeats:YES];
//            NSRunLoop *runner = [NSRunLoop currentRunLoop];
//            [runner addTimer:_timer forMode:NSDefaultRunLoopMode];
//        }
//    }
//}
//
//- (void)pause {
//    [self stop];
//}
//
//- (void)resume {
//    [self stop];
//    [self start];
//}
//
//- (void)stop {
//    if (_timer) {
//        [_timer invalidate];
//    }
//    _timer = nil;
//}
//
//- (void)addOneSecondToCurrentTask {
//    self.currentTask.duration = [self.currentTask.duration decimalNumberByAdding:[NSDecimalNumber one]];
//    [[NSNotificationCenter defaultCenter] postNotificationName:BBNotificationTaskTimerUpdate object:nil];
//}








- (void)incrementDuration:(NSTimer*)timer
{
    if (self.timerActive) {
        
        CFAbsoluteTime currentStamp = CFAbsoluteTimeGetCurrent();
        
        NSDecimalNumber *elapsedTime = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%2.8f",currentStamp-self.startStamp]];
        
        NSDecimalNumber *duration = self.startDuration;
        duration = [duration decimalNumberByAdding:elapsedTime withBehavior:self.handler];
        
        self.currentTask.duration = duration;
        
        if (elapsedTime.integerValue % 60 == 0) {
            [[self.currentTask managedObjectContext] save:nil];
            
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kTimerUpdatedNotification
                                                            object:self.currentTask
                                                          userInfo:nil];
        
    } else {
        [timer invalidate];
        timer = nil;
    }
}

- (BOOL)active
{
    return self.timerActive;
}

- (id)currentSender
{
    return self.sender;
}

- (void)hideBadge
{
    
}

- (void)showBadge
{
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.currentTask) {
        // Task duration changed externally
        self.timerActive = NO;
    }
}

- (void)startWithTask:(Task *)task sender:(id)sender
{
    
    if (self.currentTask != nil) {
        [self stop];
    }
    
    [self showBadge];
    
    self.currentTask = task;
    self.sender = sender;
    self.timerActive = YES;
    self.startStamp = CFAbsoluteTimeGetCurrent();
    self.startDuration = self.currentTask.duration;
    
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kTimerUpdateInterval target:self selector:@selector(incrementDuration:) userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTimerActivatedNotification
                                                        object:self.currentTask
                                                      userInfo:nil];
}

- (void)resume
{
    [self.remindTimer invalidate];
    
    self.timerActive = YES;
    self.startStamp = CFAbsoluteTimeGetCurrent();
    self.startDuration = self.currentTask.duration;
    
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kTimerUpdateInterval target:self selector:@selector(incrementDuration:) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTimerResumedNotification
                                                        object:self.currentTask
                                                      userInfo:nil];
}

- (void)remindNotification
{
//    //Initalize new notification
//    NSUserNotification *notification = [[NSUserNotification alloc] init];
//    //Set the title of the notification
//    [notification setTitle:@"Timer On Pause"];
//    
//    //Set the text of the notification
//    [notification setInformativeText:@"Your timer has been on pause for a few minutes."];
//    //Set the time and date on which the nofication will be deliverd (for example 20 secons later than the current date and time)
//    [notification setDeliveryDate:[NSDate dateWithTimeInterval:0 sinceDate:[NSDate date]]];
//    //Set the sound, this can be either nil for no sound, NSUserNotificationDefaultSoundName for the default sound (tri-tone) and a string of a .caf file that is in the bundle (filname and extension)
//    [notification setSoundName:NSUserNotificationDefaultSoundName];
//    
//    //Get the default notification center
//    NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
//    //Scheldule our NSUserNotification
//    [center scheduleNotification:notification];
}

- (void)pause
{
    self.remindTimer = [NSTimer scheduledTimerWithTimeInterval:10*60 target:self selector:@selector(remindNotification) userInfo:nil repeats:NO];
    
    [self.refreshTimer invalidate];
    self.timerActive = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTimerPausedNotification
                                                        object:self.currentTask
                                                      userInfo:nil];
}

- (void)stop
{
    self.timerActive = NO;

    [self hideBadge];
    
    [self.remindTimer invalidate];
    [self.refreshTimer invalidate];
    
    CFAbsoluteTime currentStamp = CFAbsoluteTimeGetCurrent();
    NSDecimalNumber *elapsedTime = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%2.8f",currentStamp-self.startStamp]];
    
    NSDecimalNumber *duration = self.startDuration;
    if (self.timerActive) {
        duration = [duration decimalNumberByAdding:elapsedTime withBehavior:[NSDecimalNumber timeRoundingHandler]];
    } else {
        duration = self.currentTask.duration;
    }
    
    NSDecimalNumber *dec60 = [NSDecimalNumber decimalNumberWithString:@"60"];
    NSDecimalNumber *rounding = [[[GlobalAttributes timerRoundingTypes] objectAtIndex:[self.currentTask.matter.roundingType intValue]] decimalNumberByMultiplyingBy:dec60 withBehavior:[NSDecimalNumber timeFractionRoundingHandler]];
    
    int roundedTime = rounding.doubleValue * ceil([duration doubleValue]/rounding.doubleValue);
    self.currentTask.duration = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",roundedTime]];
    self.startStamp = 0;
    self.startDuration = nil;
    
    [self.currentTask.managedObjectContext save:nil];

    Task *task = self.currentTask;
    self.currentTask = nil;
    self.sender = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTimerDeactivatedNotification
                                                        object:task
                                                      userInfo:nil];
    
}


@end
