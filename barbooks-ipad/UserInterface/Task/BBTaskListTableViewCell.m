//
//  BBTaskListTableViewCell.m
//  barbooks-ipad
//
//  Created by Can on 23/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBTaskListTableViewCell.h"

@interface BBTaskListTableViewCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timerButtonWidthConstraint;

@end

@implementation BBTaskListTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
