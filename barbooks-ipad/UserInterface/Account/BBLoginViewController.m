//
//  BBLoginViewController.m
//  barbooks-ipad
//
//  Created by Can on 15/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBLoginViewController.h"
#import "BBValidator.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "MBProgressHUD.h"
#import "Account.h"

@interface BBLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)onLogin:(id)sender;

@end

@implementation BBLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureRACOnLoginButton];
    
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([[BBCloudManager sharedManager] isLoggedIn]) {
        [self performSegueWithIdentifier:@"showMainApp" sender:self];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subscriptionUpdateSucceeded) name:kCouchbaseProfileFoundNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)subscriptionUpdateSucceeded {
    [self performSegueWithIdentifier:@"showMainApp" sender:self];
}

#pragma mark - IBAction

- (IBAction)onLogin:(id)sender {
   
    Account *account = [[BBAccountManager sharedManager] activeAccount];
    if (account && ![account.owner isEqualToString:_usernameTextField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Different User"
                                                        message:@"You are about to log in with a new user. This will remove the local data./n/nDo you want to proceed?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        [alert show];
    } else {
        [[MBProgressHUD showHUDAddedTo:self.view animated:YES] setLabelText:@"Logging in..."];
        [[BBCloudManager sharedManager] signinWithUsername:_usernameTextField.text password:_passwordTextField.text];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        [[MBProgressHUD showHUDAddedTo:self.view animated:YES] setLabelText:@"Logging in..."];
        NSArray *allObjects = [BBManagedObject MR_findAll];
        
        [[NSManagedObjectContext MR_rootSavingContext] MR_deleteObjects:allObjects];
        [[NSManagedObjectContext MR_rootSavingContext] MR_saveToPersistentStoreAndWait];
        
        [[BBCloudManager sharedManager] signinWithUsername:_usernameTextField.text password:_passwordTextField.text];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

- (IBAction)unwindToLoginViewController:(UIStoryboardSegue *)unwindSegue
{
    
}


#pragma mark - UI AlertViews

-(void) showLoginFailedAlert {
    [[[UIAlertView alloc] initWithTitle:@"Failed to login"
                                message:@"Please check your username and password."
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

#pragma mark - validation

- (void) configureRACOnLoginButton {
    RACSignal* signal =
    [RACSignal combineLatest:@[self.usernameTextField.rac_textSignal, self.passwordTextField.rac_textSignal]
                      reduce:^(NSString *username, NSString *password) {
                          return @(
                          [self isValidUsernameAndPassword]
                          );
                      }];
    
    [signal subscribeNext:^(NSNumber* isEnabled) {
        if (!isEnabled.boolValue) {
            [self.loginButton setAlpha:0.5];
        } else {
            [self.loginButton setAlpha:1];
        }
        [self.loginButton setEnabled:isEnabled.boolValue];
    }];
}

- (BOOL)isValidUsernameAndPassword {
    return self.usernameTextField.text.length > 0 && self.passwordTextField.text.length > 0;
}


@end
