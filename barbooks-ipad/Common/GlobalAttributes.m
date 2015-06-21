//
//  GlobalAttributes.m
//  BarBooks
//
//  Created by Eric on 29/11/2014.
//  Copyright (c) 2014 Censea Software Corporation Pty Limited. All rights reserved.
//

#import "GlobalAttributes.h"
#import "Matter.h"
#import "Invoice.h"

@implementation GlobalAttributes


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.addMatterTooltip = NSLocalizedString(@"Add Matter", nil);
        self.addReceiptTooltip = NSLocalizedString(@"Add \n- Matter Receipt\n- General Receipt\n- Tax Refund", nil);
        self.addExpenseTooltip = NSLocalizedString(@"Add \n- General Expense\n- Tax Payment", nil);
        self.addReportTooltip = NSLocalizedString(@"Add \n- GST Report\n- Cashflow & Activity Statement\n- Year End Tax Report", nil);
        self.addInvoiceTooltip = NSLocalizedString(@"Add \n- Regular Invoice\n- Interest Invoice", nil);
        self.addRateTooltip = NSLocalizedString(@"Add Rate", nil);
        self.addSolicitorTooltip = NSLocalizedString(@"New Solicitor", nil);
        self.addDisbursementTooltip = NSLocalizedString(@"Add Disbursement", nil);
        self.addTaskTooltip = NSLocalizedString(@"Add Task", nil);
        self.editDiscountTooltip = NSLocalizedString(@"Edit Discount", nil);
        
        self.editMatterTooltip = NSLocalizedString(@"Edit Matter", nil);
        self.editSolicitorTooltip = NSLocalizedString(@"Edit Solicitor", nil);

        self.deleteSelectionTooltip = NSLocalizedString(@"Delete selected item(s)", nil);
        self.archiveSelectionTooltip = NSLocalizedString(@"Archive selected item(s)", nil);
        self.unarchiveSelectedTooltip = NSLocalizedString(@"Un-archive selected item(s)", nil);


        self.addCostsAgreementTooltip = NSLocalizedString(@"New Costs Agreement & Costs Disclosure (replaces old)", nil);
        self.addVariationOfFeesTooltip = NSLocalizedString(@"New Variation of Fees (replaces old)", nil);
        self.addOutstandingFeesTooltip = NSLocalizedString(@"New Statement of Outstanding Fees (replaces old)", nil);
        self.viewCostsAgreementTooltip = NSLocalizedString(@"View Costs Agreement & Costs Disclosure", nil);
        self.viewVariationOfFeesTooltip = NSLocalizedString(@"View Variation of Fees", nil);
        self.viewOutstandingFeesTooltip = NSLocalizedString(@"View Statement of Outstanding Fees", nil);

    }
    
    return self;
}


+ (NSArray *)defaultNaturesOfBrief
{
    return @[NSLocalizedString(@"advising and appearing", nil),
             NSLocalizedString(@"advising", nil),
             NSLocalizedString(@"appearing", nil),
             NSLocalizedString(@"advising on evidence", nil),
             ];
}

+ (NSArray *)accountingTypes
{
    return @[NSLocalizedString(@"accruals", nil),
             NSLocalizedString(@"cash", nil),
             ];
}

+ (NSArray *)periods
{
    return @[NSLocalizedString(@"Year", nil),
             NSLocalizedString(@"Quarter", nil),
             NSLocalizedString(@"Month", nil),
             ];
}

- (NSArray *)expenseTypes
{
    return @[NSLocalizedString(@"expense", nil),
             NSLocalizedString(@"capital", nil),
             ];
}

+ (NSArray *)taxExpenseTypes
{
    return @[NSLocalizedString(@"PAYG/Income Tax", nil),
             NSLocalizedString(@"GST/VAT", nil)];
}

+ (NSArray *)invoiceStatusTypes
{
    return @[NSLocalizedString(@"unpaid", nil),
             NSLocalizedString(@"paid", nil),
             ];
}

+ (NSArray *)timerRoundingTypes
{
    return @[[NSDecimalNumber decimalNumberWithString:@"6"],
             [NSDecimalNumber decimalNumberWithString:@"10"],
             [NSDecimalNumber decimalNumberWithString:@"15"],
             [NSDecimalNumber decimalNumberWithString:@"20"],
             ];
}

+ (NSArray *)timerRoundingTypeStrings
{
    return @[@" 6 min",
             @"10 min",
             @"15 min",
             @"20 min"
             ];
}

- (NSArray *)rateTypes
{
    return @[NSLocalizedString(@"RATE_TYPE_0", nil),
             NSLocalizedString(@"RATE_TYPE_1", nil),
             NSLocalizedString(@"RATE_TYPE_2", nil),
             NSLocalizedString(@"RATE_TYPE_3", nil),
             NSLocalizedString(@"RATE_TYPE_4", nil),
             NSLocalizedString(@"RATE_TYPE_5", nil),
             ];
}

+ (NSArray *)expenseCategories
{
    return @[NSLocalizedString(@"Insurance", nil),
             //NSLocalizedString(@"Office expenses", nil),
             NSLocalizedString(@"Floor fees", nil),
             NSLocalizedString(@"Printing and stationary", nil),
             NSLocalizedString(@"Travel/Car", nil),
             NSLocalizedString(@"Telephone/Internet", nil),
             NSLocalizedString(@"Professional subscriptions", nil),
             NSLocalizedString(@"Computer Expenses", nil),
             NSLocalizedString(@"Accounting/Bookkeeping fees", nil),
             NSLocalizedString(@"Bank/Finance charges", nil),
             NSLocalizedString(@"Devilling", nil),
             NSLocalizedString(@"Bar Assoc fees", nil),
             NSLocalizedString(@"Education fees", nil),
             NSLocalizedString(@"Books/ subscriptions", nil),
             NSLocalizedString(@"Other", nil),
             //NSLocalizedString(@"Conferences", nil),
             //NSLocalizedString(@"Meeting Expenses", nil),
             ];
}


@end
