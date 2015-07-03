//
//  BBDropDownListViewController.h
//  barbooks-ipad
//
//  Created by Can on 24/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBBaseViewController.h"
#import "BBDropDownListDelegate.h"

@interface BBDropDownListViewController : BBBaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *displayItemList;
@property (strong, nonatomic) NSArray *dataItemList;
@property (weak, nonatomic) id<BBDropDownListDelegate> delegate;

@end
