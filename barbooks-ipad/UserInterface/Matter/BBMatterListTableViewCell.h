//
//  BBMatterListTableViewCell.h
//  barbooks-ipad
//
//  Created by Can on 16/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBMatterListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *matterNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tasksUnbilledAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *invoicesOutstandingAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *payorNameLabel;

@end
