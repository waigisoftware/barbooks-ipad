//
//  BBMatterCategoryListViewController.m
//  barbooks-ipad
//
//  Created by Can on 23/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBMatterCategoryListViewController.h"
#import "BBTaskListViewController.h"
#import "BBExpenseListViewController.h"

@interface BBMatterCategoryListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation BBMatterCategoryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // user pressed back button in Navigation Bar
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [self.taskListViewController.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"matterCategoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
            cell.imageView.image = [UIImage imageNamed:@"icon_matter_list"];
            cell.textLabel.text = @"Tasks / Time Recording";
            break;
        case 1:
            cell.imageView.image = [UIImage imageNamed:@"icon_receipt_list"];
            cell.textLabel.text = @"Disbursements";
            break;
        case 2:
            cell.imageView.image = [UIImage imageNamed:@"icon_invoice_list"];
            cell.textLabel.text = @"Invoices";
            break;
        case 3:
            cell.imageView.image = [UIImage imageNamed:@"icon_statement_list"];
            cell.textLabel.text = @"Statements of Outstanding Fees";
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        switch (indexPath.row) {
            case 0: {
                NSLog(@"Tasks");
                [self showTasks];
                break;
            }
            case 1:
                NSLog(@"Disbursements");
                [self showExpenses];
                break;
            case 2:
                NSLog(@"Invoices");
                break;
            case 3:
                NSLog(@"Statements");
                break;
        }
}

- (void)showTasks {
    if (![[(UINavigationController *)[self.splitViewController detailViewController] topViewController] isKindOfClass:[BBTaskListViewController class]]) {
        [((UINavigationController *)[self.splitViewController detailViewController]) popToRootViewControllerAnimated:NO];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BBTaskListViewController *taskListViewController = [storyboard instantiateViewControllerWithIdentifier:StoryboardIdBBTaskListViewController];
        [(UINavigationController *)[self.splitViewController detailViewController] pushViewController:taskListViewController animated:NO];
        taskListViewController.matter = self.matter;
    }
}

- (void)showExpenses {
    if (![[(UINavigationController *)[self.splitViewController detailViewController] topViewController] isKindOfClass:[BBExpenseListViewController class]]) {
        [((UINavigationController *)[self.splitViewController detailViewController]) popToRootViewControllerAnimated:NO];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BBExpenseListViewController *expenseListViewController = [storyboard instantiateViewControllerWithIdentifier:StoryboardIdBBExpenseListViewController];
        [(UINavigationController *)[self.splitViewController detailViewController] pushViewController:expenseListViewController animated:NO];
        expenseListViewController.matter = self.matter;
    }
}

@end
