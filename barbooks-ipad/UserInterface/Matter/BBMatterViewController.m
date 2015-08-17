//
//  BBMatterViewController.m
//  barbooks-ipad
//
//  Created by Can on 8/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBMatterViewController.h"
#import "BBMatterListViewController.h"
#import "BBCreateSolicitorViewController.h"
#import "UIFloatLabelTextField+BBUtil.h"
#import "BBCoreDataManager.h"
#import "GlobalAttributes.h"
#import "Account.h"
#import "Solicitor.h"
#import "Invoice.h"
#import "Firm.h"
#import "Rate.h"
#import "BBContactListViewController.h"
#import "BBRateListViewController.h"
#import "NSDate+BBUtil.h"

@interface BBMatterViewController () {
//    NSMutableArray *_rates;
}

//@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *natureOfBriefTextField;
@property (weak, nonatomic) IBOutlet UITextField *courtNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *registryTextField;
@property (weak, nonatomic) IBOutlet UITextField *endClientNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *referenceTextField;
@property (weak, nonatomic) IBOutlet UITextField *solicitorTextField;
@property (weak, nonatomic) IBOutlet UILabel *openDateLabel;
//@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
//@property (weak, nonatomic) IBOutlet UIView *datePickerContainerView;
@property (weak, nonatomic) IBOutlet UITextField *dueDateTextField;
@property (weak, nonatomic) IBOutlet UISwitch *taxedSwitch;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *taxTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *roundingTypePicker;
//@property (weak, nonatomic) IBOutlet UITableView *ratesTableView;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *roundRateTextField;
@property (weak, nonatomic) IBOutlet UIView *roundRatePickerContainerView;

// date picker
@property (weak, nonatomic) IBOutlet UIView *calendarContainerView;
@property (weak, nonatomic) IBOutlet UILabel *pickedDateDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickedDateMonthLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickedDateDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickedDateYearLabel;
@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;
@property (weak, nonatomic) IBOutlet JTCalendarContentView *calendarContentView;
@property (strong, nonatomic) JTCalendar *calendar;

@property (strong) NSString *solicitorName;
@property (strong) NSArray *rateSortDescriptors;
@property (strong) NSArray *roundingStrings;
@property (strong) NSArray *courtNames;
@property (strong) NSArray *registryNames;
@property (strong) NSArray *endClientNames;
@property (strong) NSArray *naturesOfBrief;

- (IBAction)onInput:(id)sender;
- (IBAction)onSelectContact:(id)sender;
//- (IBAction)onEditContact:(id)sender;
//- (IBAction)onAddContact:(id)sender;
- (IBAction)onCalendar:(id)sender;
//- (IBAction)onDatePicked:(id)sender;
- (IBAction)onTax:(id)sender;
- (IBAction)onBackgroundButton:(id)sender;
- (IBAction)onSelectRoundRate:(id)sender;
//- (IBAction)onAddRate:(id)sender;
//- (IBAction)onDeleteRate:(id)sender;
- (IBAction)onCancelPickDate:(id)sender;
- (IBAction)onConfirmPickDate:(id)sender;
- (IBAction)onViewRates:(id)sender;
- (IBAction)onCancel:(id)sender;
- (IBAction)onSave:(id)sender;
- (IBAction)onArchive:(id)sender;
- (IBAction)onDelete:(id)sender;

@end

@implementation BBMatterViewController

BBContactListViewController *_contactListViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"Matter";
    
    // setting delegates
    _nameTextField.delegate = self;
    _natureOfBriefTextField.delegate = self;
    _courtNameTextField.delegate = self;
    _registryTextField.delegate = self;
    _endClientNameTextField.delegate = self;
    _referenceTextField.delegate = self;
    _solicitorTextField.delegate = self;
    _dueDateTextField.delegate = self;
    _taxTextField.delegate = self;
    [self.tableView setContentInset:UIEdgeInsetsMake(-35, 0, 0, 0)];
//    _ratesTableView.dataSource = self;
//    _ratesTableView.delegate = self;
    
    // set contact selection view
//    _contactListViewController = [BBContactListViewController new];
//    _contactListViewController.delegate = self;
//    _contactsTableView.dataSource = _contactListViewController;
//    _contactsTableView.delegate = _contactListViewController;
//    _contactsView.hidden = YES;
    
    // set roundingType picker
    _roundingTypePicker.dataSource = self;
    _roundingTypePicker.delegate = self;
    
    // set calendar picker
    [self setupCalendarPickingView];
    
    [self loadMatterIntoUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [self.calendar repositionViews];
}

#pragma mark - UI Setup

- (void)setupCalendarPickingView {
    // set calendar picker
    self.calendar = [JTCalendar new];
    self.calendar.calendarAppearance.dayCircleColorSelected = [UIColor bbPrimaryBlue];
    [self.calendar setMenuMonthsView:self.calendarMenuView];
    [self.calendar setContentView:self.calendarContentView];
    [self.calendar setDataSource:self];
}

//- (void)coverViewIfNeeded {
//    [self.view bringSubviewToFront:_coverView];
//    _coverView.hidden = self.matter ? YES : NO;
//}

#pragma mark - Matter value

- (void)loadMatterIntoUI {
//    [self coverViewIfNeeded];
    if (!self.matter) {
        return;
    }
    
    _nameTextField.text = self.matter.name;
    _natureOfBriefTextField.text = self.matter.natureOfBrief;
    _courtNameTextField.text = self.matter.courtName;
    _registryTextField.text = self.matter.registry;
    _endClientNameTextField.text = self.matter.endClientName;
    _referenceTextField.text = self.matter.reference;
    _openDateLabel.text = [self.matter.date toShortDateFormat];
    // calendar
    //_calendar.currentDate = self.matter.date;
    //_calendar.currentDateSelected = self.matter.date;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kJTCalendarDaySelected" object:self.matter.date];
    
    _dueDateTextField.text = [self.matter.dueDate stringValue];
    _taxedSwitch.on = [self.matter.taxed boolValue];
    _taxTextField.text = self.matter.tax ? [[self.matter.tax decimalNumberByMultiplyingBy:[NSDecimalNumber oneHundred]] stringValue] : @"";
    if (self.matter.roundingType) {
        NSUInteger index = [[GlobalAttributes timerRoundingTypes] indexOfSameValueNumericObject:[NSDecimalNumber decimalNumberWithDecimal:[self.matter.roundingType decimalValue]]];
        [_roundingTypePicker selectRow:index inComponent:0 animated:YES];
        _roundRateTextField.text = [[GlobalAttributes timerRoundingTypeStrings] objectAtIndex:index];
    }
    
    [self updateSolicitor];
//    [self updateRates];
    
    // refresh matter list accordingly
//    [self.matterListViewController fetchMatters];
}

- (void)updateMatterFromUI {
    self.matter.name = _nameTextField.text;
    self.matter.natureOfBrief = _natureOfBriefTextField.text;
    self.matter.courtName = _courtNameTextField.text;
    self.matter.registry = _registryTextField.text;
    self.matter.endClientName = _endClientNameTextField.text;
    self.matter.reference = _referenceTextField.text;
//    self.matter.solicitor.firstname = _solicitorTextField.text;
    self.matter.date = [_openDateLabel.text fromShortDateFormatToDate];
    self.matter.dueDate = [_dueDateTextField.text numberValue];
    self.matter.taxed = [NSNumber numberWithBool:_taxedSwitch.on];
    if (self.matter.taxed && [_taxTextField.text isNumeric]) {
        self.matter.tax = [[NSDecimalNumber decimalNumberWithString:_taxTextField.text] decimalNumberByDividingBy:[NSDecimalNumber oneHundred]];
    } else {
        self.matter.tax = nil;
    }
    
    // refresh matter list accordingly
//    [self.matterListViewController fetchMatters];
}

- (void)updateSolicitor {
    _solicitorTextField.text = self.matter.solicitor ? [self.matter.solicitor displayName] : @"";
//    _editSolicitorButton.hidden = !self.matter.solicitor;
//    self.solicitorList = [Solicitor MR_findAll];
//    [_contactsTableView reloadData];
//    _contactsView.hidden = YES;
}

#pragma mark - preset data

- (void)setMatter:(Matter *)matter {
    [super setMatter:matter];
    [self loadMatterIntoUI];
}


#pragma mark IBActions

- (IBAction)onInput:(id)sender {
    [self updateMatterFromUI];
}

//- (IBAction)onDatePicked:(id)sender {
//    _openDateLabel.text = [_datePicker.date toShortDateFormat];
//    [self updateMatterFromUI];
//}

- (IBAction)onBackgroundButton:(id)sender {
    [self stopEditing];
}

- (IBAction)onSelectRoundRate:(id)sender {
    BOOL hidden = _roundRatePickerContainerView.hidden;
    [self stopEditing];
    _roundRatePickerContainerView.hidden = !hidden;
}

- (IBAction)onSelectContact:(id)sender {
    [self stopEditing];
    [self performSegueWithIdentifier:BBSegueMatterToContactList sender:self];
}

// Date picker
- (IBAction)onCalendar:(id)sender {
    _calendarContainerView.hidden = !_calendarContainerView.hidden;
    if (!_calendarContainerView.hidden && !_openDateLabel.text) {
        [self.calendar setCurrentDate:self.matter.date];
//        _datePicker.date = [_openDateLabel.text fromShortDateFormatToDate];
    }
}

- (IBAction)onTax:(id)sender {
    _taxTextField.userInteractionEnabled = _taxedSwitch.on;
    [self updateAndSaveMatterWithUIChange];
}

- (IBAction)onCancelPickDate:(id)sender {
    _calendarContainerView.hidden = YES;
}

- (IBAction)onConfirmPickDate:(id)sender {
    _calendarContainerView.hidden = YES;
    self.matter.date = _calendar.currentDateSelected;
    [self loadMatterIntoUI];
}

- (IBAction)onViewRates:(id)sender {
    [self stopEditing];
    [self performSegueWithIdentifier:BBSegueMatterToRateList sender:self];
}

- (IBAction)onCancel:(id)sender {
    
}

- (IBAction)onSave:(id)sender {
    [self refreshMatterList];
}

- (IBAction)onArchive:(id)sender {
    self.matter.archived = [NSNumber numberWithBool:YES];
    [self refreshMatterList];
}

- (IBAction)onDelete:(id)sender {
    [self.matter MR_deleteEntity];
    [self refreshMatterList];
}

- (void)refreshMatterList {
    [self stopEditing];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.matterListViewController fetchMatters];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self updateAndSaveMatterWithUIChange];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self updateMatterFromUI];
    return YES;
}

#pragma mark - Rounding Type UIPickerViewDataSource and UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [GlobalAttributes timerRoundingTypes].count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[GlobalAttributes timerRoundingTypeStrings] objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.matter.roundingType = [[GlobalAttributes timerRoundingTypes] objectAtIndex:row];
    [self loadMatterIntoUI];
}

#pragma mark - Core Data

- (void)updateAndSaveMatterWithUIChange {
    [self updateMatterFromUI];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [localContext save:nil];
    } completion:^(BOOL success, NSError *error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark - BBMatterDelegate

- (void)updateMatter:(id)data {
    Class dataClass = [data class];
    if (dataClass == [Solicitor class]) {
        self.matter.solicitor = data;
    }
//    if (dataClass == [Rate class]) {
//        // add new Rate
//        NSMutableSet *set = [NSMutableSet setWithSet:self.matter.rates];
//        [set addObject:data];
//        self.matter.rates = set;
//    }
    [self loadMatterIntoUI];
}

#pragma mark - resignFirstResponders and hide all popup views

- (void)stopEditing {
    [[UIResponder currentFirstResponder] resignFirstResponder];
    [self onCancelPickDate:nil];
    _roundRatePickerContainerView.hidden = YES;
    [self loadMatterIntoUI];
}

#pragma mark - OpenDate JTCalendarDataSource

- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date {
    return NO;
}

- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date {
    NSLog(@"%@", date);
    [self updateCalendarContainerViewWithDate:date];
}

#pragma mark - Date methods

- (void)updateCalendarContainerViewWithDate:(NSDate *)date {
    _pickedDateDayLabel.text = [date weekday];
    _pickedDateMonthLabel.text = [date month];
    _pickedDateDateLabel.text = [date day];
    _pickedDateYearLabel.text = [date year];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:BBSegueMatterToContactList]) {
        BBContactListViewController *contactListViewController = [segue destinationViewController];
        contactListViewController.matter = self.matter;
        contactListViewController.delegate = self;
    }
    if ([[segue identifier] isEqualToString:BBSegueMatterToRateList]) {
        BBRateListViewController *rateListViewController = [segue destinationViewController];
        rateListViewController.matter = self.matter;
        rateListViewController.allowsEditing = YES;
    }
}

@end

