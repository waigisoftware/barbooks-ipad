//
//  BBTaskViewController.m
//  barbooks-ipad
//
//  Created by Can on 23/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBTaskViewController.h"
#import "BBTaskTimer.h"
#import "NSString+BBUtil.h"

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
@property (weak, nonatomic) IBOutlet UIView *timerView;
@property (weak, nonatomic) IBOutlet UIButton *timerButton;
@property (weak, nonatomic) IBOutlet UIButton *timerStartButton;
@property (weak, nonatomic) IBOutlet UIButton *timerPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *timerStopButton;
@property (weak, nonatomic) IBOutlet UIView *rateTableViewContainerView;
@property (weak, nonatomic) IBOutlet UITableView *rateTableView;

@property (strong, nonatomic) NSObject *observer;

- (IBAction)onBackgroundButton:(id)sender;
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

BBDropDownListViewController *_dropDownListViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _titleLabel.text = _task ? @"Edit Task" : @"New Task";
    
    // setting delegates
    _taskNameTextField.delegate = self;
    _rateTypeTextField.delegate = self;
    _rateAmountTextField.delegate = self;
    _rateUnitTextField.delegate = self;
    
    // set Rate selection view
    _dropDownListViewController = [BBDropDownListViewController new];
    _dropDownListViewController.delegate = self;
    NSMutableArray *displayItemList = [NSMutableArray arrayWithCapacity:self.task.matter.rates.count];
    NSMutableArray *dataItemList = [NSMutableArray arrayWithCapacity:self.task.matter.rates.count];
    for (Rate *rate in self.task.matter.rates) {
//        [displayItemList addObject:[[Rate rateTypes] objectAtIndex:[rate.type intValue]]];
        [displayItemList addObject:rate.name];
        [dataItemList addObject:rate];
    }
    _dropDownListViewController.displayItemList = displayItemList;
    _dropDownListViewController.dataItemList = dataItemList;
    _rateTableView.dataSource = _dropDownListViewController;
    _rateTableView.delegate = _dropDownListViewController;
    [_rateTableView reloadData];
    _rateTableViewContainerView.hidden = YES;
    
    [self loadTaskIntoUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self addTaskTimerObserver];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
    [self stopEditing];
    [_delegate updateTask:_task];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Task value

- (void)loadTaskIntoUI {
    _taskNameTextField.text = _task.name;
    _taskDateLabel.text = [_task.date toShortDateFormat];
    _taxedSwitch.on = _task.isTaxed;
    _rateTypeTextField.text = [[Rate rateTypes] objectAtIndex:[_task.rate.type intValue]];
    _rateAmountTextField.text = _task.isTaxed ? [_task.rate.amountGst roundedAmount] : [_task.rate.amount roundedAmount];
    _unitsLabel.hidden = [_task hourlyRate];
    if ([_task hourlyRate]) {
        _rateUnitTextField.text = [_task durationToFormattedString];
        _timerView.hidden = NO;
    } else {
        _rateUnitTextField.text = [_task.units stringValue];
        [self onTimerStop:nil];
        _timerView.hidden = YES;
    }
}

- (void)updateTaskFromUI {
    _task.name = _taskNameTextField.text;
    _task.date = _datePicker.date;
    _task.taxed = [NSNumber numberWithBool:_taxedSwitch.on];
    [self resetRateAmountWithTax];
    if ([_task hourlyRate]) {
        // get time from timer
    } else {
        if ([_rateUnitTextField.text isNumeric]) {
            _task.units = [NSDecimalNumber decimalNumberWithString:_rateUnitTextField.text];
        }
    }
    // recalculate
    [_task recalculate];
}

- (void)resetRateAmountWithTax {
    if ([_rateAmountTextField.text isNumeric]) {
        if (_task.isTaxed) {
            _task.rate.amountGst = [NSDecimalNumber decimalNumberWithString:_rateAmountTextField.text];
            _task.rate.amount = [_task.rate.amountGst decimalNumberSubtractGST];
        } else {
            _task.rate.amount = [NSDecimalNumber decimalNumberWithString:_rateAmountTextField.text];
            _task.rate.amountGst = [_task.rate.amount decimalNumberAddGST];
        }
    }
}

#pragma mark - BBDropDownListDelegate

- (void)updateWithSelection:(id)data {
    Class dataClass = [data class];
    if (dataClass == [Rate class]) {
        // Rate picker
        Rate *selectedRate = data;
        [selectedRate copyValueToRate:_task.rate];
    }
    [self loadTaskIntoUI];
    _rateTableViewContainerView.hidden = YES;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self updateTaskFromUI];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self updateTaskFromUI];
    return YES;
}

#pragma mark - keyboards

- (void)stopEditing {
    [[UIResponder currentFirstResponder] resignFirstResponder];
    _datePickerContainerView.hidden = YES;
    _rateTableViewContainerView.hidden = YES;
    // update Task object
    [self updateTaskFromUI];
    // refresh UI
    [self loadTaskIntoUI];
}

#pragma mark IBActions

// Date picker
- (IBAction)onCalendar:(id)sender {
    _datePickerContainerView.hidden = !_datePickerContainerView.hidden;
    if (!_datePickerContainerView.hidden && !_taskDateLabel.text) {
        _datePicker.date = [_taskDateLabel.text fromShortDateFormatToDate];
    }
}

- (IBAction)onDatePicked:(id)sender {
    _taskDateLabel.text = [_datePicker.date toShortDateFormat];
    [self updateTaskFromUI];
}

- (IBAction)onTax:(id)sender {
    _task.taxed = [NSNumber numberWithBool:_taxedSwitch.on];
    [self resetRateAmountWithTax];
    [_task recalculate];
    [self.delegate updateTask:self.task];
}

- (IBAction)onSelectRateType:(id)sender {
    _rateTableViewContainerView.hidden = !_rateTableViewContainerView.hidden;
}

- (IBAction)onBackgroundButton:(id)sender {
    [self stopEditing];
}

- (IBAction)onTimer:(id)sender {
    [self onTimerStart:sender];
}

- (IBAction)onTimerStart:(id)sender {
    [BBTaskTimer sharedInstance].currentTask = self.task;
    [[BBTaskTimer sharedInstance] start];
    [self startPulsingButton:_timerStartButton];
    [self stopPulsingButton:_timerPauseButton];
}

- (IBAction)onTimerPause:(id)sender {
    [[BBTaskTimer sharedInstance] pause];
    [self startPulsingButton:_timerPauseButton];
    [self stopPulsingButton:_timerStartButton];
}

- (IBAction)onTimerStop:(id)sender {
    [[BBTaskTimer sharedInstance] stop];
    [self stopPulsingButton:_timerStartButton];
    [self stopPulsingButton:_timerPauseButton];
    [self pulsingButtonOnce:_timerStopButton];
}

- (void)startPulsingButton:(UIButton *)button {
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.duration = 2;
    scaleAnimation.repeatCount = HUGE_VAL;
    scaleAnimation.autoreverses = YES;
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1];
    scaleAnimation.toValue = [NSNumber numberWithFloat:2];
    
    [button.imageView.layer addAnimation:scaleAnimation forKey:@"scale"];
}

- (void)stopPulsingButton:(UIButton *)button {
    [button.imageView.layer removeAnimationForKey:@"scale"];
}

- (void)pulsingButtonOnce:(UIButton *)button {
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.duration = 1;
    scaleAnimation.repeatCount = 0;
    scaleAnimation.autoreverses = YES;
    scaleAnimation.fromValue = [NSNumber numberWithFloat:2];
    scaleAnimation.toValue = [NSNumber numberWithFloat:1];
    
    [button.imageView.layer addAnimation:scaleAnimation forKey:@"scale"];
}

#pragma mark - Observers
-(void) addTaskTimerObserver {
    __weak BBTaskViewController* weakSelf = self;
    self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:BBNotificationTaskTimerUpdate
                                                                      object:nil
                                                                       queue:[NSOperationQueue mainQueue]
                                                                  usingBlock:^(NSNotification *notification) {
                                                                      weakSelf.rateUnitTextField.text = [[BBTaskTimer sharedInstance].currentTask durationToFormattedString];
                                                                  }];
}

@end
