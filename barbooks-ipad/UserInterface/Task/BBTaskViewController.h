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
#import "Task.h"

@interface BBTaskViewController : BBBaseViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) Task *task;
@property (weak, nonatomic) id<BBTaskDelegate> delegate;

@end
