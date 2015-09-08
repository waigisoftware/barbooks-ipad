//
//  BBInvoiceDisbursementTableViewCell.h
//  barbooks-ipad
//
//  Created by Can on 17/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBInvoiceDisbursementTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountIncludeGstLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end
