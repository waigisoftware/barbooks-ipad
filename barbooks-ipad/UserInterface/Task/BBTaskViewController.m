//
//  BBTaskViewController.m
//  barbooks-ipad
//
//  Created by Can on 23/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBTaskViewController.h"
#import "UIFloatLabelTextField+BBUtil.h"

@interface BBTaskViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *taskNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *taskDateLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIView *datePickerContainerView;
@property (weak, nonatomic) IBOutlet UISwitch *taxedSwitch;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *rateTypeTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *rateAmountTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *rateUnitTextField;
@property (weak, nonatomic) IBOutlet UILabel *unitsLabel;
@property (weak, nonatomic) IBOutlet UIButton *timerButton;
@property (weak, nonatomic) IBOutlet UIButton *timerStartButton;
@property (weak, nonatomic) IBOutlet UIButton *timerPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *timerStopButton;

- (IBAction)onCalendar:(id)sender;
- (IBAction)onDatePicked:(id)sender;
- (IBAction)onTax:(id)sender;
- (IBAction)onSelectRateType:(id)sender;
- (IBAction)onTimer:(id)sender;
- (IBAction)onTimerStart:(id)sender;
- (IBAction)onTimerPause:(id)sender;
- (IBAction)onTimerStop:(id)sender;

@end

@implementation BBTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark IBActions

// Date picker
- (IBAction)onCalendar:(id)sender {
    _datePickerContainerView.hidden = !_datePickerContainerView.hidden;
    if (!_datePickerContainerView.hidden && !_taskDateLabel.text) {
        _datePicker.date = [_taskDateLabel.text fromShortDateFormatToDate];
    }
}

- (IBAction)onTax:(id)sender {
    self.task.taxed = [NSNumber numberWithBool:_taxedSwitch.on];
    [self.delegate updateTask:self.task];
}

- (IBAction)onSelectRateType:(id)sender {
}

- (IBAction)onTimer:(id)sender {
}

- (IBAction)onTimerStart:(id)sender {
}

- (IBAction)onTimerPause:(id)sender {
}

- (IBAction)onTimerStop:(id)sender {
}
@end
