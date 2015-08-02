//
//  UIFloatLabelTextField+BBUtil.h
//  barbooks-ipad
//
//  Created by Can on 13/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "UIFloatLabelTextField.h"

@interface UIFloatLabelTextField (BBUtil)

-(void) applyBottomBorderStyle;
-(void) applyEditSytle;
-(void) revertEditStyle;
-(void) applyBottomBorderStyleFloatLabelFont:(UIFont *)floatLabelFont
                       floatLabelActiveColor:(UIColor *)floatLabelActiveColor
                      floatLabelPassiveColor:(UIColor *)floatLabelPassiveColor
                               textFieldFont:(UIFont *)textFieldFont
                                 borderColor:(UIColor *)borderColor;
-(void) applyBottomBorderStyleFloatLabelFont:(UIFont *)floatLabelFont
                       floatLabelActiveColor:(UIColor *)floatLabelActiveColor
                      floatLabelPassiveColor:(UIColor *)floatLabelPassiveColor
                               textFieldFont:(UIFont *)textFieldFont
                                  showBorder:(BOOL)showBorder
                                 borderColor:(UIColor *)borderColor;

+ (void)applyStyleToAllUIFloatLabelTextFieldInView:(UIView *)view;

@end
