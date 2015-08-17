//
//  BBRateViewController.h
//  barbooks-ipad
//
//  Created by Can on 4/07/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBTableViewController.h"
#import "Rate.h"
#import "BBRateDelegate.h"

@interface BBRateViewController : BBTableViewController <UITextFieldDelegate>

@property (strong, nonatomic) Rate *rate;
@property (weak, nonatomic) id<BBRateDelegate> delegate;

@end
