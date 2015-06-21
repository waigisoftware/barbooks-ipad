//
//  GlobalAttributes.h
//  BarBooks
//
//  Created by Eric on 29/11/2014.
//  Copyright (c) 2014 Censea Software Corporation Pty Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalAttributes : NSObject

@property (strong) NSString *addMatterTooltip;
@property (strong) NSString *addReceiptTooltip;
@property (strong) NSString *addRateTooltip;
@property (strong) NSString *addExpenseTooltip;
@property (strong) NSString *addReportTooltip;
@property (strong) NSString *addTaskTooltip;
@property (strong) NSString *addDisbursementTooltip;
@property (strong) NSString *addInvoiceTooltip;
@property (strong) NSString *addSolicitorTooltip;
@property (strong) NSString *editDiscountTooltip;

@property (strong) NSString *editMatterTooltip;
@property (strong) NSString *editSolicitorTooltip;

@property (strong) NSString *deleteSelectionTooltip;
@property (strong) NSString *archiveSelectionTooltip;
@property (strong) NSString *unarchiveSelectedTooltip;

@property (strong) NSString *addCostsAgreementTooltip;
@property (strong) NSString *addVariationOfFeesTooltip;
@property (strong) NSString *addOutstandingFeesTooltip;
@property (strong) NSString *viewCostsAgreementTooltip;
@property (strong) NSString *viewVariationOfFeesTooltip;
@property (strong) NSString *viewOutstandingFeesTooltip;

@property (strong, readonly) NSArray *rateTypes;


+ (NSArray *)defaultNaturesOfBrief;
+ (NSArray *)accountingTypes;
- (NSArray *)expenseTypes;
+ (NSArray *)expenseCategories;
+ (NSArray *)timerRoundingTypes;
+ (NSArray *)timerRoundingTypeStrings;
+ (NSArray *)invoiceStatusTypes;
+ (NSArray *)taxExpenseTypes;
+ (NSArray *)periods;

@end
