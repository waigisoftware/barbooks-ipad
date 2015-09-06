//
//  Template.h
//  BarBooks
//
//  Created by Eric on 8/07/2015.
//  Copyright (c) 2015 Censea Software Corporation Pty Limited. All rights reserved.
//

#import "BBManagedObject.h"

typedef enum {
    BBTemplateTypeBlank,
    BBTemplateTypeCostsAgreement,
    BBTemplateTypeVariationOfFees,
    BBTemplateTypeInterestInvoice,
    BBTemplateTypeInvoice,
    BBTemplateTypeOutstandingFees,
    BBTemplateTypeReceipt,
    BBTemplateNumberOfTemplates
} BBTemplateType;

@class Account;

@interface Template : BBManagedObject

@property (nonatomic, retain) NSString * filepath;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * templateType;
@property (nonatomic, retain) Account *account;

@end
