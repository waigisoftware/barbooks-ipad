//
//  BBBaseViewController.h
//  barbooks-ipad
//
//  Created by Can on 4/06/2015.
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
#import "GlobalAttributes.h"

@interface BBBaseViewController : UIViewController <UIAlertViewDelegate>

//- (void)coreDataSave;
@property (strong, nonatomic, readonly) UIStoryboard *mainStoryboard;

@end
