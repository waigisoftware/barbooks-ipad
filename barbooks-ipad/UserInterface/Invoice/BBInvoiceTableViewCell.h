//
//  BBInvoiceTableViewCell.h
//  barbooks-ipad
//
//  Created by Can on 16/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBInvoiceTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *invoiceNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *outstandingAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *matterDescriptionLabel;

@end
