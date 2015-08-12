//
//  BBTaskListViewController.h
//  barbooks-ipad
//
//  Created by Can on 23/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBBaseTableViewController.h"
#import "BBTaskDelegate.h"

@class BBMatterListViewController;

@interface BBTaskListViewController : BBBaseTableViewController <BBTaskDelegate, UIPopoverControllerDelegate>

@property (weak, nonatomic) BBMatterListViewController *matterListViewController;

@end
