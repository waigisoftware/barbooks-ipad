//
//  BBContactListViewController.h
//  barbooks-ipad
//
//  Created by Can on 20/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBMatterDelegate.h"
#import "BBContactDelegate.h"
#import "Solicitor.h"
#import "Contact.h"
#import "BBBaseTableViewController.h"

@interface BBContactListViewController : BBBaseTableViewController <UIPopoverControllerDelegate, BBContactDelegate>

@property (strong, nonatomic) NSArray *solicitorList;
@property (weak, nonatomic) id<BBMatterDelegate> delegate;

@end
