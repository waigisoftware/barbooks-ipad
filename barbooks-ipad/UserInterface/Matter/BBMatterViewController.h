//
//  BBMaterViewController.h
//  barbooks-ipad
//
//  Created by Can on 8/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBBaseViewController.h"
#import "BBMatterListViewController.h"
#import <JTCalendar.h>
#import "Matter.h"
#import "BBMatterDelegate.h"

@interface BBMatterViewController : BBBaseViewController <UITextFieldDelegate, BBMatterDelegate, UIPopoverControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, JTCalendarDataSource>

@property (strong, nonatomic) Matter *matter;
@property (strong, nonatomic) BBMatterListViewController *matterListViewController;

@end