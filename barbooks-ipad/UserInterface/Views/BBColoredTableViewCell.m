//
//  BBColoredTableViewCell.m
//  barbooks-ipad
//
//  Created by Eric on 14/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBColoredTableViewCell.h"

@implementation BBColoredTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    [self setBackgroundColor:self.contentView.backgroundColor];
    [self.accessoryView setBackgroundColor:self.contentView.backgroundColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
}

@end
