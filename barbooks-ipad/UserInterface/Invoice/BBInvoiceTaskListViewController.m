//
//  BBInvoiceTaskListViewController.m
//  barbooks-ipad
//
//  Created by Can on 17/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBInvoiceTaskListViewController.h"
#import "BBInvoiceTaskTableViewCell.h"
#import "Task.h"
#import "Rate.h"

@interface BBInvoiceTaskListViewController ()

@end

@implementation BBInvoiceTaskListViewController

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
    static NSString *reuseIdentifier = @"invoiceTaskCell";
    BBInvoiceTaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    Task *task = [_itemList objectAtIndex:indexPath.row];
    cell.dateLabel.text = [task.createdAt toShortDateFormat];
    cell.unitLabel.text = task.rate.typeDescription;
    cell.amountIncludeGstLabel.text = [task.totalFeesIncGst currencyAmount];
    cell.descriptionLabel.text = task.name;
    
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
