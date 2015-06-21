//
//  Solicitor.m
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "Solicitor.h"
#import "Matter.h"


@implementation Solicitor

@dynamic isFirmOnly;
@dynamic firm;
@dynamic matters;

- (NSNumber *)isFirmOnly
{
    BOOL isFirmOnly = self.firm && (self.firstname == nil || self.firstname.length == 0) &&  (self.lastname == nil || self.lastname.length == 0);
    
    return @(isFirmOnly);
}

- (NSString *)displayName {
    if (self.firstname && self.lastname) {
        return [NSString stringWithFormat:@"%@, %@", self.lastname, self.firstname];
    } else {
        return [NSString stringWithFormat:@"%@", self.firm.name];
    }
}

@end
