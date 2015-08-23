//
//  BBAccountManager.h
//  barbooks-ipad
//
//  Created by Can on 17/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Account.h"

@interface BBAccountManager : NSObject

@property (strong) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Account *activeAccount;

+ (BBAccountManager *)sharedManager;

- (BOOL)accountAvailable;
- (void)setActiveAccountWithNumber:(NSNumber*)accountNumber;
- (void)setToLatestAccount;
- (void)setToLargestAccount;
- (id)getAnyAccount;

- (void)createAccountIfNotExist;

@end
