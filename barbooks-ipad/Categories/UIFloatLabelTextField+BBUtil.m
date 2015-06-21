//
//  UIFloatLabelTextField+BBUtil.m
//  barbooks-ipad
//
//  Created by Can on 13/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "UIFloatLabelTextField+BBUtil.h"
#import "UIColor+BBUtil.h"

@implementation UIFloatLabelTextField (BBUtil)

static NSInteger const DefaultBorderWidth = 1;
-(void) applyBottomBorderStyle
{
    
    CALayer *border = [self bottomBorder];
    border.frame = [self frameWithBottomBorder];
    [self.layer addSublayer:border];
    self.layer.masksToBounds = YES;
    self.floatLabelActiveColor = [UIColor bbPrimaryBlue];
    self.floatLabelFont = [UIFont systemFontOfSize:7];
}

-(CGRect) frameWithBottomBorder
{
    return CGRectMake(0,
                      self.frame.size.height - DefaultBorderWidth,
                      self.frame.size.width,
                      self.frame.size.height);
    
}

-(CALayer *) bottomBorder
{
    CALayer *border = [CALayer layer];
    border.borderColor = [UIColor lightGrayColor].CGColor;
    border.borderWidth = DefaultBorderWidth;
    return border;
}

-(void) applyEditSytle
{
    if ([self.layer.sublayers objectAtIndex:1])
    {
        ((CALayer *)[self.layer.sublayers objectAtIndex:1]).borderColor = [UIColor bbPrimaryBlue].CGColor;
    }
}

-(void) revertEditStyle
{
    if ([self.layer.sublayers objectAtIndex:1])
    {
        ((CALayer *)[self.layer.sublayers objectAtIndex:1]).borderColor = [UIColor lightGrayColor].CGColor;
    }
}

@end
