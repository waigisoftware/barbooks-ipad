//
//  UIColor+BBUtil.m
//  barbooks-ipad
//
//  Created by Can on 13/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "UIColor+BBUtil.h"

@implementation UIColor (BBUtil)

+(UIColor *) bbLightGrey {
    return [UIColor colorWithRed:244.0f/255.0f
                           green:244.0f/255.0f
                            blue:244.0f/255.0f
                           alpha:1.0f];
}



+(UIColor *) bbDarkText {
    return [UIColor colorWithRed:44.0f/255.0f
                           green:47.0f/255.0f
                            blue:57.0f/255.0f
                           alpha:1.0f];
}



+(UIColor *) bbDarkGrey {
    return [UIColor colorWithRed:56.0f/255.0f
                           green:52.0f/255.0f
                            blue:53.0f/255.0f
                           alpha:1.0f];
}

+(UIColor *) bbGreyLine {
    return [UIColor colorWithRed:0.835
                           green:0.835
                            blue:0.827
                           alpha:1];
}


+(UIColor*) bbPrimaryBlue {
    return [UIColor colorWithRed:0.0/255.0
                           green:31.0/255.0
                            blue:68.0/255.0
                           alpha:1];
}

+ (UIColor*) bbTableBackground {
    return [UIColor colorWithRed:38.0/255.0
                           green:58.0/255.0
                            blue:87.0/255.0
                           alpha:1];
}


+(UIColor*) bbPrimaryDisabledBlue {
    return [UIColor colorWithRed:0.639
                           green:0.722
                            blue:0.824
                           alpha:1];
}


+(UIColor*) bbGreyText {
    return [UIColor colorWithRed:0.455
                           green:0.463
                            blue:0.471
                           alpha:1];
}

+(UIColor *) bbDarkGreen {
    return [UIColor colorWithRed:63.0f/255.0f
                           green:127.0f/255.0f
                            blue:53.0f/255.0f
                           alpha:1.0f];
}

+(UIColor *) bbGreen {
    return [UIColor colorWithRed:36.0f/255.0f
                           green:212.0f/255.0f
                            blue:68.0f/255.0f
                           alpha:1.0f];
}


+(UIColor*) bbRed {
    return [UIColor colorWithRed:230.0/255.0
                           green:40.0/255.0
                            blue:33.0/255.0
                           alpha:1];
}


+(UIColor*) bbBubbleBlue {
    return [UIColor colorWithRed:52.0/255.0
                           green:151.0/255.0
                            blue:243.0/255.0
                           alpha:1];
}

+(UIColor*) bbErrorRed {
    return [UIColor colorWithRed:210.0/255.0
                           green:66.0/255.0
                            blue:73.0/255.0
                           alpha:1];
}

+ (UIColor *)bbEnabledButtonBackgroundColor
{
    return [UIColor colorWithRed:35.0/255.0
                           green:110.0/255.0
                            blue:174.0/255.0
                           alpha:1];
}

+ (UIColor *)bbDisabledButtonBackgroundColor
{
    return [UIColor colorWithRed:0.639
                           green:0.722
                            blue:0.824
                           alpha:1];
}

+ (UIColor *)bbButtonBackgroundColor
{
    return [UIColor colorWithRed:14.0/255.0
                           green:35.0/255.0
                            blue:70.0/255.0
                           alpha:1];
}

@end
