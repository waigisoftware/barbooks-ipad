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
        newTask.rate = [Rate MR_createEntity];
        if (matter.rates.count > 0) {
            Rate *rate = [matter.ratesArray objectAtIndex:0];
            [rate copyValueToRate:newTask.rate];
        }
        newTask.matter = matter;
        [matter addTasksObject:newTask];
        [newTask.managedObjectContext MR_saveToPersistentStoreAndWait];
        return newTask;
    } else {
        return nil;
    }
}

#pragma mark - calculations

- (void)recalculate {
    [self recalculateTotals];
}

- (void)recalculateTotals {
    switch (self.rate.rateChargingType) {
        case BBRateChargingTypeHourly:
        {
            NSDecimalNumber *hours = [self.matter hoursFromDuration:self.duration];
            self.totalFeesExGst = [self.rate.amount decimalNumberByAccuratelyMultiplyingBy:hours];
            self.totalFeesIncGst = [self.rate.amountGst decimalNumberByAccuratelyMultiplyingBy:hours];
            self.totalFeesGst = [self.totalFeesIncGst decimalNumberByAccuratelySubtracting:self.totalFeesExGst];
            break;
        }
        case BBRateChargingTypeUnit:
        {
            self.totalFeesExGst = [self.rate.amount decimalNumberByAccuratelyMultiplyingBy:self.units];
            self.totalFeesIncGst = [self.rate.amountGst decimalNumberByAccuratelyMultiplyingBy:self.units];
            self.totalFeesGst = [self.totalFeesIncGst decimalNumberByAccuratelySubtracting:self.totalFeesExGst];
        }
        case BBRateChargingTypeFixed:
        {
            self.totalFeesExGst = self.rate.amount;
            self.totalFeesIncGst = self.rate.amountGst;
            self.totalFeesGst = [self.totalFeesIncGst decimalNumberByAccuratelySubtracting:self.totalFeesExGst];
        }
    }
}

- (NSDecimalNumber *)totalFeesIncGst
{
    if (!self.discount || (self.discount && self.discount.value == nil)) {
        return self.feesIncGst;
    }
    
    return [self.feesIncGst decimalNumberBySubtracting:[self.discount discountedAmountForTotal:self.feesIncGst] withBehavior:[NSDecimalNumber accurateRoundingHandler]];
}

+ (NSSet *)keyPathsForValuesAffectingTotalFeesIncGst
{
    return [NSSet setWithObjects:@"rate.name", @"duration", @"units", @"discount", @"discount.type", @"discount.value", nil];;
}

+ (NSSet *)keyPathsForValuesAffectingTotalFeesExGst
{
    return [NSSet setWithObjects:@"rate.name", @"duration", @"units", @"discount", @"discount.type", @"discount.value", nil];;
}

+ (NSSet *)keyPathsForValuesAffectingTotalFeesGst
{
    return [NSSet setWithObjects:@"rate.name", @"duration", @"units", @"discount", @"discount.type", @"discount.value", nil];;
}

- (NSDecimalNumber*)discountGstRate
{
    NSDecimalNumber *discountTotal = [self.discount discountedAmountForTotal:self.feesIncGst];
    NSDecimalNumberHandler *currencyHandler = [NSDecimalNumber accurateRoundingHandler];
    
    NSDecimalNumber *discountGstAmount = [NSDecimalNumber zero];
    if (![self.matter.tax isEqualToNumber:[NSDecimalNumber notANumber]] && [self.matter.tax compare:[NSDecimalNumber zero]] == NSOrderedDescending) {
        
        NSDecimalNumber *dec10 = [NSDecimalNumber decimalNumberWithString:@"10"];
        NSDecimalNumber *taxFactor = [self.matter.tax decimalNumberByDividingBy:dec10 withBehavior:currencyHandler];
        taxFactor = [taxFactor decimalNumberByAdding:dec10 withBehavior:currencyHandler];
        
        discountGstAmount = [discountTotal decimalNumberByDividingBy:taxFactor];
    }
    
    return discountGstAmount;
}

- (NSDecimalNumber *)totalFeesExGst
{
    if (!self.discount || (self.discount && self.discount.value == nil)) {
        return self.feesExGst;
    }
    
    NSDecimalNumber *discountExGst = [[self.discount discountedAmountForTotal:self.feesIncGst] decimalNumberBySubtracting:[self discountGstRate] withBehavior:[NSDecimalNumber accurateRoundingHandler]];
    
    return [self.feesExGst decimalNumberBySubtracting:discountExGst withBehavior:[NSDecimalNumber accurateRoundingHandler]];
}


- (NSDecimalNumber *)totalFeesGst
{
    if (!self.discount || (self.discount && self.discount.value == nil)) {
        return self.feesGst;
    }
    
    return [self.feesGst decimalNumberBySubtracting:[self discountGstRate] withBehavior:[NSDecimalNumber accurateRoundingHandler]];
}

- (NSDecimalNumber *)feesExGst
{
    [self willAccessValueForKey:@"feesExGst"];
    NSDecimalNumber *amount = [self primitiveValueForKey:@"feesExGst"];
    [self didAccessValueForKey:@"feesExGst"];
    
    if (self.importedObject.boolValue && self.invoice != nil && amount && amount.intValue != 0 && ![amount isEqualToNumber:[NSDecimalNumber notANumber]]) {
        return amount;
    }
    
    NSDecimalNumber * fees = nil;
    
    
    Rate *rate = self.rate;
    if (!rate) {
        return [NSDecimalNumber zero];
    }
    
    int selectedType = rate.rateType.intValue;
    
    if (selectedType == 0) {
        
        NSDecimalNumber *division = [NSDecimalNumber decimalNumberWithString:@"60"];
        NSDecimalNumber *hourFee = [rate.amount decimalNumberByMultiplyingBy:self.hours withBehavior:[NSDecimalNumber accurateRoundingHandler]];
        if (self.minutes.intValue > 0) {
            NSDecimalNumber *minFactor = [self.minutes decimalNumberByDividingBy:division withBehavior:[NSDecimalNumber timeFractionRoundingHandler]];
            NSDecimalNumber *minFee = [rate.amount decimalNumberByMultiplyingBy:minFactor withBehavior:[NSDecimalNumber accurateRoundingHandler]];
            
            fees = [hourFee decimalNumberByAdding:minFee withBehavior:[NSDecimalNumber accurateRoundingHandler]];
        } else {
            fees = hourFee;
        }
    } else if(selectedType == 1) {
        
        fees = [rate.amount decimalNumberByMultiplyingBy:self.units withBehavior:[NSDecimalNumber accurateRoundingHandler]];
    } else {
        fees = rate.amount;
    }
    
    return fees;
    
}

- (NSDecimalNumber *)feesIncGst
{
    if (!self.taxed.boolValue) {
        return self.feesExGst;
    }
    
    NSDecimalNumber *exGst = [self.feesExGst decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber currencyRoundingHandler]];
    NSDecimalNumber *gst = [self.feesGst decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber currencyRoundingHandler]];
    if (gst == nil || [gst isEqualToNumber:[NSDecimalNumber notANumber]]) gst = [NSDecimalNumber zero];
    if (exGst == nil || [exGst isEqualToNumber:[NSDecimalNumber notANumber]]) exGst = [NSDecimalNumber zero];
    
    return [exGst decimalNumberByAdding:gst withBehavior:[NSDecimalNumber accurateRoundingHandler]];
}

- (NSDecimalNumber *)feesGst
{
    if (!self.taxed.boolValue) {
        return [NSDecimalNumber zero];
    }
    
    [self willAccessValueForKey:@"feesGst"];
    NSDecimalNumber *amount = [self primitiveValueForKey:@"feesGst"];
    [self didAccessValueForKey:@"feesGst"];
    
    if (self.importedObject.boolValue && self.invoice != nil && amount && amount.intValue != 0 && ![amount isEqualToNumber:[NSDecimalNumber notANumber]]) {
        return amount;
    }
    
    
    NSDecimalNumber * fees = nil;
    
    Rate *rate = self.rate;
    if (!rate) {
        return [NSDecimalNumber zero];
    }
    
    int selectedType = rate.rateType.intValue;
    
    if (selectedType == 0) {
        
        NSDecimalNumber *division = [NSDecimalNumber decimalNumberWithString:@"60"];
        NSDecimalNumber *hourFee = [rate.amountGst decimalNumberByMultiplyingBy:self.hours withBehavior:[NSDecimalNumber accurateRoundingHandler]];
        if (self.minutes.intValue > 0) {
            NSDecimalNumber *minFactor = [self.minutes decimalNumberByDividingBy:division withBehavior:[NSDecimalNumber timeFractionRoundingHandler]];
            NSDecimalNumber *minFee = [rate.amountGst decimalNumberByMultiplyingBy:minFactor withBehavior:[NSDecimalNumber accurateRoundingHandler]];
            
            fees = [hourFee decimalNumberByAdding:minFee withBehavior:[NSDecimalNumber accurateRoundingHandler]];
        } else {
            fees = hourFee;
        }
        
    } else if(selectedType == 1) {
        fees = [rate.amountGst decimalNumberByMultiplyingBy:self.units withBehavior:[NSDecimalNumber accurateRoundingHandler]];
        
    } else {
        fees = rate.amountGst;
    }
    
    
    return [fees decimalNumberBySubtracting:self.feesExGst withBehavior:[NSDecimalNumber accurateRoundingHandler]];
}




#pragma mark - convenient methods

- (BOOL)hourlyRate {
    return self.rate.rateChargingType == BBRateChargingTypeHourly ? YES : NO;
}

- (BOOL)isTaxed {
    return [self.taxed boolValue];
}


- (void)setHours:(NSDecimalNumber *)hours
{
    NSDecimalNumber *minutesToSeconds = [self.minutes decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"60"] withBehavior:[NSDecimalNumber timeRoundingHandler]];
    NSDecimalNumber *hoursToSeconds = [hours decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"3600"] withBehavior:[NSDecimalNumber timeRoundingHandler]];
    
    self.duration = [minutesToSeconds decimalNumberByAdding:hoursToSeconds withBehavior:[NSDecimalNumber timeRoundingHandler]];
}

- (void)setMinutes:(NSDecimalNumber *)minutes
{
    NSDecimalNumber *minutesToSeconds = [minutes decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"60"] withBehavior:[NSDecimalNumber timeRoundingHandler]];
    NSDecimalNumber *hoursToSeconds = [self.hours decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"3600"] withBehavior:[NSDecimalNumber timeRoundingHandler]];
    
    self.duration = [minutesToSeconds decimalNumberByAdding:hoursToSeconds withBehavior:[NSDecimalNumber timeRoundingHandler]];
}

- (NSDecimalNumber *)hours
{
    return [self.duration decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"3600"] withBehavior:[NSDecimalNumber timeRoundingHandler]];
}

- (NSDecimalNumber *)minutes
{
    int minutes = self.duration.integerValue / 60 % 60;
    
    NSString *string = [NSString stringWithFormat:@"%i",minutes];
    
    
    return [[NSDecimalNumber decimalNumberWithString:string] decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber timeRoundingHandler]];
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

/*
- (NSDecimalNumber *)totalFeesIncGst
{
    if (!self.discount || (self.discount && self.discount.value == nil)) {
        return self.feesIncGst;
    }
    NSLog(@"Discount %@ ---- %@",[self.discount discountedAmountForTotal:self.feesIncGst], self.discount);
    NSLog(@"Bla %@",self.feesIncGst);
    return [self.feesIncGst decimalNumberByAccuratelySubtracting:[self.discount discountedAmountForTotal:self.feesIncGst]];
}

- (NSDecimalNumber*)discountGstRate
{
    NSDecimalNumber *discountTotal = [self.discount discountedAmountForTotal:self.feesIncGst];
    
    NSDecimalNumber *discountGstAmount = [NSDecimalNumber zero];
    if (![self.matter.tax isEqualToNumber:[NSDecimalNumber notANumber]] && [self.matter.tax compare:[NSDecimalNumber zero]] == NSOrderedDescending) {
        NSDecimalNumber *taxFactor = [self.matter.tax decimalNumberByAccuratelyDividingBy:[NSDecimalNumber ten]];
        taxFactor = [taxFactor decimalNumberByAccuratelyAdding:[NSDecimalNumber ten]];
        
        discountGstAmount = [discountTotal decimalNumberByAccuratelyDividingBy:taxFactor];
    }
    
    return discountGstAmount;
}

- (NSDecimalNumber *)totalFeesExGst
{
    if (!self.discount || (self.discount && self.discount.value == nil)) {
        return self.feesExGst;
    }
    
    NSDecimalNumber *discountExGst = [[self.discount discountedAmountForTotal:self.feesIncGst] decimalNumberByAccuratelySubtracting:[self discountGstRate]];
    
    return [self.feesExGst decimalNumberByAccuratelySubtracting:discountExGst];
}

- (NSDecimalNumber *)totalFeesGst
{
    if (!self.discount || (self.discount && self.discount.value == nil)) {
        return self.feesGst;
    }
    
    return [self.feesGst decimalNumberByAccuratelySubtracting:[self discountGstRate]];
}

- (NSDecimalNumber *)feesExGst
{
    [self willAccessValueForKey:@"feesExGst"];
    NSDecimalNumber *amount = [self primitiveValueForKey:@"feesExGst"];
    [self didAccessValueForKey:@"feesExGst"];
    
    if (self.importedObject.boolValue && self.invoice != nil && amount && amount.intValue != 0 && ![amount isEqualToNumber:[NSDecimalNumber notANumber]]) {
        return amount;
    }
    
    NSDecimalNumber * fees = nil;
    
    
    Rate *rate = self.rate;
    if (!rate) {
        return [NSDecimalNumber zero];
    }
    
    int selectedType = rate.type.intValue;
    
    if (selectedType == 0) {
        
        NSDecimalNumber *division = [NSDecimalNumber decimalNumberWithString:@"60"];
        NSDecimalNumber *hourFee = [rate.amount decimalNumberByMultiplyingBy:self.hours withBehavior:[BBManagedObject accurateRoundingHandler]];
        if (self.minutes.intValue > 0) {
            NSDecimalNumber *minFactor = [self.minutes decimalNumberByDividingBy:division withBehavior:[BBManagedObject timeFractionRoundingHandler]];
            NSDecimalNumber *minFee = [rate.amount decimalNumberByMultiplyingBy:minFactor withBehavior:[BBManagedObject accurateRoundingHandler]];
            
            fees = [hourFee decimalNumberByAdding:minFee withBehavior:[BBManagedObject accurateRoundingHandler]];
        } else {
            fees = hourFee;
        }
    } else if(selectedType == 1) {
        
        fees = [rate.amount decimalNumberByMultiplyingBy:self.units withBehavior:[BBManagedObject accurateRoundingHandler]];
    } else {
        fees = rate.amount;
    }
    
    return fees;
    
}

- (NSDecimalNumber *)feesIncGst
{
    if (!self.taxed.boolValue) {
        return self.feesExGst;
    }
    
    NSDecimalNumber *exGst = [self.feesExGst decimalNumberByRoundingAccordingToBehavior:[BBManagedObject currencyRoundingHandler]];
    NSDecimalNumber *gst = [self.feesGst decimalNumberByRoundingAccordingToBehavior:[BBManagedObject currencyRoundingHandler]];
    
    return [exGst decimalNumberByAdding:gst withBehavior:[BBManagedObject accurateRoundingHandler]];
}

- (NSDecimalNumber *)feesGst
{
    if (!self.taxed.boolValue) {
        return [NSDecimalNumber zero];
    }
    
    [self willAccessValueForKey:@"feesGst"];
    NSDecimalNumber *amount = [self primitiveValueForKey:@"feesGst"];
    [self didAccessValueForKey:@"feesGst"];
    
    if (self.importedObject.boolValue && self.invoice != nil && amount && amount.intValue != 0 && ![amount isEqualToNumber:[NSDecimalNumber notANumber]]) {
        return amount;
    }
    
    
    NSDecimalNumber * fees = nil;
    
    Rate *rate = self.rate;
    if (!rate) {
        return [NSDecimalNumber zero];
    }
    
    int selectedType = rate.rateType.intValue;
    
    if (selectedType == 0) {
        
        NSDecimalNumber *division = [NSDecimalNumber decimalNumberWithString:@"60"];
        NSDecimalNumber *hourFee = [rate.amountGst decimalNumberByMultiplyingBy:self.hours withBehavior:[BBManagedObject accurateRoundingHandler]];
        if (self.minutes.intValue > 0) {
            NSDecimalNumber *minFactor = [self.minutes decimalNumberByDividingBy:division withBehavior:[BBManagedObject timeFractionRoundingHandler]];
            NSDecimalNumber *minFee = [rate.amountGst decimalNumberByMultiplyingBy:minFactor withBehavior:[BBManagedObject accurateRoundingHandler]];
            
            fees = [hourFee decimalNumberByAdding:minFee withBehavior:[BBManagedObject accurateRoundingHandler]];
        } else {
            fees = hourFee;
        }
    } else if(selectedType == 1) {
        fees = [rate.amountGst decimalNumberByMultiplyingBy:self.units withBehavior:[BBManagedObject accurateRoundingHandler]];
        
    } else {
        fees = rate.amountGst;
    }
    
    
    return [fees decimalNumberBySubtracting:self.feesExGst withBehavior:[BBManagedObject accurateRoundingHandler]];
}
*/

#pragma mark Discounts

- (NSDecimalNumber*)discountGst
{
    NSDecimalNumber *discountTotal = [self.discount discountedAmountForTotal:self.feesIncGst];
    
    NSDecimalNumber *discountGstAmount = [NSDecimalNumber zero];
    if (![self.matter.tax isEqualToNumber:[NSDecimalNumber notANumber]] && [self.matter.tax compare:[NSDecimalNumber zero]] == NSOrderedDescending) {
        
        NSDecimalNumber *taxFactor = [self.matter.tax decimalNumberByAccuratelyDividingBy:[NSDecimalNumber ten]];
        taxFactor = [taxFactor decimalNumberByAccuratelyAdding:[NSDecimalNumber ten]];
        
        discountGstAmount = [discountTotal decimalNumberByAccuratelyDividingBy:taxFactor];
    }
    
    return discountGstAmount;
}

- (NSDecimalNumber *)discountExGst
{
    if (!self.discount || (self.discount && self.discount.value == nil)) {
        return [NSDecimalNumber zero];
    }
    
    NSDecimalNumber *discountExGst = [[self.discount discountedAmountForTotal:self.feesIncGst] decimalNumberByAccuratelySubtracting:[self discountGst]];
    
    return discountExGst;
}

- (NSDecimalNumber *)discountIncGst
{
    if (!self.discount || (self.discount && self.discount.value == nil)) {
        return [NSDecimalNumber zero];
    }
    
    return [self.discountExGst decimalNumberByAccuratelyAdding:self.discountGst];
}

@end
