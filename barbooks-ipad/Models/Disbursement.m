//
//  Disbursement.m
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "Disbursement.h"
#import "Matter.h"
#import "RegularInvoice.h"


@implementation Disbursement

@dynamic invoice;
@dynamic matter;

+ (NSArray *)allUnlinkedObjectsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSPredicate *fetchpredicate = [NSPredicate predicateWithFormat:@"matter == nil"];
    
    NSArray *tasks = [Disbursement MR_findAllWithPredicate:fetchpredicate inContext:managedObjectContext];
    
    return tasks;
}

@end
