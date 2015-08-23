//
//  DropboxConfiguration.h
//  barbooks-ipad
//
//  Created by Can on 17/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BackupConfiguration.h"

@interface DropboxConfiguration : BackupConfiguration

- (void)linkInViewController:(UIViewController *)viewController;
- (void)restoreInViewController:(UIViewController *)viewController;

@end
