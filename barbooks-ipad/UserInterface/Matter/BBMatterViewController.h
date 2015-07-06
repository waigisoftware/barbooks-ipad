//
//  BBMaterViewController.h
//  barbooks-ipad
//
//  Created by Can on 8/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBBaseViewController.h"
#import "Matter.h"
#import "BBMatterDelegate.h"
#import <JTCalendar.h>

@class BBMatterListViewController;

@interface BBMatterViewController : BBBaseViewController <UITextFieldDelegate, BBMatterDelegate, UIPopoverControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate, JTCalendarDataSource>

@property (strong, nonatomic) Matter *matter;
@property (weak, nonatomic) BBMatterListViewController *matterListViewController;

@end