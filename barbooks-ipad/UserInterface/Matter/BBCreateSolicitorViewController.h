//
//  BBCreateSolicitorViewController.h
//  barbooks-ipad
//
//  Created by Can on 17/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBBaseViewController.h"
#import "BBMatterDelegate.h"
#import "Solicitor.h"

@interface BBCreateSolicitorViewController : BBBaseViewController

@property (strong, nonatomic) Solicitor *solicitor;
@property (weak, nonatomic) id<BBMatterDelegate> delegate;

@end
