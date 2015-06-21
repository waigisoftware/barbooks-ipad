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
#import "BBContactListViewController.h"

@interface BBMatterViewController ()

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
    
    // set contact selection view
    _contactListViewController = [BBContactListViewController new];
    _contactListViewController.delegate = self;
    _contactsTableView.dataSource = _contactListViewController;
    _contactsTableView.delegate = _contactListViewController;
    _contactsView.hidden = YES;
    
    self.rateSortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES]];
    self.roundingStrings = [GlobalAttributes timerRoundingTypeStrings];
    
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
//    _solicitorTextField.text = _matter.solicitor.firstname;
    _openDateLabel.text = [_matter.date toShortDateFormat];
    _dueDateTextField.text = [_matter.dueDate stringValue];
    _taxedSwitch.on = [_matter.taxed boolValue];
    _taxTextField.text = _matter.tax ? [[_matter.tax decimalNumberByMultiplyingBy:[NSDecimalNumber oneHundred]] stringValue] : @"";
    
    [self updateSolicitor];
    
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
    _matter.date = [_openDateLabel.text fromShortDateFormatToDate];
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
- (void)setMatter:(Matter *)matter
{
    _matter = matter;
    [self loadMatterIntoUI];
    
//    [self updateSolicitorName];
//    [self updateAutocomplete];
    
//    if (self.editing && [matter.name isEqualToString:@"New Matter"]) {
//        [self performSelector:@selector(selectMatterTextField) withObject:nil afterDelay:0.01];
//    }
}

#pragma mark - Solicitor

- (void)updateSolicitor {
    _solicitorTextField.text = _matter.solicitor ? [_matter.solicitor displayName] : @"";
    _editSolicitorButton.hidden = !self.matter.solicitor;
    _contactListViewController.solicitorList = [Solicitor MR_findAll];
    [_contactsTableView reloadData];
    _contactsView.hidden = YES;
}

- (void)popoverSolicitorView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BBCreateSolicitorViewController *createSolicitorViewController = [storyboard instantiateViewControllerWithIdentifier:StoryboardIdBBCreateSolicitorViewController];
    createSolicitorViewController.delegate = self;
//    createSolicitorViewController.solicitor = self.matter.solicitor;
    
    UIPopoverController * popoverController = [[UIPopoverController alloc] initWithContentViewController:createSolicitorViewController];
    popoverController.delegate = self;
    popoverController.popoverContentSize = CGSizeMake(300, 500);
    [popoverController presentPopoverFromRect:_addSolicitorButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


#pragma mark IBActions

- (IBAction)onAddContact:(id)sender {
    [self popoverSolicitorView];
}

- (IBAction)onEditContact:(id)sender {
    [self popoverSolicitorView];
}

- (IBAction)onInput:(id)sender {
    [self updateMatterFromUI];
}

- (IBAction)onDatePicked:(id)sender {
    _openDateLabel.text = [_datePicker.date toShortDateFormat];
    [self updateAndSaveMatterWithUIChange];
}

- (IBAction)onBackgroundButton:(id)sender {
    [[UIResponder currentFirstResponder] resignFirstResponder];
    _datePickerContainerView.hidden = YES;
}

- (IBAction)onSelectContact:(id)sender {
    _contactsView.hidden = !_contactsView.hidden;
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

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self updateAndSaveMatterWithUIChange];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self updateMatterFromUI];
    return YES;
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
    [self loadMatterIntoUI];
}

@end

