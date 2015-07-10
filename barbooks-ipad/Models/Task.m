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
        if (matter.rates.count > 0) {
            newTask.selectedRate = [[matter.rates allObjects] objectAtIndex:0];
        }
        newTask.matter = matter;
        [matter addTasksObject:newTask];
        return newTask;
    } else {
        return nil;
    }
}

#pragma mark - calculations

- (void)recalculate {
    [self recalculateFees];
    [self recalculateTotals];
    // save after recaculation
//    [self saveTask];
}

- (void)recalculateFees {
    self.feesExGst = self.selectedRate.amount;
    self.feesIncGst = self.selectedRate.amountGst;
    self.feesGst = [self.feesIncGst decimalNumberBySubtracting:self.feesExGst];
}

- (void)recalculateTotals {
    NSDecimalNumberHandler *roundPlain = [NSDecimalNumberHandler
                                       decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                       scale:0
                                       raiseOnExactness:NO
                                       raiseOnOverflow:NO
                                       raiseOnUnderflow:NO
                                       raiseOnDivideByZero:YES];
    if ([self hourlyRate]) {
        NSDecimalNumber *hours = [self.matter hoursFromDuration:self.duration];
        self.totalFeesExGst = [self.feesExGst decimalNumberByMultiplyingBy:hours withBehavior:roundPlain];
        self.totalFeesIncGst = [self.feesIncGst decimalNumberByMultiplyingBy:hours withBehavior:roundPlain];
        self.totalFeesGst = [self.feesGst decimalNumberByMultiplyingBy:hours withBehavior:roundPlain];
    } else {
        self.totalFeesExGst = [self.feesExGst decimalNumberByMultiplyingBy:self.units withBehavior:roundPlain];
        self.totalFeesIncGst = [self.feesIncGst decimalNumberByMultiplyingBy:self.units withBehavior:roundPlain];
        self.totalFeesGst = [self.feesGst decimalNumberByMultiplyingBy:self.units withBehavior:roundPlain];
    }
}

#pragma mark - convenient methods

- (BOOL)hourlyRate {
    return [self.selectedRate.type intValue] == 0 ? YES : NO;
}

- (BOOL)isTaxed {
    return [self.taxed boolValue];
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

#pragma mark - Core Data

- (void)saveTask {
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [localContext save:nil];
    } completion:^(BOOL success, NSError *error) {
        NSLog(@"%@", error);
    }];
}

@end
