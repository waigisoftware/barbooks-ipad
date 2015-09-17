//
//  BankfeedsClient.m
//  barbooks-ipad
//
//  Created by Can on 16/09/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BankfeedsClient.h"

const NSString *baseURL = @"https://apitest.bankfeeds.com.au/v1/";
const NSString *apiKey = @"caaa4280-54f4-4e61-bc80-b137e8fc5712";

@implementation BankfeedsClient

+ (instancetype)sharedInstance {
    static BankfeedsClient *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [BankfeedsClient new];
    });
    
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
        self.sessionManager.requestSerializer = [self createBankfeedsRequestSerializer];
    }
    return self;
}

- (AFJSONRequestSerializer*)createBankfeedsRequestSerializer {
    AFJSONRequestSerializer* requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:apiKey forHTTPHeaderField:@"X-API-KEY"];
    
    return requestSerializer;
}

- (void)institutionSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                   failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSString *url = [NSString stringWithFormat:@"institutions"];
    
    [self.sessionManager GET:url
                  parameters:nil
                     success:success
                     failure:failure];
}

- (void)createCustomer:(BFCustomer *)customer
               success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
               failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSString *url = [NSString stringWithFormat:@"customer/create"];
    
    [self.sessionManager POST:url
                   parameters:customer.createJson
                      success:success
                      failure:failure];
}

- (void)updateCustomer:(BFCustomer *)customer
               success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
               failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSString *url = [NSString stringWithFormat:@"customer/update"];
    
    [self.sessionManager POST:url
                   parameters:customer.updateJson
                      success:success
                      failure:failure];
}

- (void)showCustomer:(BFCustomer *)customer
             success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
             failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSString *url = [NSString stringWithFormat:@"customer/get"];
    
    [self.sessionManager POST:url
                   parameters:customer.customerIdAndEncryptionKeyJson
                      success:success
                      failure:failure];
}

- (void)accounts:(BFCustomer *)customer
         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
         failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSString *url = [NSString stringWithFormat:@"customer/accounts"];
    
    [self.sessionManager POST:url
                   parameters:customer.customerIdAndEncryptionKeyJson
                      success:success
                      failure:failure];
}

- (void)data:(BFCustomer *)customer
     success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
     failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSString *url = [NSString stringWithFormat:@"customer/data"];
    
    [self.sessionManager POST:url
                   parameters:customer.customerIdAndEncryptionKeyJson
                      success:success
                      failure:failure];
}

@end
