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

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupNavigationBarAppearance];
    [self determineWhichViewControllerToShowFirst];
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"BarBooks"];
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
    [MagicalRecord cleanUp];
}

-(void) setupNavigationBarAppearance
{
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor bbPrimaryBlue]];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        [[UINavigationBar appearance] setTranslucent:NO];
    }
}

#pragma mark - Navigation

-(void) determineWhichViewControllerToShowFirst
{
    ECSlidingViewController *viewController = (ECSlidingViewController *)self.window.rootViewController;
    viewController.panGesture.delegate = self;
    
    BOOL isAuthorized = YES;
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

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DetailViewController class]] && ([(DetailViewController *)[(UINavigationController *)secondaryViewController topViewController] detailItem] == nil)) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    } else {
        return NO;
    }
}


@end
