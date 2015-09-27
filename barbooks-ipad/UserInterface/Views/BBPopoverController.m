//
//  BBPopoverController.m
//  barbooks-ipad
//
//  Created by Eric on 23/09/2015.
//  Copyright © 2015 Censea. All rights reserved.
//

#import "BBPopoverController.h"

@interface BBPopoverController () <UIPopoverPresentationControllerDelegate>

@end

@implementation BBPopoverController

- (instancetype)init {
    if (self = [super init]) {
        self.modalPresentationStyle = UIModalPresentationPopover;
        self.popoverPresentationController.delegate = self;
    }
    return self;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone; //You have to specify this particular value in order to make it work on iPhone.
}

@end
