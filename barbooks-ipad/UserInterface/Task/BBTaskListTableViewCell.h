//
//  BBTaskListTableViewCell.h
//  barbooks-ipad
//
//  Created by Can on 23/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBTaskListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *taskNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalFeesExcludeGSTLabel;
@property (weak, nonatomic) IBOutlet UILabel *slashLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalFeesIncludeGSTLabel;
@property (weak, nonatomic) IBOutlet UILabel *includeGSTLabel;
@property (weak, nonatomic) IBOutlet UILabel *matterDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *taskDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *taskTimeLabel;

@end
