//
//  BBReceiptListViewController.h
//  barbooks-ipad
//
//  Created by Can on 24/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBBaseTableViewController.h"
#import "BBReceiptViewController.h"
#import "BBReceiptDelegate.h"

@interface BBReceiptListViewController : BBBaseTableViewController <BBReceiptDelegate>

@property (strong, nonatomic) Receipt *receipt;
@property (strong, nonatomic) BBReceiptViewController *receiptViewController;

@end
