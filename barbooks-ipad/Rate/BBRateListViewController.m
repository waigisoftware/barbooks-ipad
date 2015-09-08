//
//  BBRateListViewController.m
//  barbooks-ipad
//
//  Created by Can on 9/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBRateListViewController.h"
#import "Rate.h"
#import "BBRateViewController.h"

@interface BBRateListViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *ratesTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation BBRateListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setContentInset:UIEdgeInsetsMake(-35, 0, 0, 0)];
    //[self setupNavigationBarButtons];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)setAllowsEditing:(BOOL)allowsEditing
{
    _allowsEditing = allowsEditing;
    
    if (allowsEditing) {
        self.addButton.enabled = YES;
        self.addButton.style = UIBarButtonSystemItemAdd;
    } else {
        self.addButton.enabled = NO;
        self.addButton.title = @"";
    }
    
    self.tableView.editing = allowsEditing;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _ratesTableView.editing = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNavigationBarButtons {
    // add 'Add' & 'Delete' button
    UIImage *imageAdd = [[UIImage imageNamed:@"button_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *imageDelete = [[UIImage imageNamed:@"button_delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:imageAdd style:UIBarButtonItemStylePlain target:self action:@selector(onAddRate)];
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithImage:imageDelete style:UIBarButtonItemStylePlain target:self action:@selector(onDeleteRate)];
    self.navigationItem.rightBarButtonItems = @[deleteButton, addButton];
}

#pragma mark - IBAction

- (IBAction)onAddRate {
    
    [self pushRateViewWithRate:nil];
    [self.tableView reloadData];
}

- (void)onDeleteRate {
    _ratesTableView.editing = !_ratesTableView.editing;
}

#pragma mark - Rate UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    BOOL tableViewShouldBeHidden = self.matter.rates.count == 0;
    [self.tableView setHidden:tableViewShouldBeHidden];

    return self.matter.rates.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"rateCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    Rate *rate = [self.matter.ratesArray objectAtIndex:indexPath.row];
    cell.textLabel.text = rate.description;
    return cell;
}

#pragma mark - Rate UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self pushRateViewWithRate:[self.matter.ratesArray objectAtIndex:indexPath.row]];
    //[self popoverRateViewWithRate:[self.matter.ratesArray objectAtIndex:indexPath.row]];
}

// handle delete

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Rate *rateToDelete = [self.matter.ratesArray objectAtIndex:indexPath.row];
        [self.matter removeRatesObject:rateToDelete];
        [_ratesTableView reloadData];
    }
}

// show no empty cells
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

#pragma mark - Rates

- (void)pushRateViewWithRate:(Rate *)rate {
    [self performSegueWithIdentifier:BBSegueRateListToRateDetail sender:rate];
}

- (void)popoverRateViewWithRate:(Rate *)rate {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BBRateViewController *rateViewController = [storyboard instantiateViewControllerWithIdentifier:StoryboardIdBBRateViewController];
    rateViewController.delegate = self;
    rateViewController.rate = rate;
    rateViewController.matter = self.matter;
    
    // pop it over
    UIPopoverController * popoverController = [[UIPopoverController alloc] initWithContentViewController:rateViewController];
    popoverController.delegate = self;
    popoverController.popoverContentSize = CGSizeMake(300, 360);
    [popoverController presentPopoverFromRect:self.navigationController.navigationBar.frame
                                       inView:_ratesTableView
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
}

#pragma mark - BBRateDelegate

- (void)updateRate:(id)data {
    if (data) {
        NSMutableSet *mutableset = [NSMutableSet setWithSet:self.matter.rates];
        [mutableset addObject:data];
        self.matter.rates = mutableset;
    }
    [_ratesTableView reloadData];
}

#pragma mark - BBRateDelegate
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:BBSegueRateListToRateDetail]) {
        BBRateViewController *rateViewController = [segue destinationViewController];
        rateViewController.matter = self.matter;
        if (sender) {
            rateViewController.rate = sender;
        }
    }
}

@end
