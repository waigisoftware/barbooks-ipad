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

@interface BBTaskListViewController : BBBaseTableViewController <BBTaskDelegate, UIPopoverControllerDelegate>

@end
