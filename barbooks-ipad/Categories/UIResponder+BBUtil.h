//
//  UIResponder+BBUtil.h
//  barbooks-ipad
//
//  Created by Can on 15/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder (BBUtil)

+ (id)currentFirstResponder;

- (void)findFirstResponder:(id)sender;

@end
