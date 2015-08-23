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
    
    [self.taskNameLabel setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.accessoryView) {
        CGRect frame = self.accessoryView.frame;
        frame.origin.y = 0;
        [self.accessoryView setFrame:frame];
    }
}

- (void)setEditing:(BOOL)editing
{
    [super setEditing:editing];
    self.taskNameLabel.editable = !editing;
    self.taskNameLabel.selectable = !editing;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated ];
    self.taskNameLabel.editable = !editing;
    self.taskNameLabel.selectable = !editing;
    self.taskNameLabel.userInteractionEnabled = !editing;
    if (editing) {
        [self setSelectionStyle:UITableViewCellSelectionStyleDefault];
    } else {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
