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

@property UITableViewController *tableViewController;

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

#pragma mark - pull to refresh table

- (void)registerRefreshControlFor:(UITableView *)tableView withAction:(SEL)action
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // initiate a TableViewController for refreshControl
        if (!self.tableViewController) {
            self.tableViewController = [UITableViewController new];
            self.tableViewController.tableView = tableView;
        }
        
        // configure refreshControl
        if (!self.tableViewController.refreshControl) {
            self.tableViewController.refreshControl = [[UIRefreshControl alloc] init];
            self.tableViewController.refreshControl.backgroundColor = [UIColor whiteColor];
            self.tableViewController.refreshControl.tintColor = [UIColor blackColor];
            [self.tableViewController.refreshControl addTarget:self
                                                        action:action
                                              forControlEvents:UIControlEventValueChanged];
        }
    });
}

- (void)stopAndUpdateDateOnRefreshControl
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // stop refreshing
        [self.tableViewController.refreshControl endRefreshing];
        
        // format date and set to refreshControl
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [[NSDate date] toShortDateTimeFormat]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor grayColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.tableViewController.refreshControl.attributedTitle = attributedTitle;
        self.tableViewController.refreshControl.hidden = YES;
    });
}

- (BOOL)isRefreshControlRefreshing
{
    return self.tableViewController.refreshControl.isRefreshing;
}

@end
