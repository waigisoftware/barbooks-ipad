//
//  BBDiscountViewController.h
//  barbooks-ipad
//
//  Created by Can on 13/09/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBBaseViewController.h"
#import "BBDiscountDelegate.h"
#import "Discount.h"

@interface BBDiscountViewController : BBBaseViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) Discount *discount;
@property (strong, nonatomic) Task *task;
@property (strong, nonatomic) Invoice *invoice;
@property (weak, nonatomic) id<BBDiscountDelegate> delegate;

@end
