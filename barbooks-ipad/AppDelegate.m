//
//  AppDelegate.m
//  barbooks-ipad
//
//  Created by Can on 31/05/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailViewController.h"
#import "MasterViewController.h"
#import "ECSlidingViewController.h"
#import "BBCoreDataManager.h"
#import "UIColor+BBUtil.h"
#import "BBTimers.h"
#import <Lockbox/Lockbox.h>
#import <JDStatusBarNotification/JDStatusBarNotification.h>
#import "RegularInvoice.h"
#import <CouchbaseLite/CouchbaseLite.h>
#import "CBLIncrementalStore.h"
#import "BBSynchronizationViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


@interface AppDelegate () <UISplitViewControllerDelegate>


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [JDStatusBarNotification setDefaultStyle:^JDStatusBarStyle *(JDStatusBarStyle *style) {
        // main properties
        style.barColor = [UIColor bbPrimaryBlue];
        style.textColor = [UIColor whiteColor];
        style.font = [UIFont fontWithName:@"Helvetica Neue" size:10];
        
        // advanced properties
        style.animationType = JDStatusBarAnimationTypeBounce;
        style.textShadow = nil;
        style.textVerticalPositionAdjustment = 0;
        
        // progress bar
        style.progressBarColor = [UIColor bbGreen];
        style.progressBarHeight = 2;
        style.progressBarPosition = JDStatusBarProgressBarPositionBelow;
        
        return style;
    }];
    
    [JDStatusBarNotification addStyleNamed:@"warning"
                                   prepare:^JDStatusBarStyle *(JDStatusBarStyle *style) {
                                       // main properties
                                       style.barColor = [UIColor bbRed];
                                       style.textColor = [UIColor whiteColor];
                                       style.font = [UIFont fontWithName:@"Helvetica Neue" size:10];
                                       
                                       // advanced properties
                                       style.animationType = JDStatusBarAnimationTypeBounce;
                                       
                                       return style;
                                   }];
    
    NSManagedObjectModel *model =  [[NSManagedObjectModel mergedModelFromBundles:nil] mutableCopy];
    [CBLIncrementalStore updateManagedObjectModel:model];
    
    NSError *error = nil;
    NSString *databaseName = @"barbooks";
    NSURL *storeUrl = [NSURL URLWithString:databaseName];
    
    NSDictionary* options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES
                              };

    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    CBLIncrementalStore *store = (id)[persistentStoreCoordinator addPersistentStoreWithType:[CBLIncrementalStore type]
                                                                              configuration:nil
                                                                                        URL:storeUrl
                                                                                    options:options
                                                                                      error:&error];
    
    [NSManagedObjectContext MR_initializeDefaultContextWithCoordinator:persistentStoreCoordinator];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_rootSavingContext];
    [store addObservingManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
    
    [[BBAccountManager sharedManager] setManagedObjectContext:context];
    [[BBAccountManager sharedManager] setToLargestAccount];
    if (![[BBAccountManager sharedManager] activeAccount]) {
        [[BBCloudManager sharedManager] logout];
    }
    [Fabric with:@[[Crashlytics class]]];

    [self setupNavigationBarAppearance];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[BBTimers sharedInstance] runBackgroundCoreDataSaveTimer];
    [self setupObservers];
    [self determineWhichViewControllerToShowFirst];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncStatusProgressed) name:kSyncStatusProgressedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncStatusProgressed) name:kSyncStatusUpdatedNotification object:nil];

    return YES;
}

- (void)syncStatusProgressed
{
    if ([[BBCloudManager sharedManager] syncStatus] == kCBLReplicationActive) {
        if (![JDStatusBarNotification isVisible]) {
            [JDStatusBarNotification showWithStatus:@"Synchronising ..."];
        }
        [JDStatusBarNotification showProgress:[[BBCloudManager sharedManager] progress]];
    } else if ([[BBCloudManager sharedManager] syncStatus] == kCBLReplicationOffline) {
        if (![JDStatusBarNotification isVisible]) {
            [JDStatusBarNotification showWithStatus:@"Offline. Please check your internet connection." styleName:@"warning"];
        }
    }else {
        [JDStatusBarNotification dismissAnimated:YES];
    }
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    Task *task = [[BBTaskTimer sharedInstance] currentTask];
    if (task) {
        [[NSUserDefaults standardUserDefaults] setObject:[[task.objectID URIRepresentation] absoluteString] forKey:@"Running Task"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:[[BBTaskTimer sharedInstance] startStamp]] forKey:@"Timer Stamp"];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    Task *task = [[BBTaskTimer sharedInstance] currentTask];
    if (!task && [[NSUserDefaults standardUserDefaults] objectForKey:@"Running Task"]) {
        NSURL *objectURI = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"Running Task"]];
        NSManagedObjectID *objectID = [[NSManagedObjectContext MR_rootSavingContext].persistentStoreCoordinator managedObjectIDForURIRepresentation:objectURI];
        
        task = [[NSManagedObjectContext MR_defaultContext] objectWithID:objectID];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Running Task"];
        [[BBTaskTimer sharedInstance] startWithTask:task sender:self];
        [[BBTaskTimer sharedInstance] setStartStamp:[[[NSUserDefaults standardUserDefaults] objectForKey:@"Timer Stamp"] floatValue]];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Timer Stamp"];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSLog(@"all data saved!");
    }];
    [MagicalRecord cleanUp];
}



-(void) setupTableViewAppearance
{
    [[UITableView appearance] setTintColor:[UIColor whiteColor]];
    [[UITableView appearance] setBackgroundColor:[UIColor bbTableBackground]];
}


-(void) setupNavigationBarAppearance
{
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];

    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor bbPrimaryBlue]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        [[UINavigationBar appearance] setTranslucent:NO];
    }
//    [[BBGenericButton appearance] setBackgroundColor:[UIColor bbButtonBackgroundColor]];
}

#pragma mark - Navigation

-(void) determineWhichViewControllerToShowFirst
{
    //ECSlidingViewController *viewController = (ECSlidingViewController *)self.window.rootViewController;
    //viewController.panGesture.delegate = self;
    
    BOOL isAuthorized = [[BBCloudManager sharedManager] isLoggedIn];

    if (isAuthorized)
    {
        [[BBCloudManager sharedManager] activateReplication];
        //[self showMatters];
    }
    else
    {
//        [self showLogin];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        return YES;
    } else {
        return NO;
    }
}

- (void) showMatters
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UISplitViewController *splitViewController = [storyboard instantiateViewControllerWithIdentifier:BBNavigationControllerHome];//(UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    splitViewController.delegate = self;
//
    
//    ECSlidingViewController *viewController = (ECSlidingViewController *)self.window.rootViewController;
//    viewController.topViewController = splitViewController;//[storyboard instantiateViewControllerWithIdentifier:BBNavigationControllerHome];
//    [viewController resetTopViewAnimated:YES];
}

-(void) showLogin
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subscriptionUpdateSucceeded) name:kLoginSuccessfulNotification object:nil];
    [self.window makeKeyAndVisible];
    [self.window.rootViewController performSegueWithIdentifier:@"showLogin" sender:self];
//
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    ECSlidingViewController *viewController = (ECSlidingViewController *)self.window.rootViewController;
//    viewController.topViewController = [storyboard instantiateViewControllerWithIdentifier:BBNavigationControllerLogin];
//    [viewController resetTopViewAnimated:YES];
}

- (void) subscriptionUpdateSucceeded {
    
}


- (void) logout {
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DetailViewController class]] && ([(DetailViewController *)[(UINavigationController *)secondaryViewController topViewController] detailItem] == nil)) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Notifications/Ovservers

- (void)setupObservers {
    __weak AppDelegate* bself = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kSubscriptionUpdateSucceededNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
                                                      [bself showMatters];
                                                  }];
//    
//    [[NSNotificationCenter defaultCenter] addObserverForName:kLoginFailedNotification
//                                                      object:nil
//                                                       queue:nil
//                                                  usingBlock:^(NSNotification *notification) {
//                                                      NSError *error = notification.object;
//                                                      [self showAlertWithTitle:@"Authentication Error"
//                                                                       message:error.localizedDescription];
//                                                      [bself logout];
//                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kSubscriptionUpdateFailedNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
                                                      [self showAlertWithTitle:@"Invalid Subscription"
                                                                       message:[notification.object objectForKey:@"message"]];
                                                      [bself logout];
                                                  }];
    
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

@end
