//
//  Solicitor.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Contact.h"
#import "Firm.h"

@class Firm, Matter;

@interface Solicitor : Contact

@property (nonatomic, retain, readonly) NSNumber * isFirmOnly;
@property (nonatomic, retain) Firm *firm;
@property (nonatomic, retain) NSSet *matters;

- (NSString *)displayName;

@end

@interface Solicitor (CoreDataGeneratedAccessors)

- (void)addMattersObject:(Matter *)value;
- (void)removeMattersObject:(Matter *)value;
- (void)addMatters:(NSSet *)values;
- (void)removeMatters:(NSSet *)values;

@end
