//
//  Firm.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BBManagedObject.h"

@class Solicitor;

@interface Firm : BBManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDecimalNumber * remainingAmount;
@property (nonatomic, retain) NSSet *solicitors;
@end

@interface Firm (CoreDataGeneratedAccessors)

- (void)addSolicitorsObject:(Solicitor *)value;
- (void)removeSolicitorsObject:(Solicitor *)value;
- (void)addSolicitors:(NSSet *)values;
- (void)removeSolicitors:(NSSet *)values;

@end
