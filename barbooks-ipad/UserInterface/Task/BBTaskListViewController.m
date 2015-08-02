//
//  BBTaskListViewController.m
//  barbooks-ipad
//
//  Created by Can on 23/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBTaskListViewController.h"
#import "BBTaskListTableViewCell.h"
#import "BBTaskViewController.h"
#import "Task.h"

@interface BBTaskListViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tasksTableView;

@property (strong, nonatomic) NSArray *originalItemList;
@property (strong, nonatomic) NSArray *filteredItemList;

@end

@implementation BBTaskListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // hide back button
    self.navigationItem.hidesBackButton = YES;
    
    // add 'Add' & 'Delete' button
    UIImage *imageAdd = [[UIImage imageNamed:@"button_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *imageDelete = [[UIImage imageNamed:@"button_delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:imageAdd style:UIBarButtonItemStylePlain target:self action:@selector(onAddTask)];
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithImage:imageDelete style:UIBarButtonItemStylePlain target:self action:@selector(onDeleteTask)];
    self.navigationItem.rightBarButtonItems = @[deleteButton, addButton];
    
    // tableview
    _tasksTableView.dataSource = self;
    _tasksTableView.delegate = self;
    [self registerRefreshControlFor:_tasksTableView withAction:@selector(fetchTasks)];
    
    [self fetchTasks];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button actions

- (void)onAddTask {
    Task *newTask = [Task newInstanceOfMatter:self.matter];
    [self fetchTasks];
    [_tasksTableView selectRowAtIndexPath:[self indexPathOfTask:newTask] animated:YES scrollPosition:UITableViewScrollPositionTop];
    [self popoverTaskViewWithTask:newTask inCell:nil];
}

- (void)onDeleteTask {
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _filteredItemList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"taskCell";
    BBTaskListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    Task *task = [_filteredItemList objectAtIndex:indexPath.row];
    cell.taskNameLabel.text = task.name;
    cell.totalFeesExcludeGSTLabel.text = [task.totalFeesExGst currencyAmount];
    cell.totalFeesIncludeGSTLabel.text = [task.totalFeesIncGst currencyAmount];
    cell.slashLabel.hidden = !task.isTaxed;
    cell.includeGSTLabel.hidden = !task.isTaxed;
    cell.totalFeesIncludeGSTLabel.hidden = !task.isTaxed;
    cell.matterDescriptionLabel.text = task.matter.name;
    cell.taskDateLabel.text = [task.date toShortDateFormat];
    if ([task hourlyRate]) {
        cell.taskTimeLabel.text = [task durationToFormattedString];
    } else {
        cell.taskTimeLabel.text = [NSString stringWithFormat:@"%@ %@", [task.units stringValue], [task.rate typeDescription]];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Task *task = [_filteredItemList objectAtIndex:indexPath.row];
    [self popoverTaskViewWithTask:task inCell:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

#pragma mark - TableView helper methods

- (NSIndexPath *)indexPathOfTask:(Task *)task {
    return [NSIndexPath indexPathForRow:[_originalItemList indexOfObject:task] inSection:0];
}

#pragma mark - Core data

- (void)fetchTasks {
    _originalItemList = [Task MR_findAll];
    [self filterContentForSearchText:_searchBar.text scope:nil];
    [_tasksTableView reloadData];
    [self stopAndUpdateDateOnRefreshControl];
}

#pragma mark - override

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    if (searchText && [searchText length] > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchText];
        _filteredItemList = [_originalItemList filteredArrayUsingPredicate:predicate];
    } else {
        _filteredItemList = _originalItemList;
    }
}

- (void)popoverTaskViewWithTask:(Task *)task inCell:(UITableViewCell *)cell {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BBTaskViewController *taskViewController = [storyboard instantiateViewControllerWithIdentifier:StoryboardIdBBTaskViewController];
    taskViewController.delegate = self;
    taskViewController.task = task;
    
    // pop it over
    UIPopoverController * popoverController = [[UIPopoverController alloc] initWithContentViewController:taskViewController];
    popoverController.delegate = self;
    popoverController.popoverContentSize = CGSizeMake(500, 500);
    [popoverController presentPopoverFromRect:self.navigationController.navigationBar.frame
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
}

#pragma mark - BBTaskDelegate

- (void)updateTask:(id)data {
    [self fetchTasks];
}

@end
