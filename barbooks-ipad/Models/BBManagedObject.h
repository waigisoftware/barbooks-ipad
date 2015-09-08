//
//  BBManagedObject.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BBManagedObject : NSManagedObject

@property (nonatomic, retain) NSNumber * archived;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * entryNumber;
@property (nonatomic, retain) NSNumber * importedObject;
@property (nonatomic, retain) NSString * syncID;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * owner;

+ (BBManagedObject*) oldestEntryInManagedObjectContext:(NSManagedObjectContext*)context;
+ (BBManagedObject*) latestEntryInManagedObjectContext:(NSManagedObjectContext*)context;

@end
