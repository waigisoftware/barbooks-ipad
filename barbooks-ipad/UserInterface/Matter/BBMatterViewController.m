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
#import "BBModalDatePickerViewController.h"

@interface BBMatterViewController () <BBModalDatePickerViewControllerDelegate>
{
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
@property (weak, nonatomic) IBOutlet UILabel *agreementDateLabel;
//@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
//@property (weak, nonatomic) IBOutlet UIView *datePickerContainerView;
@property (weak, nonatomic) IBOutlet UITextField *dueDateTextField;
@property (weak, nonatomic) IBOutlet UISwitch *taxedSwitch;
@property (weak, nonatomic) IBOutlet UITextField *taxTextField;

@property (strong, nonatomic) BBModalDatePickerViewController *datePickerController;

@property (strong) NSString *solicitorName;
@property (strong) NSArray *rateSortDescriptors;
@property (strong) NSArray *roundingStrings;
@property (strong) NSArray *courtNames;
@property (strong) NSArray *registryNames;
@property (strong) NSArray *endClientNames;
@property (strong) NSArray *naturesOfBrief;

- (IBAction)onInput:(id)sender;
- (IBAction)onTax:(id)sender;
- (IBAction)onBackgroundButton:(id)sender;
- (IBAction)onSelectRoundRate:(id)sender;
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
    
    [self loadMatterIntoUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    _agreementDateLabel.text = [self.matter.costsAgreementDate toShortDateFormat];
    
    _dueDateTextField.text = [self.matter.dueDate stringValue];
    _taxedSwitch.on = [self.matter.taxed boolValue];
    _taxTextField.text = [self.matter.tax stringValue];
    
    [self updateSolicitor];
    
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
        self.matter.tax = [NSDecimalNumber decimalNumberWithString:_taxTextField.text];
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



// Date picker
- (void)showDatePickerWithDate:(NSDate*)date {
    if (!self.datePickerController) {
        self.datePickerController = [BBModalDatePickerViewController defaultPicker];
        [self.datePickerController.view setFrame:self.view.bounds];
        
        self.datePickerController.delegate = self;
    }
    
    [self.datePickerController.datePicker setDate:date];

    [self.view addSubview:self.datePickerController.view];
    [[UIApplication sharedApplication] resignFirstResponder];
    [self.datePickerController run];
}

- (void)datePickerControllerDone:(UIDatePicker *)datePicker
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    if (indexPath.row == 1) {
        self.matter.date = datePicker.date;
    } else {
        self.matter.costsAgreementDate = datePicker.date;
    }
    
    [self loadMatterIntoUI];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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

- (IBAction)onSelectContact:(id)sender {
    [self stopEditing];
    [self performSegueWithIdentifier:BBSegueMatterToContactList sender:self];
}

- (IBAction)onTax:(id)sender {
    _taxTextField.userInteractionEnabled = _taxedSwitch.on;
    [self updateAndSaveMatterWithUIChange];
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            [self showDatePickerWithDate:self.matter.date];
        } else if (indexPath.row == 2) {
            [self showDatePickerWithDate:self.matter.costsAgreementDate];
        }
    }
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
    [self loadMatterIntoUI];
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

