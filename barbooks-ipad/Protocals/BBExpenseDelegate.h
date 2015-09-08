//
//  BBExpenseDelegate.h
//  barbooks-ipad
//
//  Created by Can on 23/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BBExpenseDelegate <NSObject>

- (void)updateExpense:(id)data;

@end
