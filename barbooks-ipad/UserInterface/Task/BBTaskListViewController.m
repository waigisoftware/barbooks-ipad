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

@interface BBTaskListViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tasksTableView;

@property (strong, nonatomic) NSArray *originalItemList;
@property (strong, nonatomic) NSArray *filteredItemList;

@end

@implementation BBTaskListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerUpdated:) name:kTimerUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerStopped:) name:kTimerDeactivatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerPaused:) name:kTimerPausedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerResumed:) name:kTimerResumedNotification object:nil];

    // tableview
    _tasksTableView.dataSource = self;
    _tasksTableView.delegate = self;
    _tasksTableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
    _tasksTableView.estimatedRowHeight = _tasksTableView.rowHeight;
    _tasksTableView.rowHeight = UITableViewAutomaticDimension;
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [_tasksTableView insertRowsAtIndexPaths:@[[self indexPathOfTask:newTask]] withRowAnimation:UITableViewRowAnimationTop];
    
    NSIndexPath *indexPath = [self indexPathOfTask:newTask];
    CGRect rect = [_tasksTableView rectForRowAtIndexPath:indexPath];
    rect.origin.y += _tasksTableView.contentInset.top;
    
    BBTaskListTableViewCell *cell = [_tasksTableView cellForRowAtIndexPath:indexPath];
    [cell.taskNameLabel becomeFirstResponder];
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
        
        BBTimerAccessoryView *accView = [BBTimerAccessoryView cellAccessoryViewWithOwner:self];
        
        UIButton *button = accView.timerButton;
        [button setImage:[UIImage imageNamed:@"button_timer"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(timerButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
        UIButton *stopbutton = accView.stopButton;
        stopbutton.alpha = 0;
        [stopbutton setImage:[UIImage imageNamed:@"button_timer_stop"] forState:UIControlStateNormal];
        [stopbutton addTarget:self action:@selector(stopButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.accessoryView = accView;
        
        if ([[BBTaskTimer sharedInstance] currentTask] == task) {
            [self expandTimerForCell:cell animated:NO];
            if ([[BBTaskTimer sharedInstance] active]) {
                [accView showRunningTimer];
            } else {
                [accView showPauseTimer];
            }
        }
        
        
        cell.taskTimeLabel.text = [task durationToFormattedString];
    } else {
        
        cell.accessoryView = nil;
        [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
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
        
        BBTaskListTableViewCell *cell = [_tasksTableView cellForRowAtIndexPath:indexPath];
        BBTimerAccessoryView *accView = (BBTimerAccessoryView *)cell.accessoryView;
        
        if ([[BBTaskTimer sharedInstance] active]) {
            [accView showPauseTimer];
            [self pauseTimer];
        } else {
            [self expandTimerForCell:cell animated:YES];
            
            [accView showRunningTimer];
            [self startTimerWithTask:[self.filteredItemList objectAtIndex:indexPath.row]];
        }
    }
}

- (void)stopButtonTapped:(id)sender event:(id)event{
    [self stopTimer];
}

- (IBAction)infoButtonPressed:(UIButton*)sender event:(UIEvent*)event {
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tasksTableView];
    NSIndexPath *indexPath = [self.tasksTableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath != nil){
        
        [self popoverTaskViewWithTask:[self.filteredItemList objectAtIndex:indexPath.row] inRect:sender.frame inView:[self.tasksTableView cellForRowAtIndexPath:indexPath].accessoryView];
    }
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    CGRect popRect = CGRectMake(cell.frame.origin.x + cell.contentView.frame.size.width, cell.frame.size.height/2.0, 1, 1);

    [self popoverTaskViewWithTask:[self.filteredItemList objectAtIndex:indexPath.row] inRect:popRect inView:cell];

    
}

- (void)expandTimerForCell:(UITableViewCell*)cell animated:(BOOL)animated
{
    BBTimerAccessoryView *accView = (BBTimerAccessoryView *)cell.accessoryView;
    UIView *innerView = [accView.subviews objectAtIndex:0];
    [innerView setTranslatesAutoresizingMaskIntoConstraints:YES];
    CGRect accViewRect = accView.bounds;
    
    
    if (animated) {
        [UIView animateWithDuration:0.6
                              delay:0
                            options:UIViewAnimationOptionLayoutSubviews|UIViewAnimationCurveEaseInOut
                         animations:^{
                             [innerView setFrame:accViewRect];
                             [accView.stopButton setAlpha:1.0];
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    } else {
        [innerView setFrame:accViewRect];
        [accView.stopButton setAlpha:1.0];
    }
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {


    //    if (!self.tasksTableView.editing) {
//        [tableView deselectRowAtIndexPath:indexPath animated:NO];
//        Task *task = [_filteredItemList objectAtIndex:indexPath.row];
//        CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
//        rect.origin.y += tableView.contentInset.top;
//        
//        [self popoverTaskViewWithTask:task inRect:rect];
//    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Task *task = [self.filteredItemList objectAtIndex:indexPath.row];
    BBTaskListTableViewCell *cell = (id)[tableView cellForRowAtIndexPath:indexPath];
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:15]};
    // NSString class method: boundingRectWithSize:options:attributes:context is
    // available only on ios7.0 sdk.
    CGRect rect = [task.name boundingRectWithSize:CGSizeMake(cell.taskNameLabel.frame.size.width, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:attributes
                                     context:nil];
    
    CGSize size = rect.size;
    size.height += tableView.estimatedRowHeight;

    return MAX(size.height, tableView.estimatedRowHeight);
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

#pragma mark - UITextViewDelegate Methods

- (void)textViewDidChange:(UITextView *)textView
{
    id cell = textView.superview.superview;
    NSIndexPath *indexPath = [self.tasksTableView indexPathForCell:cell];

    Task *task = [self.filteredItemList objectAtIndex:indexPath.row];
    task.name = textView.text;
    
    [UIView setAnimationsEnabled:NO];
    [self.tasksTableView beginUpdates];
    [self.tasksTableView endUpdates];
    [UIView setAnimationsEnabled:YES];

    CGRect rect = [_tasksTableView rectForRowAtIndexPath:indexPath];
    [self.tasksTableView scrollRectToVisible:rect animated:NO];
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

- (void)popoverTaskViewWithTask:(Task *)task inRect:(CGRect)rect inView:(UIView*)view {
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
    popoverController.popoverContentSize = CGSizeMake(350, 500);
    [popoverController presentPopoverFromRect:rect
                                       inView:view
                     permittedArrowDirections:UIPopoverArrowDirectionRight
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
    if ([[BBTaskTimer sharedInstance] currentTask] && [[BBTaskTimer sharedInstance] currentTask] == task) {
        [[BBTaskTimer sharedInstance] resume];
    } else {
        [[BBTaskTimer sharedInstance] startWithTask:task sender:self];
    }
}

- (void)pauseTimer {
    [[BBTaskTimer sharedInstance] pause];
}

- (void)stopTimer {
    [[BBTaskTimer sharedInstance] stop];
}

- (void)updateRowAtIndexPath:(NSIndexPath*)path
{
    [self fetchTasks];
    // refresh matter list accordingly
    [self.matterListViewController fetchMatters];
    [self.tasksTableView beginUpdates];
    [self.tasksTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
    [self.tasksTableView endUpdates];
}

- (void)timerStopped:(NSNotification*)notification
{
    Task *task = notification.object;
    NSIndexPath *indexPath = [self indexPathOfTask:task];
    
    if (indexPath) {

        BBTaskListTableViewCell *cell = [self.tasksTableView cellForRowAtIndexPath:indexPath];
        
        cell.taskTimeLabel.text = [task durationToFormattedString];
        cell.totalFeesExcludeGSTLabel.text = [task.totalFeesExGst currencyAmount];
        cell.totalFeesIncludeGSTLabel.text = [task.totalFeesIncGst currencyAmount];

        BBTimerAccessoryView *accView = (BBTimerAccessoryView *)cell.accessoryView;
        [accView showDefaultTimer];

        UIView *innerView = [[accView subviews] objectAtIndex:0];
        [innerView setTranslatesAutoresizingMaskIntoConstraints:YES];
        UIView *innerViewPrototype = [[[BBTimerAccessoryView cellAccessoryViewWithOwner:self] subviews] objectAtIndex:0];
        CGRect accViewRect = innerViewPrototype.frame;
        
        [UIView animateWithDuration:0.6
                              delay:0
                            options:UIViewAnimationOptionLayoutSubviews|UIViewAnimationCurveEaseInOut
                         animations:^{
                             [innerView setFrame:accViewRect];
                             [accView.stopButton setAlpha:0.0];
                         }
                         completion:^(BOOL finished) {
                         }];
        

    }
}

- (void)timerResumed:(NSNotification*)notification
{
    Task *task = notification.object;
    NSIndexPath *indexPath = [self indexPathOfTask:task];
    BBTaskListTableViewCell *cell = [self.tasksTableView cellForRowAtIndexPath:indexPath];
    [(BBTimerAccessoryView*)cell.accessoryView showRunningTimer];
}

- (void)timerPaused:(NSNotification*)notification
{
    Task *task = notification.object;
    NSIndexPath *indexPath = [self indexPathOfTask:task];
    BBTaskListTableViewCell *cell = [self.tasksTableView cellForRowAtIndexPath:indexPath];
    [(BBTimerAccessoryView*)cell.accessoryView showPauseTimer];
}

- (void)timerUpdated:(NSNotification*)notification
{
    Task *task = notification.object;
    NSIndexPath *indexPath = [self indexPathOfTask:task];
    BBTaskListTableViewCell *cell = [self.tasksTableView cellForRowAtIndexPath:indexPath];

    cell.taskTimeLabel.text = [task durationToFormattedString];
    cell.totalFeesExcludeGSTLabel.text = [task.totalFeesExGst currencyAmount];
    cell.totalFeesIncludeGSTLabel.text = [task.totalFeesIncGst currencyAmount];
}

@end
