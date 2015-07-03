//
//  BBDropDownListDelegate.h
//  barbooks-ipad
//
//  Created by Can on 28/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BBDropDownListDelegate <NSObject>

- (void)updateWithSelection:(id)data;

@end
