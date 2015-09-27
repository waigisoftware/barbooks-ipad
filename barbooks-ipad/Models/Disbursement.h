//
//  Disbursement.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Expense.h"

@class Matter, RegularInvoice;

@interface Disbursement : Expense

@property (nonatomic, retain) RegularInvoice *invoice;
@property (nonatomic, retain) Matter *matter;

+ (instancetype)newInstanceOfMatter:(Matter *)matter;

@end
