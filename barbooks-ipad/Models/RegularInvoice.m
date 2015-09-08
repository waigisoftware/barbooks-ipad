//
//  RegularInvoice.m
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "RegularInvoice.h"
#import "Disbursement.h"
#import "Task.h"


@implementation RegularInvoice

@dynamic disbursementsExGst;
@dynamic disbursementsGst;
@dynamic professionalFeeExGst;
@dynamic professionalFeeGst;
@dynamic disbursements;
@dynamic tasks;

- (NSDecimalNumber *)professionalFeesGst
{
    NSDecimalNumber * amount = [[self.tasks valueForKeyPath:@"@sum.totalFeesGst"] decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber accurateRoundingHandler]];
    
    return amount;
}

- (NSDecimalNumber *)professionalFeesExGst
{
    NSDecimalNumber * amount = [[self.tasks valueForKeyPath:@"@sum.totalFeesExGst"] decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber accurateRoundingHandler]];
    
    return amount;
}

- (NSDecimalNumber *)disbursementsExGst
{
    NSDecimalNumber * amount = [[self.disbursements valueForKeyPath:@"@sum.amountExGst"] decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber accurateRoundingHandler]];
    
    return amount;
}

- (NSDecimalNumber *)disbursementsGst
{
    NSDecimalNumber * amount = [[self.disbursements valueForKeyPath:@"@sum.amountGst"] decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber accurateRoundingHandler]];
    
    return amount;
}

+ (NSSet *)keyPathsForValuesAffectingProfessionalFeesGst
{
    return [NSSet setWithObjects:@"tasks", nil];
}

+ (NSSet *)keyPathsForValuesAffectingProfessionalFeesExGst
{
    return [NSSet setWithObjects:@"tasks", nil];
}

+ (NSSet *)keyPathsForValuesAffectingDisbursementsGst
{
    return [NSSet setWithObjects:@"disbursements", nil];
}

+ (NSSet *)keyPathsForValuesAffectingDisbursementsExGst
{
    return [NSSet setWithObjects:@"disbursements", nil];
}


#pragma mark - Invoice Totals

- (NSDecimalNumber *)amountExGst
{
    [self willAccessValueForKey:@"amountExGst"];
    NSDecimalNumber *amount = [self primitiveValueForKey:@"amountExGst"];
    [self didAccessValueForKey:@"amountExGst"];
    
    if (self.importedObject.boolValue && amount.intValue != 0) {
        return amount;
    }
    
    NSDecimalNumber * totalTaskExGst = [[self.tasks valueForKeyPath:@"@sum.totalFeesExGst"] decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber accurateRoundingHandler]];
    
    NSDecimalNumber * totalDisbursementExGst = [[self.disbursements valueForKeyPath:@"@sum.amountExGst"] decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber accurateRoundingHandler]];
    
    if ([totalTaskExGst isEqualToNumber:[NSDecimalNumber notANumber]]) {
        totalTaskExGst = [NSDecimalNumber zero];
    }
    
    if ([totalDisbursementExGst isEqualToNumber:[NSDecimalNumber notANumber]]) {
        totalDisbursementExGst = [NSDecimalNumber zero];
    }
    
    amount = [totalTaskExGst decimalNumberByAdding:totalDisbursementExGst withBehavior:[NSDecimalNumber accurateRoundingHandler]];
    
    return amount;
}

+ (NSSet *)keyPathsForValuesAffectingAmountExGst
{
    return [NSSet setWithObjects:@"tasks", @"disbursements", nil];
}

- (NSDecimalNumber *)amountGst
{
    [self willAccessValueForKey:@"amountGst"];
    NSDecimalNumber *amount = [self primitiveValueForKey:@"amountGst"];
    [self didAccessValueForKey:@"amountGst"];
    
    //    if (self.importedObject.boolValue && ![amount isEqualToNumber:[NSDecimalNumber notANumber]])
    if (self.importedObject.boolValue && amount != nil && ![amount isEqualToNumber:[NSDecimalNumber notANumber]] && amount.intValue >= 0)
    {
        return amount;
    }
    
    NSDecimalNumber * totalTaskGst = [[self.tasks valueForKeyPath:@"@sum.totalFeesGst"] decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber accurateRoundingHandler]];
    
    NSDecimalNumber * totalDisbursementGst = [[self.disbursements valueForKeyPath:@"@sum.amountGst"] decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber accurateRoundingHandler]];
    
    amount = [totalTaskGst decimalNumberByAdding:totalDisbursementGst withBehavior:[NSDecimalNumber accurateRoundingHandler]];
    
    return amount;
}

+ (NSSet *)keyPathsForValuesAffectingAmountGst
{
    return [NSSet setWithObjects:@"tasks", @"disbursements", nil];
}

+ (NSSet *)keyPathsForValuesAffectingAmount
{
    return [NSSet setWithObjects:@"tasks", @"disbursements", nil];
}

#pragma mark - Receiving Money

+ (NSSet *)keyPathsForValuesAffectingIsPaid
{
    return [NSSet setWithObjects:@"receiptAllocations", @"tasks", @"writeOffs",@"disbursements", nil];
}



@end
