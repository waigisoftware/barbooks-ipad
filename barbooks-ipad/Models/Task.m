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
        newTask.date = [NSDate date];
        newTask.taxed = [NSNumber numberWithBool:YES];
        newTask.matter = matter;
        [matter addTasksObject:newTask];
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [localContext save:nil];
        } completion:^(BOOL success, NSError *error) {
            NSLog(@"%@", error);
        }];
        return newTask;
    } else {
        return nil;
    }
}

@end
