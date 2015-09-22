//
//  BBExpenseTableViewCell.m
//  barbooks-ipad
//
//  Created by Can on 11/07/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBExpenseTableViewCell.h"

@implementation BBExpenseTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    [self.descriptionLabel setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
