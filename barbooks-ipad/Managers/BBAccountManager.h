//
//  BBAccountManager.h
//  BarBooks
//
//  Created by Eric on 28/04/2015.
//  Copyright (c) 2015 Censea Software Corporation Pty Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account;
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
