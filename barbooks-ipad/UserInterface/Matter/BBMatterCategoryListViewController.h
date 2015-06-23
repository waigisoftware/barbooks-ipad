//
//  BBMatterCategoryListViewController.h
//  barbooks-ipad
//
//  Created by Can on 23/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBBaseTableViewController.h"
#import "BBTaskListViewController.h"

@interface BBMatterCategoryListViewController : BBBaseTableViewController

@property (strong, nonatomic) BBTaskListViewController *taskListViewController;

@end
