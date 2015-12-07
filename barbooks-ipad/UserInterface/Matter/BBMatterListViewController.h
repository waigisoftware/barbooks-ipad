//
//  BBMatterListViewController.h
//  barbooks-ipad
//
//  Created by Can on 6/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBTableViewController.h"
#import "BBTaskListViewController.h"
#import "BBMatterViewController.h"
#import "BBMatterDelegate.h"

@interface BBMatterListViewController : BBTableViewController <BBMatterDelegate>

@property (strong, nonatomic) BBTaskListViewController *taskListViewController;
@property (weak, nonatomic) IBOutlet UITableView *matterListTableView;
@property (strong) id createdObject;


@end
