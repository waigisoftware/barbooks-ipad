//
//  BBContactListViewController.m
//  barbooks-ipad
//
//  Created by Can on 20/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBContactListViewController.h"
#import "BBCreateSolicitorViewController.h"

@interface BBContactListViewController ()

//@property (weak, nonatomic) IBOutlet UIButton *editSolicitorButton;
//@property (weak, nonatomic) IBOutlet UIButton *addSolicitorButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *contactsView;
@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;

@end

@implementation BBContactListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBarButtons];
    [self registerRefreshControlFor:_contactsTableView withAction:@selector(updateContact:)];
    [self updateContact:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNavigationBarButtons {
    // add 'Add' & 'Delete' button
    UIImage *imageAdd = [[UIImage imageNamed:@"button_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *imageDelete = [[UIImage imageNamed:@"button_delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:imageAdd style:UIBarButtonItemStylePlain target:self action:@selector(onAddContact)];
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithImage:imageDelete style:UIBarButtonItemStylePlain target:self action:@selector(onDeleteContact)];
    self.navigationItem.rightBarButtonItems = @[deleteButton, addButton];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.solicitorList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"solicitorCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    Solicitor *solicitor = [self.solicitorList objectAtIndex:indexPath.row];
    cell.textLabel.text = [solicitor displayName];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate updateMatter:[self.solicitorList objectAtIndex:indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}

// show no empty cells
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

#pragma mark - Solicitor

- (void)popoverSolicitorViewWithSolicitor:(Solicitor *)solicitor {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BBCreateSolicitorViewController *createSolicitorViewController = [storyboard instantiateViewControllerWithIdentifier:StoryboardIdBBCreateSolicitorViewController];
    createSolicitorViewController.delegate = self;
    createSolicitorViewController.solicitor = solicitor;
    
    // pop it over
    UIPopoverController * popoverController = [[UIPopoverController alloc] initWithContentViewController:createSolicitorViewController];
    popoverController.delegate = self;
    popoverController.popoverContentSize = CGSizeMake(300, 500);
    [popoverController presentPopoverFromRect:self.view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark - IBAction

- (void)onAddContact {
    [self popoverSolicitorViewWithSolicitor:nil];
}

//- (IBAction)onEditContact:(id)sender {
//    [self popoverSolicitorViewWithSolicitor:_solicitor];
//}

- (void)onDeleteContact {
    
}

- (void)updateContact:(id)data {
//    if (data) {
        _solicitorList = [Contact MR_findAll];
//    }
    [_contactsTableView reloadData];
}

@end
