//
//  TestNSDate+BBUtil.m
//  barbooks-ipad
//
//  Created by Can on 10/09/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSDate+BBUtil.h"
#import "PrefixHeader.pch"

@interface TestNSDate_BBUtil : XCTestCase

@end

@implementation TestNSDate_BBUtil

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFinancialYear {
    NSDate *now = [NSDate new];
    XCTAssertTrue(2016 == [now financialYear]);
    XCTAssertEqual(2016, [now financialYear]);
}



@end
