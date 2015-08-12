//
//  BBCreateSolicitorViewController.m
//  barbooks-ipad
//
//  Created by Can on 17/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBCreateSolicitorViewController.h"
#import "UIFloatLabelTextField+BBUtil.h"
#import "Solicitor.h"
#import "Contact.h"
#import "Address.h"
#import "Firm.h"

@interface BBCreateSolicitorViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *firstnameTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *lastnameTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *dxaddressTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *firmNameTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *faxTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *address1TextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *address2TextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *cityTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *postcodeTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *stateTextField;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *countryTextField;

- (IBAction)onCancel:(id)sender;
- (IBAction)onDone:(id)sender;

@end

@implementation BBCreateSolicitorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSolicitorIntoUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadSolicitorIntoUI {
    _titleLabel.text = self.solicitor ? @"Edit Solicitor" : @"New Solicitor";
    if (self.solicitor) {
        _firstnameTextField.text = self.solicitor.firstname;
        _lastnameTextField.text = self.solicitor.lastname;
        _dxaddressTextField.text = self.solicitor.dxaddress;
        _firmNameTextField.text = self.solicitor.firm.name;
        _emailTextField.text = self.solicitor.email;
        _phoneNumberTextField.text = self.solicitor.phonenumber;
        _faxTextField.text = self.solicitor.fax;
        _address1TextField.text = self.solicitor.address.streetLine1;
        _address2TextField.text = self.solicitor.address.streetLine2;
        _cityTextField.text = self.solicitor.address.city;
        _postcodeTextField.text = self.solicitor.address.zip;
        _stateTextField.text = self.solicitor.address.state;
        _countryTextField.text = self.solicitor.address.country;
    }
}

- (void)updateSolicitorFromUI {
    [[UIResponder currentFirstResponder] resignFirstResponder];
    
    if (!self.solicitor) {
        self.solicitor = [Solicitor MR_createEntity];
    }
    self.solicitor.firstname = _firstnameTextField.text;
    self.solicitor.lastname = _lastnameTextField.text;
    self.solicitor.dxaddress = _dxaddressTextField.text;
    self.solicitor.firm.name = _firmNameTextField.text;
    self.solicitor.email = _emailTextField.text;
    self.solicitor.phonenumber = _phoneNumberTextField.text;
    self.solicitor.fax = _faxTextField.text;
    self.solicitor.address.streetLine1 = _address1TextField.text;
    self.solicitor.address.streetLine2 = _address2TextField.text;
    self.solicitor.address.city = _cityTextField.text;
    self.solicitor.address.zip = _postcodeTextField.text;
    self.solicitor.address.state = _stateTextField.text;
    self.solicitor.address.country = _countryTextField.text;
}

#pragma mark - Button actions

- (IBAction)onCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onDone:(id)sender {
    // stop editing
    [self stopEditing];
    // validate
    if (_firstnameTextField.text.length == 0 || _lastnameTextField.text.length == 0) {
        [[[UIAlertView alloc]initWithTitle:@"Invalid Solicitor" message:@"Please input both Firstname and Lastname." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    // save
    [self updateSolicitorFromUI];
    [self.delegate updateContact:self.solicitor];
    // dismiss
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - resignFirstResponders and hide all popup views

- (void)stopEditing {
    [[UIResponder currentFirstResponder] resignFirstResponder];
    [self loadSolicitorIntoUI];
}

@end
