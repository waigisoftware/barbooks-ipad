//
//  BBBaseTableViewController.h
//  barbooks-ipad
//
//  Created by Can on 4/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBBaseViewController.h"
#import "Matter.h"

@interface BBBaseTableViewController : BBBaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) Matter *matter;
@property (strong, nonatomic) IBOutlet UIView *noContentView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;


- (NSIndexPath *)indexPathOfItem:(NSObject *)item;

@end
