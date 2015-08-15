//
//  BBSubscriptionManager.h
//  barbooks-ipad
//
//  Created by Can on 15/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    BBSubscriptionStatusExpired,
    BBSubscriptionStatusActive,
    BBSubscriptionStatusPending
} BBSubscriptionStatus;

@interface BBSubscriptionManager : NSObject

@property (assign) BOOL isLoggedIn;

+ (instancetype)sharedInstance;

- (void)signinWithUsername:(NSString*)username password:(NSString*)password;
- (void)logout;
- (BOOL)subscriptionValid;

@end
