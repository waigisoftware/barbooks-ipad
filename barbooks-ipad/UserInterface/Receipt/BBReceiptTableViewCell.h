//
//  BBReceiptTableViewCell.h
//  barbooks-ipad
//
//  Created by Can on 24/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBReceiptTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *receiptNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *paidAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *paidDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *invoiceNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *matterDescriptionLabel;

@end
