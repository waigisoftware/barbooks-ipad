//
//  BFCredential.m
//  barbooks-ipad
//
//  Created by Can on 17/09/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BFCredential.h"

@implementation BFCredential

+ (BFCredential *)credentialFromJson:(NSDictionary *)json {
    BFCredential *credential = nil;
    
    if (json) {
        credential.institution = [json objectForKey:@"institution"];
        credential.username = [json objectForKey:@"username"];
        credential.password = [json objectForKey:@"password"];
    }
    
    return credential;
}

- (NSDictionary *)json {
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    
    [json setNullSafeObject:self.institution forKey:@"institution"];
    [json setNullSafeObject:self.username forKey:@"username"];
    [json setNullSafeObject:self.password forKey:@"password"];
    
    return json;
}

@end
