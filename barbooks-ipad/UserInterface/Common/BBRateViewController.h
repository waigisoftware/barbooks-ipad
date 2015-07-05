//
//  BBRateViewController.h
//  barbooks-ipad
//
//  Created by Can on 4/07/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBBaseViewController.h"
#import "Rate.h"
#import "BBMatterDelegate.h"

@interface BBRateViewController : BBBaseViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) Rate *rate;
@property (weak, nonatomic) id<BBMatterDelegate> delegate;

@end
