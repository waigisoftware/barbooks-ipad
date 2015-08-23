//
//  BBModalDatePickerViewController.h
//  barbooks-ipad
//
//  Created by Eric on 20/08/2015.
//  Copyright © 2015 Censea. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BBModalDatePickerViewControllerDelegate <NSObject>
@optional
- (void)datePickerControllerDone:(UIDatePicker*)datePicker;
- (void)datePickerControllerCancelled:(UIDatePicker*)datePicker;

@end

@interface BBModalDatePickerViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) id<BBModalDatePickerViewControllerDelegate> delegate;

- (void)run;

+ (id)defaultPicker;

@end
