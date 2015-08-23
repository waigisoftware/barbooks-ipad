//
//  BBInvoiceViewController.m
//  barbooks-ipad
//
//  Created by Can on 16/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBInvoiceViewController.h"
#import "BBInvoiceTaskListViewController.h"
#import "BBInvoiceDisbursementListViewController.h"
#import "RegularInvoice.h"
#import "InterestInvoice.h"

@interface BBInvoiceViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIView *detailsView;
@property (weak, nonatomic) IBOutlet UIView *tasksView;
@property (weak, nonatomic) IBOutlet UIView *disbursmentsView;
@property (weak, nonatomic) IBOutlet UITextField *invoiceNumberTextField;
@property (weak, nonatomic) IBOutlet UILabel *issueDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;

@property (weak, nonatomic) IBOutlet UITableView *taskTableView;
@property (weak, nonatomic) IBOutlet UITableView *disbursementTableView;

@property (strong, nonatomic) BBInvoiceTaskListViewController *taskListViewController;
@property (strong, nonatomic) BBInvoiceDisbursementListViewController *disbursementListViewController;

- (IBAction)onSegmentChange:(id)sender;
- (IBAction)onClose:(id)sender;

@end

@implementation BBInvoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // details view
    self.preferredContentSize = CGSizeMake(200, 200);
    [self loadInvoiceIntoUI];
    
    // tasks view
    _taskListViewController = [BBInvoiceTaskListViewController new];
    _taskTableView.dataSource = _taskListViewController;
    _taskTableView.delegate = _taskListViewController;
    if ([self.invoice isKindOfClass:[RegularInvoice class]]) {
        _taskListViewController.itemList = ((RegularInvoice *)self.invoice).tasks.allObjects;
    } else {
        _taskListViewController.itemList = [NSArray new];
    }
    
    // disbursements view
    _disbursementListViewController = [BBInvoiceDisbursementListViewController new];
    _disbursementTableView.dataSource = _disbursementListViewController;
    _disbursementTableView.delegate = _disbursementListViewController;
    if ([self.invoice isKindOfClass:[RegularInvoice class]]) {
        _disbursementListViewController.itemList = ((RegularInvoice *)self.invoice).disbursements.allObjects;
    } else {
        _disbursementListViewController.itemList = [NSArray new];
    }
    
    [self showSelectedView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI update

- (void)showSelectedView {
    _detailsView.hidden = (_segmentedControl.selectedSegmentIndex == 0) ? NO : YES;
    _tasksView.hidden = (_segmentedControl.selectedSegmentIndex == 1) ? NO : YES;
    _disbursmentsView.hidden = (_segmentedControl.selectedSegmentIndex == 2) ? NO : YES;
}

- (void)loadInvoiceIntoUI {
    // preselect detail segment
    _segmentedControl.selectedSegmentIndex = 0;
    _invoiceNumberTextField.text = _invoice.classDisplayName;
    _issueDateLabel.text = [_invoice.createdAt toShortDateFormat];
    _dueDateLabel.text = [_invoice.dueDate toShortDateFormat];
}

- (void)updateTaskFromUI {
    _invoice.classDisplayName = _invoiceNumberTextField.text;
}

#pragma mark - Actions

- (IBAction)onClose:(id)sender {
    [self.delegate updateInvoice:self.invoice];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onSegmentChange:(id)sender {
    [self showSelectedView];
}

@end
