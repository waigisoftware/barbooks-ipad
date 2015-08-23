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
#import "BBSubscriptionManager.h"
#import "DBAccountManager.h"
#import "DBDatastoreManager.h"
#import "BBSynchronizationViewController.h"


@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupNavigationBarAppearance];
    [self determineWhichViewControllerToShowFirst];
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"BarBooks"];
    [[BBTimers sharedInstance] runBackgroundCoreDataSaveTimer];
    [self setupObservers];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
//    [[BBCoreDataManager sharedInstance] saveContext];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSLog(@"all data saved!");
    }];
    [MagicalRecord cleanUp];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplicatio annotation:(id)annotation {
    NSString *action = [url lastPathComponent];
    
    if ([action isEqualToString:@"connect"]) {
        DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
        if (account) {
            NSLog(@"App linked successfully!");
            // Migrate any local datastores to the linked account
            DBDatastoreManager *localManager = [DBDatastoreManager localManagerForAccountManager:
                                                [DBAccountManager sharedManager]];
            [localManager migrateToAccount:account error:nil];
            // Now use Dropbox datastores
            [DBDatastoreManager setSharedManager:[DBDatastoreManager managerForAccount:account]];
            return YES;
        }
    }
    return NO;
}

-(void) setupNavigationBarAppearance
{
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
    ECSlidingViewController *viewController = (ECSlidingViewController *)self.window.rootViewController;
    viewController.panGesture.delegate = self;
    
//    [self showSynchronization];
//    return;
    BOOL isAuthorized = [[BBSubscriptionManager sharedInstance] subscriptionValid];
    isAuthorized = YES;
    if (isAuthorized)
    {
        [self showMatters];
    }
    else
    {
        [self showLogin];
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

-(void) showMatters
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UISplitViewController *splitViewController = [storyboard instantiateViewControllerWithIdentifier:BBNavigationControllerHome];//(UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    splitViewController.delegate = self;
    
    UINavigationController *masterNavigationController = splitViewController.viewControllers[0];
    MasterViewController *controller = (MasterViewController *)masterNavigationController.topViewController;
//    controller.managedObjectContext = self.managedObjectContext;
    
    ECSlidingViewController *viewController = (ECSlidingViewController *)self.window.rootViewController;
    viewController.topViewController = splitViewController;//[storyboard instantiateViewControllerWithIdentifier:BBNavigationControllerHome];
    [viewController resetTopViewAnimated:YES];

}

-(void) showLogin
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ECSlidingViewController *viewController = (ECSlidingViewController *)self.window.rootViewController;
    viewController.topViewController = [storyboard instantiateViewControllerWithIdentifier:BBNavigationControllerLogin];
    [viewController resetTopViewAnimated:YES];
}

-(void) showSynchronization
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ECSlidingViewController *viewController = (ECSlidingViewController *)self.window.rootViewController;
    viewController.topViewController = [storyboard instantiateViewControllerWithIdentifier:BBNavigationControllerLogin];
    [viewController resetTopViewAnimated:NO];
    
    BBSynchronizationViewController *synchronizationViewController = ((BBSynchronizationViewController *)[viewController.topViewController.storyboard instantiateViewControllerWithIdentifier:StoryboardIdBBSynchronizationViewController]);
    [(UINavigationController *)viewController.topViewController pushViewController:synchronizationViewController animated:YES];

//    [viewController.topViewController.navigationController performSegueWithIdentifier:BBSegueShowSynchronization sender:viewController.topViewController];
}

-(void) logout {
    [[BBSubscriptionManager sharedInstance] logout];
    [self showLogin];
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
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kLoginFailedNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
                                                      [self showAlertWithTitle:@"Authentication Error"
                                                                       message:[notification.object objectForKey:@"message"]];
                                                      [bself logout];
                                                  }];
    
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
                               delegate:((ECSlidingViewController *)self.window.rootViewController).topViewController.view
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

@end
