//
//  Rate.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BBManagedObject.h"
#import "GlobalAttributes.h"
#import "NSDecimalNumber+BBUtil.h"

@class Account, Matter, Task;

@interface Rate : BBManagedObject

@property (nonatomic, retain) NSDecimalNumber * amount;
@property (nonatomic, retain) NSDecimalNumber * amountGst;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) Account *account;
@property (nonatomic, retain) Matter *matter;
@property (nonatomic, retain) Task *task;

@end
