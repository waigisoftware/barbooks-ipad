//
//  BBTableViewController.h
//  barbooks-ipad
//
//  Created by Eric on 14/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UISplitViewController+BBUtil.h"
#import "UIResponder+BBUtil.h"
#import "NSDate+BBUtil.h"
#import "NSString+BBUtil.h"
#import "UIColor+BBUtil.h"
#import "NSDecimalNumber+BBUtil.h"
#import "NSArray+BBUtil.h"
#import "UIFloatLabelTextField+BBUtil.h"
#import "UIButton+BBUtil.h"
#import "GlobalAttributes.h"
#import <CHDropDownTextField/CHDropDownTextField.h>
#import "Matter.h"

@interface BBTableViewController : UITableViewController

@property (strong, nonatomic) Matter *matter;
@property (strong, nonatomic, readonly) UIStoryboard *mainStoryboard;

- (void)registerRefreshControlFor:(UITableView *)tableView withAction:(SEL)action;

- (void)stopAndUpdateDateOnRefreshControl;

- (BOOL)isRefreshControlRefreshing;

- (UIRefreshControl *)refreshControl;

- (NSIndexPath *)indexPathOfItem:(NSObject *)item;

@end
