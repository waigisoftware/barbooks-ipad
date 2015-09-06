//
//  SubscriptionManager.h
//  BarBooks
//
//  Created by Eric on 4/11/2014.
//  Copyright (c) 2014 Censea Software Corporation Pty Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CouchbaseLite/CouchbaseLite.h>

#define kLoginSuccessfulNotification @"kLoginSuccessfulNotification"
#define kLoginFailedNotification @"kLoginFailedNotification"
#define kSubscriptionUpdatedNotification @"kSubscriptionUpdatedNotification"
#define kSyncStatusUpdatedNotification @"kSyncStatusUpdatedNotification"

#define kMaxDaysOverdue 14

typedef enum {
    BBSubscriptionStatusExpired,
    BBSubscriptionStatusActive,
    BBSubscriptionStatusPending
}BBSubscriptionStatus;

@interface BBCloudManager : NSObject

@property (assign) BOOL isLoggedIn;
@property (assign) CBLReplicationStatus syncStatus;

+ (instancetype)sharedManager;

- (void) signinWithUsername:(NSString*)username password:(NSString*)password;
- (void) startSubscriptionProcess;
- (BBSubscriptionStatus) subscriptionStatus;
- (NSInteger) daysOverdue;
- (NSDate *)subscriptionEndDate;
- (void) checkSubscriptionStatus;
- (void) logout;
- (void) activeSync;

@end
