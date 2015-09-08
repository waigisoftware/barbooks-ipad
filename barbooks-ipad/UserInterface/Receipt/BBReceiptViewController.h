//
//  BBReceiptViewController.h
//  barbooks-ipad
//
//  Created by Can on 24/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBBaseTableViewController.h"
#import "Receipt.h"
#import <JTCalendar.h>
#import <IGLDropDownMenu/IGLDropDownMenu.h>
#import "BBReceiptDelegate.h"

@class BBReceiptListViewController;

@interface BBReceiptViewController : BBBaseTableViewController <JTCalendarDataSource, IGLDropDownMenuDelegate, UITextFieldDelegate>

@property (strong, nonatomic) Receipt *receipt;
@property (weak, nonatomic) BBReceiptListViewController *receiptListViewController;
@property (weak, nonatomic) id<BBReceiptDelegate> delegate;

@property BOOL showCloseButton;

@end
