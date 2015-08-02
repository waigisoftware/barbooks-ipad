//
//  Matter.m
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "Matter.h"
#import "Account.h"
#import "CostsAgreement.h"
#import "Disbursement.h"
#import "Invoice.h"
#import "OutstandingFees.h"
#import "Rate.h"
#import "Solicitor.h"
#import "Task.h"
#import "VariationOfFees.h"
#import "BBCoreDataManager.h"


@implementation Matter

@dynamic amountOutstandingInvoices;
@dynamic amountUnbilledTasks;
@dynamic courtName;
@dynamic date;
@dynamic dueDate;
@dynamic endClientName;
@dynamic invoicesOverdue;
@dynamic name;
@dynamic natureOfBrief;
@dynamic payor;
@dynamic reference;
@dynamic registry;
@dynamic roundingType;
@dynamic tax;
@dynamic taxed;
@dynamic account;
@dynamic costsAgreement;
@dynamic disbursements;
@dynamic invoices;
@dynamic outstandingFees;
@dynamic rates;
@dynamic solicitor;
@dynamic tasks;
@dynamic variationOfFees;

+ (instancetype)newInstanceInManagedObjectContext:(NSManagedObjectContext*)context {
    id object = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
    return object;
}

+ (instancetype)newInstanceInDefaultManagedObjectContext {
    id object = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:[[BBCoreDataManager sharedInstance] managedObjectContext]];
    return object;
}

+ (instancetype)newInstanceWithDefaultValue {
    Matter *newMatter = [Matter MR_createEntity];
    newMatter.date = [NSDate date];
    newMatter.taxed = [NSNumber numberWithBool:YES];
    newMatter.tax = [NSDecimalNumber decimalNumberWithString:@"0.1"];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [localContext save:nil];
    } completion:^(BOOL success, NSError *error) {
        NSLog(@"%@", error);
    }];
    return newMatter;
}

+ (NSString*)entityName {
    return NSStringFromClass(self);
}

#pragma mark - calculation

// calculate how many hours to be charged after rounding, e.g. 3000s -> 0.83h
- (NSDecimalNumber *)hoursFromDuration:(NSDecimalNumber *)duration {
    NSDecimalNumber *hours;
    NSDecimalNumber *unit;
    NSDecimalNumber *numberOfUnit;
    NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler
                                       decimalNumberHandlerWithRoundingMode:NSRoundUp
                                       scale:0
                                       raiseOnExactness:NO
                                       raiseOnOverflow:NO
                                       raiseOnUnderflow:NO
                                       raiseOnDivideByZero:YES];

    switch ([self.roundingType intValue]) {
        case 0:
            unit = [NSDecimalNumber decimalNumberWithString:@"360"];
            numberOfUnit = [duration decimalNumberByDividingBy:unit withBehavior:roundUp];
            hours = [numberOfUnit decimalNumberByMultiplyingBy:[unit decimalNumberByDividingBy:[NSDecimalNumber anHourSeconds]]];
            break;
        case 1:
            unit = [NSDecimalNumber decimalNumberWithString:@"600"];
            break;
        case 2:
            unit = [NSDecimalNumber decimalNumberWithString:@"900"];
            break;
        case 3:
            unit = [NSDecimalNumber decimalNumberWithString:@"1200"];
            break;
    }
    numberOfUnit = [duration decimalNumberByDividingBy:unit withBehavior:roundUp];
    hours = [numberOfUnit decimalNumberByMultiplyingBy:[unit decimalNumberByDividingBy:[NSDecimalNumber anHourSeconds]]];

    return hours;
}

#pragma mark - convenient methods

- (NSDecimalNumber *)totalTasksUnbilled {
    NSDecimalNumber *totalAmount = [NSDecimalNumber zero];
    for (Task *task in self.tasks) {
        totalAmount = [totalAmount decimalNumberByAdding:[task unbilledAmount]];
    }
    return totalAmount;
}

- (NSDecimalNumber *)totalInvoicesOutstanding {
    NSDecimalNumber *totalAmount = [NSDecimalNumber zero];
    //TODO: calculate
    return totalAmount;
}

#pragma mark - Core Data

+ (NSArray *)allMatters {
    return [Matter MR_findAll];
}

+ (NSArray *)unarchivedMatters {
    return [Matter MR_findAll];
}

+ (NSArray *)archivedMatters {
    return [Matter MR_findAll];
}

@end
