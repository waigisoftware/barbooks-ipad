//
//  BBSelectionTableViewController.h
//  barbooks-ipad
//
//  Created by Eric on 21/08/2015.
//  Copyright © 2015 Censea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBSelectionTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *dataList;
@property (assign, nonatomic) NSInteger selectedIndex;

@end
