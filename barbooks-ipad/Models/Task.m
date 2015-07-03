//
//  Task.m
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "Task.h"
#import "Discount.h"
#import "Matter.h"
#import "Rate.h"
#import "RegularInvoice.h"
#import "NSDecimalNumber+BBUtil.h"


@implementation Task

@dynamic date;
@dynamic duration;
@dynamic feesExGst;
@dynamic feesGst;
@dynamic feesIncGst;
@dynamic hasTime;
@dynamic hasUnits;
@dynamic hours;
@dynamic isFixed;
@dynamic minutes;
@dynamic name;
@dynamic selectedRate;
@dynamic selectedRateIndex;
@dynamic taxed;
@dynamic totalFeesExGst;
@dynamic totalFeesGst;
@dynamic totalFeesIncGst;
@dynamic units;
@dynamic discount;
@dynamic invoice;
@dynamic matter;
@dynamic rates;

+ (instancetype)newInstanceOfMatter:(Matter *)matter {
    if (matter) {
        Task *newTask = [Task MR_createEntity];
        // set default values
        newTask.date = [NSDate date];
        newTask.duration = [NSDecimalNumber zero];
        newTask.hours = [NSDecimalNumber zero];
        newTask.minutes = [NSDecimalNumber zero];
        newTask.taxed = [NSNumber numberWithBool:YES];
        newTask.matter = matter;
        [matter addTasksObject:newTask];
//        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
//            [localContext save:nil];
//        } completion:^(BOOL success, NSError *error) {
//            NSLog(@"%@", error);
//        }];
        return newTask;
    } else {
        return nil;
    }
}

- (BOOL)hourlyRate {
    return [self.selectedRate.type intValue] == 0 ? YES : NO;
}

// generate duration displaying string
- (NSString *)durationToFormattedString {
    int totalSeconds = [self.duration intValue];
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, seconds];
}

// convert user input time string to durations
- (void)durationFromString:(NSString *)durationString {
    int totalSeconds = 0;
    int seconds = 0;
    int minutes = 0;
    int hours = 0;
    
    NSArray *durationComponents = [durationString componentsSeparatedByString:@":"];
    if (durationComponents.count > 0) {
        hours = [[NSString stringWithString:durationComponents[0]] intValue];
    }
    if (durationComponents.count > 1) {
        minutes = [[NSString stringWithString:durationComponents[1]] intValue];
    }
    if (durationComponents.count > 2) {
        seconds = [[NSString stringWithString:durationComponents[2]] intValue];
    }
    totalSeconds = hours * 3600 + minutes * 60 + seconds;
    
    self.duration = [NSDecimalNumber decimalNumberWithInt:totalSeconds];
    self.hours = [NSDecimalNumber decimalNumberWithInt:hours];
    self.minutes = [NSDecimalNumber decimalNumberWithInt:minutes];
}

@end
