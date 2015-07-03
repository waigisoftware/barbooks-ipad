//
//  BBTaskViewController.h
//  barbooks-ipad
//
//  Created by Can on 23/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBBaseViewController.h"
#import "BBTaskDelegate.h"
#import "BBDropDownListDelegate.h"
#import "BBDropDownListViewController.h"
#import "Task.h"
#import "Rate.h"

@interface BBTaskViewController : BBBaseViewController <UITextFieldDelegate, BBDropDownListDelegate>

@property (strong, nonatomic) Task *task;
@property (weak, nonatomic) id<BBTaskDelegate> delegate;

@end
