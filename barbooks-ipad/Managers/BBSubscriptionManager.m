//
//  BBSubscriptionManager.m
//  barbooks-ipad
//
//  Created by Can on 15/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBSubscriptionManager.h"
#import <AFNetworking/AFNetworking.h>
#import "Lock"

@implementation BBSubscriptionManager

+ (instancetype)sharedInstance {
    static BBSubscriptionManager* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BBSubscriptionManager alloc] init];
    });
    return instance;
}

- (void) signinWithUsername:(NSString*)username password:(NSString*)password
{
    NSString *requestUsername = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)username, NULL, (__bridge CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
    
    NSString *requestPassword = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)password, NULL, (__bridge CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
    
    NSString *cookieURL = [NSString stringWithFormat:@"%@&username=%@&password=%@%@",kGenerateCookieURL,requestUsername,requestPassword,kWordpressApiParameter];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",kAPIURL,cookieURL];
    
    
    [self startRequestWithURL:[NSURL URLWithString:urlString]
   completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
       if ([responseObject objectForKey:@"cookie"])
       {
//           BBSubscriber *user = [BBSubscriber new];
//           user.username = [[responseObject objectForKey:@"user"] objectForKey:@"username"];
//           user.userID = [NSString stringWithFormat:@"%i",[[[responseObject objectForKey:@"user"] objectForKey:@"id"] intValue]];
//           user.cookie = [responseObject objectForKey:@"cookie"];
           NSString *userId = [NSString stringWithFormat:@"%i",[[[responseObject objectForKey:@"user"] objectForKey:@"id"] intValue]];
           
           self.isLoggedIn = YES;
           
           [Lockbox setString:username forKey:kBarBooksSubscriptionUsername];
           [Lockbox setString:password forKey:kBarBooksSubscriptionUserPassword];
           
           [self checkSubscriptionForUser:user.userID];
           
           [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessfulNotification object:nil];
       } else {
           self.isLoggedIn = NO;
           [self displayError:@"Authentication Error" message:@"Please check your username and password."];
           
           [[NSNotificationCenter defaultCenter] postNotificationName:kLoginFailedNotification object:nil];
       }
       
   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       [[NSNotificationCenter defaultCenter] postNotificationName:kLoginFailedNotification object:error];
   }];
}

- (void) startRequestWithURL:(NSURL*)url
  completionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:success failure:failure];
    [operation start];
}

@end
