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
@dynamic costsAgreementDate;
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
//    id object = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:[[BBCoreDataManager sharedInstance] managedObjectContext]];
    Matter *newMatter = [Matter MR_createEntityInContext:[[BBCoreDataManager sharedInstance] managedObjectContext]];
    newMatter.createdAt = [NSDate date];
    newMatter.archived = [NSNumber numberWithBool:NO];
    newMatter.date = [NSDate date];
    newMatter.taxed = [NSNumber numberWithBool:YES];
    newMatter.tax = [NSDecimalNumber decimalNumberWithString:@"0.1"];
    newMatter.costsAgreementDate = [NSDate date];
    return newMatter;
}


+ (NSString*)entityName {
    return NSStringFromClass(self);
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    self.archived = [NSNumber numberWithBool:NO];
    self.createdAt = [NSDate date];
    self.date = [NSDate date];
    self.costsAgreementDate = [NSDate date];
    self.taxed = [NSNumber numberWithBool:YES];
}

#pragma mark - calculation

// calculate how many hours to be charged after rounding, e.g. 3000s -> 0.83h
- (NSDecimalNumber *)hoursFromDuration:(NSDecimalNumber *)duration {
    NSDecimalNumber *hours;
    NSDecimalNumber *unit;
    NSDecimalNumber *numberOfUnit;

    switch ([self.roundingType intValue]) {
        case 0:
            unit = [NSDecimalNumber decimalNumberWithString:@"360"];
            numberOfUnit = [duration decimalNumberByDividingBy:unit withBehavior:[NSDecimalNumber timeFractionRoundingHandler]];
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
    numberOfUnit = [duration decimalNumberByDividingBy:unit withBehavior:[NSDecimalNumber timeFractionRoundingHandler]];
    hours = [numberOfUnit decimalNumberByMultiplyingBy:[unit decimalNumberByDividingBy:[NSDecimalNumber anHourSeconds]]];

    return hours;
}

#pragma mark - convenient methods


- (NSDecimalNumber *)amountOutstandingInvoices
{
    if (!self.invoices.count) {
        return [NSDecimalNumber zero];
    }
    
    NSPredicate *outstandingPredicate = [NSPredicate predicateWithFormat:@"totalOutstanding > 0"];
    NSSet *outstandingInvoices = [self.invoices filteredSetUsingPredicate:outstandingPredicate];
    
    NSString *string = [NSString stringWithFormat:@"%.3f",[[outstandingInvoices valueForKeyPath:@"@sum.totalOutstanding"] doubleValue]];
    
    return [[NSDecimalNumber decimalNumberWithString:string] decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber accurateRoundingHandler]];
}


- (NSDecimalNumber *)amountUnbilledTasks
{
    if (!self.tasks.count) {
        return [NSDecimalNumber zero];
    }
    
    NSDecimalNumber *sum = [NSDecimalNumber zero];
    
    for (Task *task in self.tasks) {
        if (!task.invoice) {
            sum = [sum decimalNumberByAccuratelyAdding:task.totalFeesIncGst];
        }
    }

    return sum;
}

- (NSArray *)tasksArray {
    return [[self.tasks allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((Task *)obj2).createdAt compare:((Task *)obj1).createdAt];
    }];
    return [[self.tasks allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
}

- (NSArray *)ratesArray {
    return [self.rates allObjects];
}

- (NSArray *)invoicesArray {
    return [[self.invoices allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((Invoice *)obj2).entryNumber compare:((Invoice *)obj1).entryNumber];
    }];
}

- (NSArray *)disbursementsArray {
    return [self.disbursements allObjects];
}

#pragma mark - Core Data

+ (NSArray *)allMatters {
    return [Matter MR_findAllSortedBy:@"createdAt" ascending:NO];
}


+ (NSArray *)unarchivedMatters {
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"archived == %@", [NSNumber numberWithBool:NO]];
    return [Matter MR_findAllSortedBy:@"createdAt" ascending:NO withPredicate:filter];
}

+ (NSArray *)archivedMatters {
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"archived == %@", [NSNumber numberWithBool:YES]];
    return [Matter MR_findAllSortedBy:@"createdAt" ascending:NO withPredicate:filter];
}

+ (instancetype)firstMatter {
    return [[Matter unarchivedMatters] firstObject];
}

@end
