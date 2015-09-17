//
//  BankfeedsClient.h
//  barbooks-ipad
//
//  Created by Can on 16/09/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "BFCustomer.h"
#import "BFCredential.h"

@interface BankfeedsClient : NSObject

@property(strong) AFHTTPSessionManager* sessionManager;

+ (instancetype)sharedInstance;

- (void)institutionSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                   failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (void)createCustomer:(BFCustomer *)customer
               success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
               failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (void)updateCustomer:(BFCustomer *)customer
               success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
               failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (void)showCustomer:(BFCustomer *)customer
             success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
             failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (void)accounts:(BFCustomer *)customer
         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
         failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (void)data:(BFCustomer *)customer
     success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
     failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@end
