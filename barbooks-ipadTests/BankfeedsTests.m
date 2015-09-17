//
//  BankfeedsTests.m
//  barbooks-ipad
//
//  Created by Can on 16/09/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BankFeedsClient.h"

@interface BankfeedsTests : XCTestCase

@end

@implementation BankfeedsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInstitution {
//    [[BankfeedsClient sharedInstance] institutionSuccess:^(NSDictionary *dict) {
//        NSLog(@"%@", [dict description]);
//        XCTAssertNotNil(dict);
//    } fail:^(NSError *error) {
//        NSLog(@"%@", error.description);
//        XCTAssertNil(error);
//    }];
}

@end
