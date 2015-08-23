//
//  BBSyncManager.m
//  barbooks-ipad
//
//  Created by Can on 17/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBSyncManager.h"
#import "BBManagedObject.h"
#import "NSManagedObject+ParcelKit.h"
#import "DBRecord+ParcelKit.h"
#import "NSDate+BBUtil.h"

@implementation BBSyncManager

- (NSSet *)syncableManagedObjectsFromManagedObjects:(NSSet *)managedObjects
{
    NSMutableSet *syncableManagedObjects = [[NSMutableSet alloc] init];
    for (BBManagedObject *managedObject in managedObjects) {
        
        NSInteger fy_datastore = [self.fromDate financialYear];
        
        if (![managedObject createdAt]) {
            if ([managedObject respondsToSelector:@selector(date)] && [managedObject valueForKeyPath:@"date"]) {
                [managedObject setCreatedAt:[managedObject valueForKeyPath:@"date"]];
            } else {
                [managedObject setCreatedAt:[NSDate date]];
            }
        }
        
        NSInteger comparisonFY = [managedObject.createdAt financialYear];
        
        if (fy_datastore != comparisonFY) {
            continue;
        }
        
        if (fy_datastore == 2016) {
            NSLog(@"");
        }
        
        NSString *tableID = [self tableForEntityName:[[managedObject entity] name]];
        if (!tableID) continue;
        
        if ([managedObject respondsToSelector:@selector(isRecordSyncable)]) {
            id<ParcelKitSyncedObject> pkObj = (id<ParcelKitSyncedObject>)managedObject;
            if (![pkObj isRecordSyncable]) {
                continue;
            }
        }
        
        if (![managedObject valueForKey:self.syncAttributeName]) {
            [managedObject setPrimitiveValue:[[self class] syncID] forKey:self.syncAttributeName];
        }
        
        [syncableManagedObjects addObject:managedObject];
    }
    
    return [[NSSet alloc] initWithSet:syncableManagedObjects];
}

@end
