//
//  BankfeedsSample.m
//  barbooks-ipad
//
//  Created by Can on 17/09/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BankfeedsSample.h"
#import "BankfeedsClient.h"

@implementation BankfeedsSample


#pragma mark - Bankfeeds

+ (void)bankfeedsRequests {
    
    // list institutions
    [[BankfeedsClient sharedInstance] institutionSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Institutions : %@", responseObject);
    }
                                                 failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Network error");
    }];
    
    /*
     NSDictionary *json = @{
     @"name":@"Can",
     @"credentials": @{
     @"institution": @"bank_of_statements",
     @"username": @"12345678",
     @"password": @"TestMyMoney"
     }
     };
     */
    // create an account for a customer
    __block BFCustomer *customer = [BFCustomer new];
    customer.name = @"Can Z";
    BFCredential *credential = [BFCredential new];
    credential.institution = @"bank_of_statements";
    credential.username = @"12345678";
    credential.password = @"TestMyMoney";
    customer.credentials = [NSArray arrayWithObject:credential];
    
    [[BankfeedsClient sharedInstance] createCustomer:customer
                                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                                 NSLog(@"New Customer : %@", responseObject);
                                                 if (responseObject) {
                                                     NSDictionary *json = (NSDictionary *)responseObject;
                                                     customer.customerId = [json objectForKey:@"customerId"];
                                                     customer.encryptionKey = [json objectForKey:@"encryptionKey"];
                                                 }
                                             }
                                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                 NSLog(@"Network error");
                                             }];
    
    /*
     NSDictionary *json = @{
     @"customerId": @"5d40333c-57a2-4f94-9036-d2b51bf49a5b",
     @"encryptionKey": @"cfdc/iOMGPH0azpfgdGdex/mjhwtMULgkFAP8mgb/2I=",
     @"name":@"Can Z",
     @"credentials": @{
     @"institution": @"bank_of_statements",
     @"username": @"12345678",
     @"password": @"TestMyMoney"
     }
     };
     */
    // update customer
    customer.name = @"Can Z";
    customer.customerId = @"588ca82e-5da6-4c11-b2db-c626ba36d4cd";
    customer.encryptionKey = @"4h0GhKX0LF9rmHD2DJla+mW327rG+WSKZhwVBt7asc4=";
    
    [[BankfeedsClient sharedInstance] updateCustomer:customer
                                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                                 NSLog(@"Updated Customer : %@", responseObject);
                                                 
                                                 if (responseObject) {
                                                     NSDictionary *json = (NSDictionary *)responseObject;
                                                     BOOL success = ([[[json objectForKey:@"success"] stringValue] compare:@"true"] == NSOrderedSame);
                                                     NSString *message = [json objectForKey:@"message"];
                                                     if (success) {
                                                         // update id and key
                                                         customer.customerId = [json objectForKey:@"customerId"];
                                                         customer.encryptionKey = [json objectForKey:@"encryptionKey"];
                                                     } else {
                                                         // show error
                                                         NSLog(@"result : %@", message);
                                                     }
                                                     customer.customerId = [json objectForKey:@"customerId"];
                                                     customer.encryptionKey = [json objectForKey:@"encryptionKey"];
                                                 }
                                                 
                                             }
                                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                 NSLog(@"Network error");
                                             }];
    
    /*
     NSDictionary *json = @{
     @"customerId": @"6e9f075f-0dc6-441e-8b11-90d7df39660f",
     @"encryptionKey": @"hqEth6O6ySH+jaAxTWtZabr4zjtzSNgEuTOvEdumnDk="
     };
     */
    // show customer
    [[BankfeedsClient sharedInstance] showCustomer:customer
                                           success:^(NSURLSessionDataTask *task, id responseObject) {
                                               NSLog(@"Show Customer : %@", responseObject);
                                               
                                               if (responseObject) {
                                                   NSDictionary *json = (NSDictionary *)responseObject;
                                                   customer = [BFCustomer customerFromJson:json];
                                               }
                                               
                                           }
                                           failure:^(NSURLSessionDataTask *task, NSError *error) {
                                               NSLog(@"Network error");
                                           }];
    
    /*
     NSDictionary *json = @{
     @"customerId": @"6e9f075f-0dc6-441e-8b11-90d7df39660f",
     @"encryptionKey": @"hqEth6O6ySH+jaAxTWtZabr4zjtzSNgEuTOvEdumnDk="
     };
     */
    // show accounts
    [[BankfeedsClient sharedInstance] accounts:customer
                                       success:^(NSURLSessionDataTask *task, id responseObject) {
                                           NSLog(@"Accounts : %@", responseObject);
                                       }
                                       failure:^(NSURLSessionDataTask *task, NSError *error) {
                                           NSLog(@"Network error");
                                       }];
    
    /*
     NSDictionary *json = @{
     @"customerId": @"6e9f075f-0dc6-441e-8b11-90d7df39660f",
     @"encryptionKey": @"hqEth6O6ySH+jaAxTWtZabr4zjtzSNgEuTOvEdumnDk="
     };
     */
    // show statements data
    [[BankfeedsClient sharedInstance] data:customer
                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                       NSLog(@"Bank Statements : %@", responseObject);
                                   }
                                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                                       NSLog(@"Network error");
                                   }];
}


@end
