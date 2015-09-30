//
//  BBMatterSelectionTableViewController.h
//  barbooks-ipad
//
//  Created by Eric on 30/09/2015.
//  Copyright © 2015 Censea. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BBMatterSelectionDelegate;

@interface BBMatterSelectionTableViewController : UITableViewController

@property (strong, nonatomic) id<BBMatterSelectionDelegate> delegate;

@end

@protocol BBMatterSelectionDelegate <NSObject>

- (void)matterSelectionController:(BBMatterSelectionTableViewController*)controller didSelectMatter:(Matter*)matter;

@end