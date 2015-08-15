//
//  BBSubscriptionManager.m
//  barbooks-ipad
//
//  Created by Can on 15/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBSubscriptionManager.h"
#import <AFNetworking/AFNetworking.h>
#import <Lockbox/Lockbox.h>
#import "DateTimeUtility.h"

@interface BBSubscriptionManager ()

@property (strong) NSMutableData *responseData;

@end

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
           NSString *userId = [NSString stringWithFormat:@"%i",[[[responseObject objectForKey:@"user"] objectForKey:@"id"] intValue]];
           
           self.isLoggedIn = YES;
           
           [Lockbox setString:username forKey:kBarBooksSubscriptionUsername];
           [Lockbox setString:password forKey:kBarBooksSubscriptionUserPassword];
           
           [self checkSubscriptionForUser:userId];
           
//           [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessfulNotification object:nil];
       } else {
           self.isLoggedIn = NO;
           
           [[NSNotificationCenter defaultCenter] postNotificationName:kLoginFailedNotification object:@{@"message" : [responseObject objectForKey:@"error"]}];
       }
       
   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       [[NSNotificationCenter defaultCenter] postNotificationName:kLoginFailedNotification object:@{@"message" : [error description]}];
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

- (void) checkSubscriptionForUser:(NSString*)userID {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *urlString = [NSString stringWithFormat:@"%@%@%@",kWooCommerceAPI,kGetCustomerURL,userID];
        
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", kWoocommerceKey, kWoocommerceSecret];
        NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];

        NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64Encoding]];
        
        [request setValue:authValue forHTTPHeaderField:@"Authorization"];
        
        NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
        if (urlConnection) {
            self.responseData = [NSMutableData data];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kSubscriptionUpdateFailedNotification object:@{@"message" : @"Failed to get subscription, please try again."}];
        }
    });
}

- (BOOL)subscriptionValid {
    return ![self daysOverdue] && ([self subscriptionStatus] == BBSubscriptionStatusActive);
}

- (NSInteger)daysOverdue
{
    NSInteger daysOverdue = 0;
    if ([self subscriptionEndDate]) {
        NSDate *subscriptionEndDate = [DateTimeUtility dateByAddingDays:14 toDate:[self subscriptionEndDate]] ;
        
        NSComparisonResult result = [DateTimeUtility compareDate:subscriptionEndDate toDate:[NSDate date]];
        
        if (result == NSOrderedAscending) {
            daysOverdue = [DateTimeUtility daysBetweenDate:[NSDate date] andDate:[self subscriptionEndDate]];
        } else if (result == NSOrderedDescending)
        {
            daysOverdue = -[DateTimeUtility daysBetweenDate:[NSDate date] andDate:[self subscriptionEndDate]];
        }
    }
    
    return daysOverdue;
}

- (NSDate *)subscriptionEndDate
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSubscriptionEndDate];
}

- (BBSubscriptionStatus)subscriptionStatus
{
    NSNumber *status = [[NSUserDefaults standardUserDefaults] objectForKey:kSubscriptionActive];
    
    if (status) {
        return status.intValue;
    }
    
    return 0;
}

- (void)logout
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSubscriptionEndDate];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSubscriptionActive];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSubscriptionLastChecked];
    
    [Lockbox setString:nil forKey:kBarBooksSubscriptionUsername];
    [Lockbox setString:nil forKey:kBarBooksSubscriptionUserPassword];
    self.isLoggedIn = NO;
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                         options:kNilOptions
                                                           error:&error];
    NSLog(@"Subscription Info : %@\n", json);
    if ([json objectForKey:@"customer"]) {
        NSInteger timestamp = [[[json objectForKey:@"customer"] objectForKey:@"subscription_expiration_timestamp"] integerValue] ;
        NSDate *expiration = [NSDate dateWithTimeIntervalSince1970:timestamp];
        NSNumber *status = [[json objectForKey:@"customer"] objectForKey:@"subscription_status"];
        
        [[NSUserDefaults standardUserDefaults] setObject:expiration forKey:kSubscriptionEndDate];
        [[NSUserDefaults standardUserDefaults] setObject:status forKey:kSubscriptionActive];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kSubscriptionLastChecked];
        
        if ([self subscriptionValid]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kSubscriptionUpdateSucceededNotification object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kSubscriptionUpdateFailedNotification object:@{@"message" : @"Your subscription is expired, please renew and retry"}];
        }
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSubscriptionUpdateFailedNotification object:@{@"message" : [error description]}];
}

@end
