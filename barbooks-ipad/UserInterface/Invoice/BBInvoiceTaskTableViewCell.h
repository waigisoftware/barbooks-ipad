//
//  BBInvoiceTaskTableViewCell.h
//  barbooks-ipad
//
//  Created by Can on 17/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBInvoiceTaskTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountIncludeGstLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end
