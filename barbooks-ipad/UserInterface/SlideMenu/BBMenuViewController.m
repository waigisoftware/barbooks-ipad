//
//  BBMenuViewController.m
//  barbooks-ipad
//
//  Created by Can on 1/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBMenuViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "AppDelegate.h"

@interface BBMenuViewController ()

@property (weak, nonatomic) IBOutlet UITableView *menuTableView;

@end

@implementation BBMenuViewController

NSInteger const EmptyTableViewCellIndex = 0;
NSInteger const MattersTableViewCellIndex = 1;
NSInteger const AboutTableViewCellIndex = 2;
NSInteger const LogoutTableViewCellIndex = 3;
NSInteger const LoginTableViewCellIndex = 4;

CGFloat const TableViewCellHeight = 60.00;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    _menuTableView.dataSource = self;
    _menuTableView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.hidden = [self shouldHideTableViewCellAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self shouldHideTableViewCellAtIndex:indexPath.row] ? 0.0 : TableViewCellHeight;
}

- (BOOL)shouldHideTableViewCellAtIndex:(NSInteger)index {
    BOOL isAuthorized = YES;
    if (isAuthorized) {
        return index == LoginTableViewCellIndex;
    } else {
        return !(index == AboutTableViewCellIndex || index == LoginTableViewCellIndex);
    }
}

@end
