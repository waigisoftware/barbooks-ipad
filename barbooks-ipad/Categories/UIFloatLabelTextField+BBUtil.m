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
    self.borderStyle = UITextBorderStyleNone;
    //CALayer *border = [self bottomBorderWithColor:[UIColor lightGrayColor]];
    //border.frame = [self frameWithBottomBorder];
    //[self.layer addSublayer:border];
    self.layer.masksToBounds = YES;
    self.floatLabelActiveColor = [UIColor bbPrimaryBlue];
    self.floatLabelFont = [UIFont systemFontOfSize:9];
}

-(CGRect) frameWithBottomBorder
{
    return CGRectMake(0,
                      self.frame.size.height - DefaultBorderWidth,
                      self.frame.size.width,
                      self.frame.size.height);
    
}

-(CALayer *) bottomBorderWithColor:(UIColor *)borderColor
{
    CALayer *border = [CALayer layer];
    border.borderColor = borderColor.CGColor;
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

-(void) applyBottomBorderStyleFloatLabelFont:(UIFont *)floatLabelFont
                       floatLabelActiveColor:(UIColor *)floatLabelActiveColor
                      floatLabelPassiveColor:(UIColor *)floatLabelPassiveColor
                               textFieldFont:(UIFont *)textFieldFont
                                 borderColor:(UIColor *)borderColor
{
    [self applyBottomBorderStyleFloatLabelFont:floatLabelFont
                         floatLabelActiveColor:floatLabelActiveColor
                        floatLabelPassiveColor:floatLabelPassiveColor
                                 textFieldFont:textFieldFont
                                    showBorder:YES
                                   borderColor:borderColor];
}

-(void) applyBottomBorderStyleFloatLabelFont:(UIFont *)floatLabelFont
                       floatLabelActiveColor:(UIColor *)floatLabelActiveColor
                      floatLabelPassiveColor:(UIColor *)floatLabelPassiveColor
                               textFieldFont:(UIFont *)textFieldFont
                                  showBorder:(BOOL)showBorder
                                 borderColor:(UIColor *)borderColor
{
    if (showBorder) {
        CALayer *border = [self bottomBorderWithColor:borderColor];
        border.frame = [self frameWithBottomBorder];
        [self.layer addSublayer:border];
        self.layer.masksToBounds = YES;
    }
    
    self.floatLabelActiveColor = floatLabelActiveColor;
    self.floatLabelPassiveColor = floatLabelPassiveColor;
    self.floatLabelFont = floatLabelFont;
    self.font = textFieldFont;
}

+ (void)applyStyleToAllUIFloatLabelTextFieldInView:(UIView *)view {
    NSArray *subviews = [view subviews];
    if (subviews && (subviews.count > 0)) {
        for (UIView *subview in subviews) {
            if (![subview isKindOfClass:[UIFloatLabelTextField class]] && [subview subviews].count > 0) {
                [UIFloatLabelTextField applyStyleToAllUIFloatLabelTextFieldInView:subview];
            } else {
                if ([subview isKindOfClass:[UIFloatLabelTextField class]]) {
                    [((UIFloatLabelTextField *)subview) applyBottomBorderStyle];
                }
            }
        }
    }
}

@end
