//
//  CostsAgreement.h
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BBManagedObject.h"

@class Matter;

@interface CostsAgreement : BBManagedObject

@property (nonatomic, retain) id agreementInformation;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) id disclosureInformation;
@property (nonatomic, retain) Matter *matter;

@end
