//
//  VariationOfFees.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BBManagedObject.h"

@class Matter;

@interface VariationOfFees : BBManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) id information;
@property (nonatomic, retain) Matter *matter;

@end
