//
//  BBContactListViewController.h
//  barbooks-ipad
//
//  Created by Can on 20/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBMatterDelegate.h"
#import "Solicitor.h"
#import "Contact.h"

@interface BBContactListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *solicitorList;
@property (weak, nonatomic) id<BBMatterDelegate> delegate;

@end
