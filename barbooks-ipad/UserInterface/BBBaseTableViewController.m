//
//  BBBaseTableViewController.m
//  barbooks-ipad
//
//  Created by Can on 4/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBBaseTableViewController.h"
#import "NSDate+BBUtil.h"

@interface BBBaseTableViewController ()

@property (strong, nonatomic) NSArray *originalItemList;
@property (strong, nonatomic) NSArray *filteredItemList;

@end

@implementation BBBaseTableViewController

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
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - UITableViewDelegate

// show no empty cells
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

#pragma mark - TableView helper methods

- (NSIndexPath *)indexPathOfItem:(NSObject *)item {
    return [NSIndexPath indexPathForRow:[_originalItemList indexOfObject:item] inSection:0];
}

@end
