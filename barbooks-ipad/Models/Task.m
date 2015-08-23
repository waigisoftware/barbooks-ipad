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
@dynamic hours;
@dynamic minutes;
@dynamic name;
@dynamic selectedRateIndex;
@dynamic taxed;
@dynamic totalFeesExGst;
@dynamic totalFeesGst;
@dynamic totalFeesIncGst;
@dynamic units;
@dynamic discount;
@dynamic invoice;
@dynamic matter;
@dynamic rate;

+ (instancetype)newInstanceOfMatter:(Matter *)matter {
    if (matter) {
        Task *newTask = [Task MR_createEntity];
        // set default values
        newTask.createdAt = [NSDate date];
        newTask.archived = [NSNumber numberWithBool:NO];
        newTask.date = [NSDate date];
        newTask.duration = [NSDecimalNumber zero];
        newTask.hours = [NSDecimalNumber zero];
        newTask.minutes = [NSDecimalNumber zero];
        newTask.taxed = [NSNumber numberWithBool:YES];
        if (matter.rates.count > 0) {
            newTask.selectedRateIndex = 0;
        }
        newTask.rate = [Rate MR_createEntity];
        newTask.matter = matter;
        [matter addTasksObject:newTask];
        return newTask;
    } else {
        return nil;
    }
}

#pragma mark - calculations

- (void)recalculate {
//    [self recalculateFees];
    [self recalculateTotals];
}

- (void)recalculateTotals {
//    NSDecimalNumberHandler *roundPlain = [NSDecimalNumberHandler
//                                       decimalNumberHandlerWithRoundingMode:NSRoundPlain
//                                       scale:0
//                                       raiseOnExactness:NO
//                                       raiseOnOverflow:NO
//                                       raiseOnUnderflow:NO
//                                       raiseOnDivideByZero:YES];
    switch (self.rate.rateChargingType) {
        case BBRateChargingTypeHourly:
        {
            NSDecimalNumber *hours = [self.matter hoursFromDuration:self.duration];
            self.totalFeesExGst = [self.rate.amount decimalNumberByMultiplyingBy:hours withBehavior:[NSDecimalNumber accurateRoundingHandler]];
            self.totalFeesIncGst = [self.rate.amountGst decimalNumberByMultiplyingBy:hours withBehavior:[NSDecimalNumber accurateRoundingHandler]];
            self.totalFeesGst = [self.totalFeesIncGst decimalNumberBySubtracting:self.totalFeesExGst];
            break;
        }
        case BBRateChargingTypeUnit:
        {
            self.totalFeesExGst = [self.rate.amount decimalNumberByMultiplyingBy:self.units withBehavior:[NSDecimalNumber accurateRoundingHandler]];
            self.totalFeesIncGst = [self.rate.amountGst decimalNumberByMultiplyingBy:self.units withBehavior:[NSDecimalNumber accurateRoundingHandler]];
            self.totalFeesGst = [self.totalFeesIncGst decimalNumberBySubtracting:self.totalFeesExGst];
        }
        case BBRateChargingTypeFixed:
        {
            self.totalFeesExGst = self.rate.amount;
            self.totalFeesIncGst = self.rate.amountGst;
            self.totalFeesGst = [self.totalFeesIncGst decimalNumberBySubtracting:self.totalFeesExGst];
        }
    }
}

#pragma mark - convenient methods

- (BOOL)hourlyRate {
    return self.rate.rateChargingType == BBRateChargingTypeHourly ? YES : NO;
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

- (NSDecimalNumber *)unbilledAmount {
    //TODO:calculate. return amount for now
    return [self isTaxed] ? self.totalFeesIncGst : self.totalFeesExGst;
}

#pragma mark - Core Data

- (void)saveTask {
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [localContext save:nil];
    } completion:^(BOOL success, NSError *error) {
        NSLog(@"%@", error);
    }];
}

+ (NSArray *)allUnlinkedObjectsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSPredicate *fetchpredicate = [NSPredicate predicateWithFormat:@"matter == nil"];
    
    NSArray *tasks = [Task MR_findAllWithPredicate:fetchpredicate inContext:managedObjectContext];
    
    return tasks;
}

@end
