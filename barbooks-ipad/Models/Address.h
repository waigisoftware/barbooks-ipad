//
//  Address.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BBManagedObject.h"

@class Contact;

@interface Address : BBManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * streetLine1;
@property (nonatomic, retain) NSString * streetLine2;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSSet *contact;
@end

@interface Address (CoreDataGeneratedAccessors)

- (void)addContactObject:(Contact *)value;
- (void)removeContactObject:(Contact *)value;
- (void)addContact:(NSSet *)values;
- (void)removeContact:(NSSet *)values;

@end
