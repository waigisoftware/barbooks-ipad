//
//  BBHomeViewController.m
//  barbooks-ipad
//
//  Created by Can on 6/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBHomeViewController.h"
#import "BBMatterListViewController.h"
#import "BBMatterViewController.h"


@interface BBHomeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *tasksOutstandingAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *invoicesOutstandingAmountLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)onCreateMatter:(id)sender;
- (IBAction)onCreateTask:(id)sender;
- (IBAction)onCreateInvoice:(id)sender;
- (IBAction)onCreateReceipt:(id)sender;
- (IBAction)onCreateExpense:(id)sender;

@end

@implementation BBHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tableView.dataSource = self;
    _tableView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - button actions

- (IBAction)onCreateMatter:(id)sender {
    Matter *newMatter = [Matter newInstanceWithDefaultValue];
    [self showMatters:newMatter];
}

- (IBAction)onCreateTask:(id)sender {
}

- (IBAction)onCreateInvoice:(id)sender {
}

- (IBAction)onCreateReceipt:(id)sender {
}

- (IBAction)onCreateExpense:(id)sender {
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1; break;
        case 1:
            return 3; break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"categoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case 0:
            cell.imageView.image = [UIImage imageNamed:@"icon_overview"];
            cell.textLabel.text = @"Overview";
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.imageView.image = [UIImage imageNamed:@"icon_matter_list"];
                    cell.textLabel.text = @"Matters";
                    break;
                case 1:
                    cell.imageView.image = [UIImage imageNamed:@"icon_receipt_list"];
                    cell.textLabel.text = @"Receipts";
                    break;
                case 2:
                    cell.imageView.image = [UIImage imageNamed:@"icon_expense_list"];
                    cell.textLabel.text = @"Expenses";
                    break;
            }
    }
    
    return cell;
}

#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            NSLog(@"Overview");
            break;
        case 1:
            switch (indexPath.row) {
                case 0: {
                    NSLog(@"Matters");
                    [self showMatters:nil];
                    break;
                }
                case 1:
                    NSLog(@"Receipts");
                    break;
                case 2:
                    NSLog(@"Expenses");
                    break;
            }
    }
}

//- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath

- (void)showMatters:(Matter *)matter {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BBMatterListViewController *matterListViewController = [storyboard instantiateViewControllerWithIdentifier:StoryboardIdBBMatterListViewController];
    BBMatterViewController *matterViewController = [storyboard instantiateViewControllerWithIdentifier:StoryboardIdBBMatterViewController];
    [(UINavigationController *)[self.splitViewController masterViewController] pushViewController:matterListViewController animated:YES];
    [(UINavigationController *)[self.splitViewController detailViewController] pushViewController:matterViewController animated:YES];
    matterListViewController.matter = matter;
    matterListViewController.matterViewController = matterViewController;
    matterViewController.matter = matter;
    matterViewController.matterListViewController = matterListViewController;
}

@end
