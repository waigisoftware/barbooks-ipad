//
//  BBManagedObject.m
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBManagedObject.h"


@implementation BBManagedObject

@dynamic archived;
@dynamic createdAt;
@dynamic entryNumber;
@dynamic importedObject;
@dynamic syncID;
@dynamic updatedAt;

// dropbox sync

+ (NSString *)syncID
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    NSString *uuid = (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL, uuidRef));
    return [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

+ (BBManagedObject*) latestEntryInManagedObjectContext:(NSManagedObjectContext*)context
{
    NSSortDescriptor *dateAscending = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
    NSFetchRequest* request = [self fetchRequest];
    request.fetchLimit = 1;
    request.sortDescriptors = @[dateAscending];
    request.predicate = [NSPredicate predicateWithFormat:@"createdAt != nil"];
    request.includesSubentities = YES;
    
    NSError* error = nil;
    NSArray* results = [context executeFetchRequest:request error:&error];
    
    if (results.count) {
        return [results objectAtIndex:0];
    } else {
        return nil;
    }
}

+ (BBManagedObject*) oldestEntryInManagedObjectContext:(NSManagedObjectContext*)context
{
    NSSortDescriptor *dateAscending = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
    NSFetchRequest* request = [self fetchRequest];
    request.fetchLimit = 1;
    request.sortDescriptors = @[dateAscending];
    request.predicate = [NSPredicate predicateWithFormat:@"createdAt != nil"];
    request.includesSubentities = YES;
    
    NSError* error = nil;
    NSArray* results = [context executeFetchRequest:request error:&error];
    
    if (results.count) {
        return [results objectAtIndex:0];
    } else {
        return nil;
    }
}

+ (NSFetchRequest*) fetchRequest {
    return [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
}

+ (NSString*) entityName {
    // subclasses can override, but provide a reasonable default
    return NSStringFromClass(self);
}

// update model objects

+ (void) load {
    @autoreleasepool {
        [[NSNotificationCenter defaultCenter] addObserver: (id)[self class]
                                                 selector: @selector(objectContextWillSave:)
                                                     name: NSManagedObjectContextWillSaveNotification
                                                   object: nil];
    }
}

+ (void) objectContextWillSave: (NSNotification*) notification {
    NSManagedObjectContext* context = [notification object];
    NSSet* allModified = [context.insertedObjects setByAddingObjectsFromSet: context.updatedObjects];
    NSPredicate* predicate = [NSPredicate predicateWithFormat: @"self isKindOfClass: %@", [self class]];
    NSSet* modifiable = [allModified filteredSetUsingPredicate: predicate];
    [modifiable makeObjectsPerformSelector: @selector(setUpdatedAt:) withObject: [NSDate date]];
}

- (NSNumber*)generateIdentifier
{
    if (self.importedObject.boolValue) {
        return self.entryNumber;
    }
    
    NSSortDescriptor *descending = [[NSSortDescriptor alloc] initWithKey:@"entryNumber" ascending:NO];
    NSString *entityName = NSStringFromClass(self.class);
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setSortDescriptors:@[descending]];
    
    // Execute the fetch
    NSError *error;
    NSArray *objects = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    NSInteger lastID = 100000;
    if (objects.count > 0) {
        lastID = MAX(lastID, [[objects objectAtIndex:0] entryNumber].integerValue);
        lastID++;
    }
    
    return [NSNumber numberWithInteger:lastID];
}


@end
