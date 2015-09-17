//
//  BFCustomer.m
//  barbooks-ipad
//
//  Created by Can on 17/09/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BFCustomer.h"
#import "BFCredential.h"

@implementation BFCustomer

+ (BFCustomer *)customerFromJson:(NSDictionary *)json {
    BFCustomer *customer = nil;
    
    if (json) {
        customer.customerId = [json objectForKey:@"customerId"];
        customer.encryptionKey = [json objectForKey:@"encryptionKey"];
        customer.name = [json objectForKey:@"name"];
        customer.credentials = [self credentialsFromJson:[json objectForKey:@"credentials"]];
    }
    
    return customer;
}

+ (NSArray *)credentialsFromJson:(NSDictionary *)json {
    NSMutableArray *credentials = nil;
    if (json && ![json isKindOfClass:[NSNull class]] && json.count > 0) {
        credentials = [NSMutableArray new];
        
        for(id item in json) {
            [credentials addObject:[BFCredential credentialFromJson:item]];
        }
    }
    return credentials;
}

- (NSDictionary *)createJson {
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    
    [json setNullSafeObject:self.name forKey:@"name"];
//    NSMutableArray *credentialsJson = [NSMutableArray arrayWithCapacity:self.credentials.count];
//    for (BFCredential *credential in self.credentials) {
//        [credentialsJson addObject:credential.json];
//    }
    if (self.credentials && self.credentials.count > 0) {
        BFCredential *credential = [self.credentials objectAtIndex:0];
        [json setNullSafeObject:credential.json forKey:@"credentials"];
    }
    
    return json;
}

- (NSDictionary *)updateJson {
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    
    [json setNullSafeObject:self.customerId forKey:@"customerId"];
    [json setNullSafeObject:self.encryptionKey forKey:@"encryptionKey"];
    [json setNullSafeObject:self.name forKey:@"name"];
    if (self.credentials && self.credentials.count > 0) {
        BFCredential *credential = [self.credentials objectAtIndex:0];
        [json setNullSafeObject:credential.json forKey:@"credentials"];
    }
    
    return json;
}

- (NSDictionary *)customerIdAndEncryptionKeyJson {
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    
    [json setNullSafeObject:self.customerId forKey:@"customerId"];
    [json setNullSafeObject:self.encryptionKey forKey:@"encryptionKey"];
    
    return json;
}

- (NSDictionary *)json {
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    
    [json setNullSafeObject:self.customerId forKey:@"customerId"];
    [json setNullSafeObject:self.encryptionKey forKey:@"encryptionKey"];
    [json setNullSafeObject:self.name forKey:@"name"];
    NSMutableArray *credentialsJson = [NSMutableArray arrayWithCapacity:self.credentials.count];
    for (BFCredential *credential in self.credentials) {
        [credentialsJson addObject:credential.json];
    }
    [json setNullSafeObject:credentialsJson forKey:@"credentials"];
    
    return json;
}

@end
