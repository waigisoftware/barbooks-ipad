//
//  Task.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BBManagedObject.h"

@class Discount, Matter, Rate, RegularInvoice;

@interface Task : BBManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDecimalNumber * duration;
@property (nonatomic, retain) NSDecimalNumber * feesExGst;
@property (nonatomic, retain) NSDecimalNumber * feesGst;
@property (nonatomic, retain) NSDecimalNumber * feesIncGst;
@property (nonatomic, retain) NSNumber * hasTime;
@property (nonatomic, retain) NSNumber * hasUnits;
@property (nonatomic, retain) NSDecimalNumber * hours;
@property (nonatomic, retain) NSNumber * isFixed;
@property (nonatomic, retain) NSDecimalNumber * minutes;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Rate * selectedRate;
@property (nonatomic, retain) NSNumber * selectedRateIndex;
@property (nonatomic, retain) NSNumber * taxed;
@property (nonatomic, retain) NSDecimalNumber * totalFeesExGst;
@property (nonatomic, retain) NSDecimalNumber * totalFeesGst;
@property (nonatomic, retain) NSDecimalNumber * totalFeesIncGst;
@property (nonatomic, retain) NSDecimalNumber * units;
@property (nonatomic, retain) Discount *discount;
@property (nonatomic, retain) RegularInvoice *invoice;
@property (nonatomic, retain) Matter *matter;
@property (nonatomic, retain) NSSet *rates;
@end

@interface Task (CoreDataGeneratedAccessors)

- (void)addRatesObject:(Rate *)value;
- (void)removeRatesObject:(Rate *)value;
- (void)addRates:(NSSet *)values;
- (void)removeRates:(NSSet *)values;

+ (instancetype)newInstanceOfMatter:(Matter *)matter;

- (BOOL)hourlyRate;
- (BOOL)isTaxed;
- (NSString *)durationToFormattedString;
- (void)durationFromString:(NSString *)durationString;

// recalculate all amounts
- (void)recalculate;

//- (void)saveTask;

@end
