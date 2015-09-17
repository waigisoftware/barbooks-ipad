//
//  BFCustomer.h
//  barbooks-ipad
//
//  Created by Can on 17/09/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFCustomer : NSObject

@property (nonatomic, strong) NSString *customerId;
@property (nonatomic, strong) NSString *encryptionKey;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *credentials;

+ (BFCustomer *)customerFromJson:(NSDictionary *)json;

// JSON to create customer
- (NSDictionary *)createJson;
// JSON to update customer
- (NSDictionary *)updateJson;
// JSON to get customer/accounts/statements
- (NSDictionary *)customerIdAndEncryptionKeyJson;
// JSON of the object
- (NSDictionary *)json;

@end
