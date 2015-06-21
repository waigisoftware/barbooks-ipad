//
//  UISplitViewController+BBUtil.m
//  barbooks-ipad
//
//  Created by Can on 8/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "UISplitViewController+BBUtil.h"

@implementation UISplitViewController (BBUtil)

- (UIViewController *)masterViewController {
    return [self.viewControllers firstObject];
}

- (UIViewController *)detailViewController {
    return self.viewControllers.count > 1 ? self.viewControllers[1] : nil;
}

@end
