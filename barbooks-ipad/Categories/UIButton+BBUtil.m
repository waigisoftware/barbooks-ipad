//
//  UIButton+BBUtil.m
//  barbooks-ipad
//
//  Created by Can on 6/07/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "UIButton+BBUtil.h"
#import "UIColor+BBUtil.h"

@implementation UIButton (BBUtil)

- (void)updateBackgroundColourAndSetEnabledTo:(BOOL)enabled {
    self.enabled = enabled;
    self.userInteractionEnabled = enabled;
    self.backgroundColor = enabled ? [UIColor bbEnabledButtonBackgroundColor] : [UIColor bbDisabledButtonBackgroundColor];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
}

@end
