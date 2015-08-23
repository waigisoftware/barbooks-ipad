//
//  BBInvoiceDisbursementListViewController.m
//  barbooks-ipad
//
//  Created by Can on 17/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBInvoiceDisbursementListViewController.h"
#import "BBInvoiceDisbursementTableViewCell.h"
#import "Disbursement.h"

@interface BBInvoiceDisbursementListViewController ()

@end

@implementation BBInvoiceDisbursementListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _itemList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"invoiceDisbursementCell";
    BBInvoiceDisbursementTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    Disbursement *disbursement = [_itemList objectAtIndex:indexPath.row];
    cell.dateLabel.text = [disbursement.createdAt toShortDateFormat];
    cell.amountIncludeGstLabel.text = [disbursement.amountIncGst currencyAmount];
    cell.descriptionLabel.text = disbursement.classDisplayName;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

@end
