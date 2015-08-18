//
//  BBTimerAccessoryView.h
//  barbooks-ipad
//
//  Created by Eric on 18/08/2015.
//  Copyright © 2015 Censea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBTimerAccessoryView : UIView

@property (strong, nonatomic) IBOutlet UIButton *timerButton;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;

+ (id)cellAccessoryView;

- (void)startAnimatingTimer;
- (void)stopAnimatingTimer;

@end
