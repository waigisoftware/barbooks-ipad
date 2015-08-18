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
#import "BBMatterListViewController.h"
#import "Task.h"
#import "BBTimerAccessoryView.h"

@interface BBTaskListViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tasksTableView;

@property (strong, nonatomic) NSArray *originalItemList;
@property (strong, nonatomic) NSArray *filteredItemList;

@end

@implementation BBTaskListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // tableview
    _tasksTableView.dataSource = self;
    _tasksTableView.delegate = self;
    _tasksTableView.contentInset = UIEdgeInsetsMake(-28, 0, 0, 0);
    //[self registerRefreshControlFor:_tasksTableView withAction:@selector(fetchTasks)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // setup navigation bar and toolbar
    [self setupNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self fetchTasks];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNavigationBar {
    // title
    self.tabBarController.navigationItem.title = @"Tasks";
    
    // hide back button
    self.tabBarController.navigationItem.hidesBackButton = YES;
    
    // add 'Add' & 'Delete' button
    UIImage *imageAdd = [[UIImage imageNamed:@"button_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onEdit)];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:imageAdd style:UIBarButtonItemStylePlain target:self action:@selector(onAddTask)];
    self.tabBarController.navigationItem.rightBarButtonItems = @[addButton,editButton];
}

#pragma mark - Button actions

- (void)onAddTask {
    Task *newTask = [Task newInstanceOfMatter:self.matter];
    [self fetchTasks];
    [self.tasksTableView beginUpdates];
    [_tasksTableView insertRowsAtIndexPaths:@[[self indexPathOfTask:newTask]] withRowAnimation:UITableViewRowAnimationTop];
    //[_tasksTableView selectRowAtIndexPath:[self indexPathOfTask:newTask] animated:YES scrollPosition:UITableViewScrollPositionTop];
    [self.tasksTableView endUpdates];
    CGRect rect = [_tasksTableView rectForRowAtIndexPath:[self indexPathOfTask:newTask]];
    [self popoverTaskViewWithTask:newTask inRect:rect];
}

- (void)onDeleteTask {
    NSArray *selections = [self.tasksTableView indexPathsForSelectedRows];
    NSArray *tasks = self.matter.tasksArray;
    for (NSIndexPath *selection in selections) {
        [self.matter removeTasksObject:[tasks objectAtIndex:selection.row]];
    }
    [self fetchTasks];
    [self.tasksTableView beginUpdates];
    [self.tasksTableView deleteRowsAtIndexPaths:selections withRowAnimation:UITableViewRowAnimationTop];
    [self.tasksTableView endUpdates];
}

- (void)onEdit {
    if (self.tasksTableView.editing) {
        UIImage *imageAdd = [[UIImage imageNamed:@"button_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:imageAdd style:UIBarButtonItemStylePlain target:self action:@selector(onAddTask)];
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onEdit)];
        
        [self.tabBarController.navigationItem setRightBarButtonItems:@[addButton,editButton] animated:YES];
        
    } else {
        UIImage *imageDelete = [[UIImage imageNamed:@"button_delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIBarButtonItem *removeButton = [[UIBarButtonItem alloc] initWithImage:imageDelete style:UIBarButtonItemStylePlain target:self action:@selector(onDeleteTask)];
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onEdit)];
        
        [self.tabBarController.navigationItem setRightBarButtonItems:@[removeButton,editButton] animated:YES];
    }
    
    [self.tasksTableView setEditing:!self.tasksTableView.editing animated:YES];
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
        
        BBTimerAccessoryView *accView = [BBTimerAccessoryView cellAccessoryView];
        
        UIButton *button = accView.timerButton;
        [button setImage:[UIImage imageNamed:@"button_timer"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(timerButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
        UIButton *stopbutton = accView.stopButton;
        stopbutton.alpha = 0;
        [stopbutton setImage:[UIImage imageNamed:@"button_timer_stop"] forState:UIControlStateNormal];
        [stopbutton addTarget:self action:@selector(stopButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.accessoryView = accView;
        
        cell.taskTimeLabel.text = [task durationToFormattedString];
    } else {
        cell.accessoryView = nil;
        cell.taskTimeLabel.text = [NSString stringWithFormat:@"%@ %@", [task.units stringValue], [task.rate typeDescription]];
    }
    
    return cell;
}

- (void)timerButtonTapped:(id)sender event:(id)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tasksTableView];
    NSIndexPath *indexPath = [self.tasksTableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath != nil){
        [self tableView:self.tasksTableView accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}

- (void)stopButtonTapped:(id)sender event:(id)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tasksTableView];
    NSIndexPath *indexPath = [self.tasksTableView indexPathForRowAtPoint:currentTouchPosition];
    
    BBTaskListTableViewCell *cell = [self.tasksTableView cellForRowAtIndexPath:indexPath];
    BBTimerAccessoryView *accView = (BBTimerAccessoryView *)cell.accessoryView;
    
    
    CGRect accViewRect = accView.frame;
    accViewRect.size.height = [[BBTimerAccessoryView cellAccessoryView] frame].size.height;
    accViewRect.origin.y = cell.frame.size.height/2-accViewRect.size.height/2;
    [accView stopAnimatingTimer];
    
    [UIView animateWithDuration:0.6
                          delay:0
                        options:UIViewAnimationOptionLayoutSubviews|UIViewAnimationCurveEaseInOut
                     animations:^{
                         [accView setFrame:accViewRect];
                         [accView.stopButton setAlpha:0.0];
                     }
                     completion:^(BOOL finished) {

                     }];
}




#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    BBTaskListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    BBTimerAccessoryView *accView = (BBTimerAccessoryView *)cell.accessoryView;
    
    if ([[BBTaskTimer sharedInstance] currentTask]) {
        
    }
    CGRect accViewRect = accView.frame;
    accViewRect.origin.y = 0;
    accViewRect.size.height = cell.frame.size.height;
    [accView startAnimatingTimer];

    [UIView animateWithDuration:0.6
                          delay:0
                        options:UIViewAnimationOptionLayoutSubviews|UIViewAnimationCurveEaseInOut
                     animations:^{
                            [accView setFrame:accViewRect];
                            [accView.stopButton setAlpha:1.0];
                        }
                     completion:^(BOOL finished) {

                     }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.tasksTableView.editing) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        Task *task = [_filteredItemList objectAtIndex:indexPath.row];
        CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
        
        [self popoverTaskViewWithTask:task inRect:rect];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.tasksTableView.rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.tasksTableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self onDeleteTask];
    }
}

#pragma mark - TableView helper methods

- (NSIndexPath *)indexPathOfTask:(Task *)task {
    return [NSIndexPath indexPathForRow:[_originalItemList indexOfObject:task] inSection:0];
}

#pragma mark - Core data

- (void)fetchTasks {
//    _originalItemList = [Task MR_findAll];
    _originalItemList = self.matter.tasksArray;
    [self filterContentForSearchText:_searchBar.text scope:nil];
    
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

- (void)popoverTaskViewWithTask:(Task *)task inRect:(CGRect)rect {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BBTaskViewController *taskViewController = [storyboard instantiateViewControllerWithIdentifier:StoryboardIdBBTaskViewController];
    taskViewController.delegate = self;
    taskViewController.task = task;
    
    
    UINavigationController *navigationController =  [[UINavigationController alloc]
                                                     initWithRootViewController:taskViewController];
    // [navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    [navigationController.navigationBar setTintColor:[UIColor bbPrimaryBlue]];
    [navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor bbPrimaryBlue]}];
    [navigationController.navigationBar setTranslucent:YES];
    
    // CGRect rect = [self.tasksTableView rectForRowAtIndexPath:indexPath];
    // pop it over
    UIPopoverController * popoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
    popoverController.delegate = self;
    popoverController.popoverContentSize = CGSizeMake(350, 540);
    [popoverController presentPopoverFromRect:rect
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    
}

#pragma mark - BBTaskDelegate

- (void)updateTask:(id)data {
    [self fetchTasks];
    Task *task = data;
    // refresh matter list accordingly
    [self.matterListViewController fetchMatters];
    [self.tasksTableView beginUpdates];
    [self.tasksTableView reloadRowsAtIndexPaths:@[[self indexPathOfTask:task]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tasksTableView endUpdates];

}

#pragma mark - BBTaskTimer Control

- (void)startTimerWithTask:(Task*)task {
    [BBTaskTimer sharedInstance].currentTask = task;
    [[BBTaskTimer sharedInstance] start];
}

- (void)pauseTimer {
    [[BBTaskTimer sharedInstance] pause];
}

- (void)stopTimer {
    [[BBTaskTimer sharedInstance] stop];
}

@end
