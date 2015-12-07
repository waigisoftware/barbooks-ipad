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

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong, readonly) NSString *entityName;
@property (nonatomic, strong, readonly) NSArray *sortDescriptors;
@property (nonatomic, strong, readonly) NSPredicate *filterPredicate;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath *)indexPathOfItem:(NSObject *)item;
- (void)managedObjectContextDidSave:(NSNotification*)notification;

@end
