//
//  BBModalDatePickerViewController.m
//  barbooks-ipad
//
//  Created by Eric on 20/08/2015.
//  Copyright © 2015 Censea. All rights reserved.
//

#import "BBModalDatePickerViewController.h"

@interface BBModalDatePickerViewController ()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *datePickerBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *datePickerHeightConstraint;
@property (strong, nonatomic) IBOutlet UIView *backgroundView;

@end

@implementation BBModalDatePickerViewController

+ (id)defaultPicker
{
    BBModalDatePickerViewController *pickerController = [[BBModalDatePickerViewController alloc] initWithNibName:@"BBModalDatePickerViewController" bundle:[NSBundle mainBundle]];
    return pickerController;
    
}

- (void)run
{
//    [self.view setFrame:view.bounds];
//    [view addSubview:self.view];
    
    self.backgroundView.alpha = 0;
    self.datePickerBottomConstraint.constant = -self.datePickerHeightConstraint.constant;
    [self.view layoutIfNeeded];
    
    self.datePickerBottomConstraint.constant = 0;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.backgroundView.alpha = 1.0;
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

- (void)close
{
    self.datePickerBottomConstraint.constant = -self.datePickerHeightConstraint.constant;

    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.backgroundView.alpha = 0.0;
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [self.view removeFromSuperview];
                     }];
}

- (IBAction)onDone:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(datePickerControllerDone:)]) {
        [self.delegate datePickerControllerDone:self.datePicker];
    }
    [self close];
}

- (IBAction)onCancel:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(datePickerControllerCancelled:)]) {
        [self.delegate datePickerControllerCancelled:self.datePicker];
    }
    [self close];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
