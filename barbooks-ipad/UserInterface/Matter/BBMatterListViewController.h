//
//  BBMatterListViewController.h
//  barbooks-ipad
//
//  Created by Can on 6/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBBaseTableViewController.h"
#import "BBTaskListViewController.h"
#import "BBMatterViewController.h"

@interface BBMatterListViewController : BBBaseTableViewController

@property (strong, nonatomic) BBTaskListViewController *taskListViewController;

- (void)fetchMatters;

@end
