//
//  BBTaskViewController.h
//  barbooks-ipad
//
//  Created by Can on 23/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTableViewController.h"
#import "BBTaskDelegate.h"
#import "BBDropDownListDelegate.h"
#import "BBDropDownListViewController.h"
#import "Task.h"
#import "Rate.h"
#import "Matter.h"

@interface BBTaskViewController : BBTableViewController <UITextFieldDelegate, UITextViewDelegate, BBDropDownListDelegate>

@property (strong, nonatomic) Task *task;
@property (weak, nonatomic) id<BBTaskDelegate> delegate;

@end
