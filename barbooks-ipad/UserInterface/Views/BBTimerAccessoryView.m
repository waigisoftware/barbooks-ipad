//
//  BBTimerAccessoryView.m
//  barbooks-ipad
//
//  Created by Eric on 18/08/2015.
//  Copyright © 2015 Censea. All rights reserved.
//

#import "BBTimerAccessoryView.h"
#import "UIColor+BBUtil.h"

#define BBTimerAccessoryViewTableViewCell @"BBTimerCellAccessory"

@implementation BBTimerAccessoryView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (id)cellAccessoryView
{
    return [self accessoryViewFromNib:BBTimerAccessoryViewTableViewCell];
}

+ (id)accessoryViewFromNib:(NSString*)nib
{
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:nib
                                                   owner:self
                                                 options:nil];
    return [views objectAtIndex:0];
}


- (void)startAnimatingTimer
{
    
    
    // Check if the timer is already animating
    if (![self.timerButton.layer animationForKey:@"transform.scale"]) {
        [self.timerButton setBackgroundColor:[UIColor bbGreen]];
        [self.timerButton setImage:[UIImage imageNamed:@"button_timer_pause"] forState:UIControlStateNormal];
        
        //        if (!CGPointEqualToPoint(self.accessoryView.layer.anchorPoint, CGPointMake(0.5, 0.5)) ) {
        //            [self.accessoryView.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
        //        }
        
        float duration = 1.0f;
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        
        animation.duration = duration;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.values = @[[NSNumber numberWithFloat:1.0f],
                             [NSNumber numberWithFloat:1.1f],
                             [NSNumber numberWithFloat:1.0f],
                             ];
        
        animation.keyTimes = @[[NSNumber numberWithFloat:0.0f],
                               [NSNumber numberWithFloat:0.2f],
                               [NSNumber numberWithFloat:1.0f],
                               ];
        
        animation.removedOnCompletion = NO;
        animation.repeatCount = HUGE_VALF;
        
        [self.timerButton.layer addAnimation:animation forKey:@"transform.scale"];
    }
}

- (void)stopAnimatingTimer
{
    [self.timerButton setBackgroundColor:[UIColor bbGreyLine]];
    [self.timerButton setImage:[UIImage imageNamed:@"button_timer"] forState:UIControlStateNormal];

    [self.timerButton.layer removeAllAnimations];
}


@end
