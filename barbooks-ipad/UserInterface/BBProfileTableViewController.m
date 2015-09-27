//
//  BBProfileTableViewController.m
//  barbooks-ipad
//
//  Created by Eric on 25/09/2015.
//  Copyright © 2015 Censea. All rights reserved.
//

#import "BBProfileTableViewController.h"
#import "Account.h"
#import "Address.h"

@interface BBProfileTableViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *firstnameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastnameTextField;
@property (weak, nonatomic) IBOutlet UITextField *dxTextField;
@property (weak, nonatomic) IBOutlet UITextField *businessnumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *chambersTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *faxCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *faxNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *streetLine1TextField;
@property (weak, nonatomic) IBOutlet UITextField *streetLine2TextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *postCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *stateTextField;
@property (weak, nonatomic) IBOutlet UITextField *countryTextField;

@end

@implementation BBProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self loadUIFromModel];
}

- (void)loadUIToModel
{
    
    // only update entries, that have changed to prevent unnecessary updates of the cloud
    Account *account = [BBAccountManager sharedManager].activeAccount;
    if (![account.firstname isEqualToString:_firstnameTextField.text]) account.firstname = _firstnameTextField.text;
    if (![account.lastname isEqualToString:_lastnameTextField.text]) account.lastname = _lastnameTextField.text;
    if (![account.dxaddress isEqualToString:_dxTextField.text]) account.dxaddress = _dxTextField.text;
    if (![account.businessnumber isEqualToString:_businessnumberTextField.text]) account.businessnumber = _businessnumberTextField.text;
    if (![account.chambername isEqualToString:_chambersTextField.text]) account.chambername = _chambersTextField.text;
    if (![account.email isEqualToString:_emailTextField.text]) account.email = _emailTextField.text;
    if (![account.areacodePhone isEqualToString:_phoneCodeTextField.text]) account.areacodePhone = _phoneCodeTextField.text;
    if (![account.areacodeFax isEqualToString:_faxCodeTextField.text]) account.areacodeFax = _faxCodeTextField.text;
    if (![account.phonenumber isEqualToString:_phoneNumberTextField.text]) account.phonenumber = _phoneNumberTextField.text;
    if (![account.fax isEqualToString:_faxNumberTextField.text]) account.fax = _faxNumberTextField.text;
    
    if (account.address) {
        if (![account.address.streetLine1 isEqualToString:_streetLine1TextField.text]) account.address.streetLine1 = _streetLine1TextField.text;
        if (![account.address.streetLine2 isEqualToString:_streetLine2TextField.text]) account.address.streetLine2 = _streetLine2TextField.text;
        if (![account.address.city isEqualToString:_cityTextField.text]) account.address.city = _cityTextField.text;
        if (![account.address.zip isEqualToString:_postCodeTextField.text]) account.address.zip = _postCodeTextField.text;
        if (![account.address.state isEqualToString:_stateTextField.text]) account.address.state = _stateTextField.text;
        if (![account.address.country isEqualToString:_countryTextField.text]) account.address.country = _countryTextField.text;
    }
    if ([account.managedObjectContext hasChanges]) {
        [account.managedObjectContext MR_saveToPersistentStoreAndWait];
    }
}

- (void)loadUIFromModel
{
    Account *account = [BBAccountManager sharedManager].activeAccount;
    _firstnameTextField.text = account.firstname;
    _lastnameTextField.text = account.lastname;
    _dxTextField.text = account.dxaddress;
    _businessnumberTextField.text = account.businessnumber;
    _chambersTextField.text = account.chambername;
    _emailTextField.text = account.email;
    _phoneCodeTextField.text = account.areacodePhone;
    _faxCodeTextField.text = account.areacodeFax;
    _phoneNumberTextField.text = account.phonenumber;
    _faxNumberTextField.text = account.fax;
    if (account.address) {
        _streetLine1TextField.text = account.address.streetLine1;
        _streetLine2TextField.text = account.address.streetLine2;
        _cityTextField.text = account.address.city;
        _postCodeTextField.text = account.address.zip;
        _stateTextField.text = account.address.state;
        _countryTextField.text = account.address.country;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self loadUIToModel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//
//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
