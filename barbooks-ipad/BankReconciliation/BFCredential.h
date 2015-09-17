//
//  BFCredential.h
//  barbooks-ipad
//
//  Created by Can on 17/09/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFCredential : NSObject

@property (nonatomic, strong) NSString *institution;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

+ (BFCredential *)credentialFromJson:(NSDictionary *)json;

- (NSDictionary *)json;

@end
