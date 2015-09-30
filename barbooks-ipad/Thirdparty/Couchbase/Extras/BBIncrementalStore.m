//
//  BBIncrementalStore.m
//  BarBooks
//
//  Created by Eric on 4/09/2015.
//  Copyright (c) 2015 Censea Software Corporation Pty Limited. All rights reserved.
//

#import "BBIncrementalStore.h"
#import "BBManagedObject.h"

#define WARN(FMT, ...) NSLog(@"[CBLIS] WARNING " FMT, ##__VA_ARGS__)


@implementation BBIncrementalStore


+ (void) initialize {
    if ([[self class] isEqual: [BBIncrementalStore class]]) {
        [NSPersistentStoreCoordinator registerStoreClass: self
                                            forStoreType: [self type]];
    }
}

+ (NSString*) type {
    return @"BBIncrementalStore";
}

- (NSArray*) obtainPermanentIDsForObjects: (NSArray*)array error: (NSError**)outError {
    NSMutableArray* result = [NSMutableArray arrayWithCapacity: array.count];
    for (BBManagedObject* object in array) {
        // if you call -[NSManagedObjectContext obtainPermanentIDsForObjects:error:] yourself,
        // this can get called with already permanent ids which leads to mismatch between store.
        if (![object.objectID isTemporaryID]) {
            [result addObject: object.objectID];
        } else if(object.syncID) {
            NSString* uuid = [object valueForKeyPath:@"syncID"];
            NSManagedObjectID* objectID = [self newObjectIDForEntity: object.entity
                                                     referenceObject: uuid];
            [result addObject: objectID];
        } else {
            NSString* uuid = [[NSProcessInfo processInfo] globallyUniqueString];
            NSManagedObjectID* objectID = [self newObjectIDForEntity: object.entity
                                                     referenceObject: uuid];
            [result addObject: objectID];
        }
    }
    return result;
}

/** Checks if value is nil or NSNull. */
BOOL CBLISIsNull(id value) {
    return value == nil || [value isKindOfClass: [NSNull class]] || ([value isKindOfClass:[NSDecimalNumber class]] && [value isEqualToNumber:[NSDecimalNumber notANumber]]);
}

- (id) convertCoreDataValue: (id)value toCouchbaseLiteValueOfType: (NSAttributeType)type {
    id result = nil;
    
    switch (type) {
        case NSInteger16AttributeType:
        case NSInteger32AttributeType:
        case NSInteger64AttributeType:
            result = CBLISIsNull(value) ? @(0) : value;
            break;
        case NSDecimalAttributeType:
        case NSDoubleAttributeType:
        case NSFloatAttributeType:
            result = CBLISIsNull(value) ? @(0.0f) : value;
            break;
        case NSStringAttributeType:
            result = CBLISIsNull(value) ? @"" : value;
            break;
        case NSBooleanAttributeType:
            result = CBLISIsNull(value) ? @(NO) : [value boolValue] ? @(YES) : @(NO);
            break;
        case NSDateAttributeType:
            result = CBLISIsNull(value) ? nil : [CBLJSON JSONObjectWithDate: value];
            break;
        case NSBinaryDataAttributeType:
        case NSUndefinedAttributeType:
            result = value;
            break;
        default:
            WARN(@"Unsupported attribute type : %d", (int)type);
            break;
    }
    
    return result;
}


@end
