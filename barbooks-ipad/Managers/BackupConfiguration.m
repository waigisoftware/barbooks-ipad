//
//  BackupConfiguration.m
//  barbooks-ipad
//
//  Created by Can on 17/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BackupConfiguration.h"

@implementation BackupConfiguration

- (void)link {}
- (void)unlink {}
- (void)showSetupWindow {}
- (void)restore {}
- (void)sync {}
- (void)deleteStore {}
- (BackupLocationType)backgroundLocationType { return BackupLocationTypeNotSet; }
- (NSManagedObjectContext *)managedObjectContext
{
    return [NSManagedObjectContext MR_defaultContext];;
}

@end

