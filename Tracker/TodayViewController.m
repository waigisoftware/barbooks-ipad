//
//  TodayViewController.m
//  Tracker
//
//  Created by Eric on 23/09/2015.
//  Copyright © 2015 Censea. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "BBTimerAccessoryView.h"

#define kWClosedHeight   37.0
#define kWExpandedHeight 86.0

@interface TodayViewController () <NCWidgetProviding>

@property (weak, nonatomic) IBOutlet BBTimerAccessoryView *accessoryView;
@property (weak, nonatomic) IBOutlet UILabel *taskName;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *matterLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setPreferredContentSize:CGSizeMake(0.0, kWExpandedHeight)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDefaultsDidChange:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
    
    [self updateDetails];
}

- (void)userDefaultsDidChange:(NSNotification *)notification {
    [self updateDetails];
}

- (IBAction)timerButtonPressed:(id)sender {
    NSLog(@"");
}

- (IBAction)stopButtonPressed:(id)sender {
    NSLog(@"");
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)margins
{
    margins.bottom = 10.0;
    return margins;
}

- (void)updateDetails {
    NSLog(@"");
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"status"] integerValue] == 0) {
        [self.accessoryView showRunningTimer];
    } else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"status"] integerValue] == 1) {
        [self.accessoryView showPauseTimer];
    }
    int duration = [[[NSUserDefaults standardUserDefaults] objectForKey:@"duration"] intValue];
    int seconds = duration % 60;
    int minutes = (duration / 60) % 60;
    int hours = duration / 3600;

    
    _timeLabel.text = [NSString stringWithFormat:@"%02i:%02i:%02i", hours,minutes,seconds];
}

- (void)timerStopped {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    
    
    completionHandler(NCUpdateResultNewData);
}

@end
