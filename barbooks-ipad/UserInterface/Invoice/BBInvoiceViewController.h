//
//  BBInvoiceViewController.h
//  barbooks-ipad
//
//  Created by Can on 16/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBBaseViewController.h"
#import "Invoice.h"
#import "BBInvoiceDelegate.h"
#import "BBDiscountDelegate.h"

@interface BBInvoiceViewController : BBBaseViewController <BBDiscountDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) Invoice *invoice;
@property (weak, nonatomic) id<BBInvoiceDelegate> delegate;

@end
