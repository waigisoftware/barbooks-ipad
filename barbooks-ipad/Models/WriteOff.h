//
//  WriteOff.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Payment.h"

@class Invoice;

@interface WriteOff : Payment

@property (nonatomic, retain) Invoice *invoice;

@end
