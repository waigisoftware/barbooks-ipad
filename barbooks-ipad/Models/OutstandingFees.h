//
//  OutstandingFees.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BBManagedObject.h"

@class Matter, OutstandingAmount;

@interface OutstandingFees : BBManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) id information;
@property (nonatomic, retain) NSDecimalNumber * totalOutstanding;
@property (nonatomic, retain) Matter *matter;
@property (nonatomic, retain) NSSet *outstandingAmounts;
@end

@interface OutstandingFees (CoreDataGeneratedAccessors)

- (void)addOutstandingAmountsObject:(OutstandingAmount *)value;
- (void)removeOutstandingAmountsObject:(OutstandingAmount *)value;
- (void)addOutstandingAmounts:(NSSet *)values;
- (void)removeOutstandingAmounts:(NSSet *)values;

@end
