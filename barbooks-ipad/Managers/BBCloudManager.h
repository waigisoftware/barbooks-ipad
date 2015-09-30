//
//  SubscriptionManager.h
//  BarBooks
//
//  Created by Eric on 4/11/2014.
//  Copyright (c) 2014 Censea Software Corporation Pty Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CouchbaseLite/CouchbaseLite.h>


#define kCouchbaseMigrationStartedNotification @"kCouchbaseMigrationStartedNotification"
#define kCouchbaseMigrationFinishedNotification @"kCouchbaseMigrationFinishedNotification"
#define kCouchbaseProfileFoundNotification @"kCouchbaseProfileFoundNotification"
#define kCouchbaseProfileNotFoundNotification @"kCouchbaseProfileNotFoundNotification"
#define kLoginSuccessfulNotification @"kLoginSuccessfulNotification"
#define kLoginFailedNotification @"kLoginFailedNotification"
#define kSubscriptionUpdatedNotification @"kSubscriptionUpdatedNotification"
#define kSyncStatusUpdatedNotification @"kSyncStatusUpdatedNotification"
#define kSyncStatusProgressedNotification @"kSyncStatusProgressedNotification"

#define kMaxDaysOverdue 14

typedef enum {
    BBSubscriptionStatusExpired,
    BBSubscriptionStatusActive,
    BBSubscriptionStatusPending
}BBSubscriptionStatus;

@interface BBCloudManager : NSObject

@property (assign) BOOL isLoggedIn;
@property (assign) CBLReplicationStatus syncStatus;
@property (assign) CGFloat progress;
@property (assign) NSInteger changes;
@property (assign) NSInteger changesCompleted;

+ (instancetype)sharedManager;

- (void) signinWithUsername:(NSString*)username password:(NSString*)password;
- (void) startSubscriptionProcess;
- (BBSubscriptionStatus) subscriptionStatus;
- (NSInteger) daysOverdue;
- (NSDate *)subscriptionEndDate;
- (void) checkSubscriptionStatus;
- (void) logout;
- (void) activateReplication;

@end
