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
#import "BBRateViewController.h"

@interface BBMatterViewController () {
    NSMutableArray *_rates;
}

@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *natureOfBriefTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *courtNameTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *registryTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *endClientNameTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *referenceTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *solicitorTextField;
@property (weak, nonatomic) IBOutlet UILabel *openDateLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIView *datePickerContainerView;
@property (weak, nonatomic) IBOutlet UITextField *dueDateTextField;
@property (weak, nonatomic) IBOutlet UISwitch *taxedSwitch;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *taxTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *roundingTypePicker;
@property (weak, nonatomic) IBOutlet UITableView *ratesTableView;
@property (weak, nonatomic) IBOutlet UIButton *editSolicitorButton;
@property (weak, nonatomic) IBOutlet UIButton *addSolicitorButton;
@property (weak, nonatomic) IBOutlet UIView *contactsView;
@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *roundRateTextField;
@property (weak, nonatomic) IBOutlet UIView *roundRatePickerContainerView;

@property (strong) NSString *solicitorName;
@property (strong) NSArray *rateSortDescriptors;
@property (strong) NSArray *roundingStrings;
@property (strong) NSArray *courtNames;
@property (strong) NSArray *registryNames;
@property (strong) NSArray *endClientNames;
@property (strong) NSArray *naturesOfBrief;

- (IBAction)onInput:(id)sender;
- (IBAction)onSelectContact:(id)sender;
- (IBAction)onEditContact:(id)sender;
- (IBAction)onAddContact:(id)sender;
- (IBAction)onCalendar:(id)sender;
- (IBAction)onDatePicked:(id)sender;
- (IBAction)onTax:(id)sender;
- (IBAction)onBackgroundButton:(id)sender;
- (IBAction)onSelectRoundRate:(id)sender;
- (IBAction)onAddRate:(id)sender;
- (IBAction)onDeleteRate:(id)sender;

@end

@implementation BBMatterViewController

BBContactListViewController *_contactListViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
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
    _ratesTableView.dataSource = self;
    _ratesTableView.delegate = self;
    
    // set contact selection view
    _contactListViewController = [BBContactListViewController new];
    _contactListViewController.delegate = self;
    _contactsTableView.dataSource = _contactListViewController;
    _contactsTableView.delegate = _contactListViewController;
    _contactsView.hidden = YES;
    
    // set roundingType picker
    _roundingTypePicker.dataSource = self;
    _roundingTypePicker.delegate = self;
    
    [self loadMatterIntoUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIFloatLabelTextField setup
- (void)setupTextFields {
    [_nameTextField applyBottomBorderStyle];
}

#pragma mark - Matter value

- (void)loadMatterIntoUI {
    _nameTextField.text = _matter.name;
    _natureOfBriefTextField.text = _matter.natureOfBrief;
    _courtNameTextField.text = _matter.courtName;
    _registryTextField.text = _matter.registry;
    _endClientNameTextField.text = _matter.endClientName;
    _referenceTextField.text = _matter.reference;
    _openDateLabel.text = [_matter.date toShortDateFormat];
    _dueDateTextField.text = [_matter.dueDate stringValue];
    _taxedSwitch.on = [_matter.taxed boolValue];
    _taxTextField.text = _matter.tax ? [[_matter.tax decimalNumberByMultiplyingBy:[NSDecimalNumber oneHundred]] stringValue] : @"";
    if (self.matter.roundingType) {
        NSUInteger index = [[GlobalAttributes timerRoundingTypes] indexOfSameValueNumericObject:[NSDecimalNumber decimalNumberWithDecimal:[self.matter.roundingType decimalValue]]];
        [_roundingTypePicker selectRow:index inComponent:0 animated:YES];
        _roundRateTextField.text = [[GlobalAttributes timerRoundingTypeStrings] objectAtIndex:index];
    }
    
    [self updateSolicitor];
    [self updateRates];
    
    // refresh matter list accordingly
    [self.matterListViewController fetchMatters];
}

- (void)updateMatterFromUI {
    _matter.name = _nameTextField.text;
    _matter.natureOfBrief = _natureOfBriefTextField.text;
    _matter.courtName = _courtNameTextField.text;
    _matter.registry = _registryTextField.text;
    _matter.endClientName = _endClientNameTextField.text;
    _matter.reference = _referenceTextField.text;
    _matter.solicitor.firstname = _solicitorTextField.text;
    _matter.date = _datePicker.date;
    _matter.dueDate = [_dueDateTextField.text numberValue];
    _matter.taxed = [NSNumber numberWithBool:_taxedSwitch.on];
    if (_matter.taxed && [_taxTextField.text isNumeric]) {
        _matter.tax = [[NSDecimalNumber decimalNumberWithString:_taxTextField.text] decimalNumberByDividingBy:[NSDecimalNumber oneHundred]];
    } else {
        _matter.tax = nil;
    }
    
    // refresh matter list accordingly
    [self.matterListViewController fetchMatters];
}

#pragma mark - preset data

- (void)setMatter:(Matter *)matter {
    _matter = matter;
    [self loadMatterIntoUI];
}

#pragma mark - Solicitor

- (void)updateSolicitor {
    _solicitorTextField.text = _matter.solicitor ? [_matter.solicitor displayName] : @"";
    _editSolicitorButton.hidden = !self.matter.solicitor;
    _contactListViewController.solicitorList = [Solicitor MR_findAll];
    [_contactsTableView reloadData];
    _contactsView.hidden = YES;
}

- (void)popoverSolicitorViewWithSolicitor:(Solicitor *)solicitor {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BBCreateSolicitorViewController *createSolicitorViewController = [storyboard instantiateViewControllerWithIdentifier:StoryboardIdBBCreateSolicitorViewController];
    createSolicitorViewController.delegate = self;
    createSolicitorViewController.solicitor = solicitor;
    
    // pop it over
    UIPopoverController * popoverController = [[UIPopoverController alloc] initWithContentViewController:createSolicitorViewController];
    popoverController.delegate = self;
    popoverController.popoverContentSize = CGSizeMake(300, 500);
    [popoverController presentPopoverFromRect:_addSolicitorButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


#pragma mark IBActions

- (IBAction)onAddContact:(id)sender {
    [self popoverSolicitorViewWithSolicitor:nil];
}

- (IBAction)onEditContact:(id)sender {
    [self popoverSolicitorViewWithSolicitor:self.matter.solicitor];
}

- (IBAction)onInput:(id)sender {
    [self updateMatterFromUI];
}

- (IBAction)onDatePicked:(id)sender {
    _openDateLabel.text = [_datePicker.date toShortDateFormat];
//    [self updateAndSaveMatterWithUIChange];
    [self updateMatterFromUI];
}

- (IBAction)onBackgroundButton:(id)sender {
    [self stopEditing];
}

- (IBAction)onSelectRoundRate:(id)sender {
    BOOL hidden = _roundRatePickerContainerView.hidden;
    [self stopEditing];
    _roundRatePickerContainerView.hidden = !hidden;
}

- (IBAction)onSelectContact:(id)sender {
    BOOL hidden = _contactsView.hidden;
    [self stopEditing];
    _contactsView.hidden = !hidden;
}

// Date picker
- (IBAction)onCalendar:(id)sender {
    _datePickerContainerView.hidden = !_datePickerContainerView.hidden;
    if (!_datePickerContainerView.hidden && !_openDateLabel.text) {
        _datePicker.date = [_openDateLabel.text fromShortDateFormatToDate];
    }
}

- (IBAction)onTax:(id)sender {
    _taxTextField.userInteractionEnabled = _taxedSwitch.on;
    [self updateAndSaveMatterWithUIChange];
}

- (IBAction)onAddRate:(id)sender {
    [self popoverRateViewWithRate:nil];
}

- (IBAction)onDeleteRate:(id)sender {
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
        _matter.solicitor = data;
    }
    if (dataClass == [Rate class]) {
        // add new Rate
        NSMutableSet *set = [NSMutableSet setWithSet:_matter.rates];
        [set addObject:data];
        _matter.rates = set;
    }
    [self loadMatterIntoUI];
}

#pragma mark - resignFirstResponders and hide all popup views

- (void)stopEditing {
    [[UIResponder currentFirstResponder] resignFirstResponder];
    _datePickerContainerView.hidden = YES;
    _roundRatePickerContainerView.hidden = YES;
    [self loadMatterIntoUI];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _matter.rates.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"rateCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    Rate *rate = [_rates objectAtIndex:indexPath.row];
    cell.textLabel.text = rate.description;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self popoverRateViewWithRate:[_rates objectAtIndex:indexPath.row]];
}

// show no empty cells
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

#pragma mark - Rates

- (void)popoverRateViewWithRate:(Rate *)rate {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BBRateViewController *rateViewController = [storyboard instantiateViewControllerWithIdentifier:StoryboardIdBBRateViewController];
    rateViewController.delegate = self;
    rateViewController.rate = rate;
    
    // pop it over
    UIPopoverController * popoverController = [[UIPopoverController alloc] initWithContentViewController:rateViewController];
    popoverController.delegate = self;
    popoverController.popoverContentSize = CGSizeMake(300, 300);
    [popoverController presentPopoverFromRect:self.navigationController.navigationBar.frame
                                       inView:_ratesTableView
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
}

- (void)updateRates {
    _rates = [NSMutableArray arrayWithArray:[_matter.rates allObjects]];
    [_ratesTableView reloadData];
}

@end

