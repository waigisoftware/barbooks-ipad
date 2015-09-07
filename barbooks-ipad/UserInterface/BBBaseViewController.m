//
//  BBBaseViewController.m
//  barbooks-ipad
//
//  Created by Can on 4/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBBaseViewController.h"

@interface BBBaseViewController () {
    UIStoryboard *_mainStoryboard;
}

@end

@implementation BBBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [UIFloatLabelTextField applyStyleToAllUIFloatLabelTextFieldInView:self.view];
    self.splitViewController.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core Data

//- (void)coreDataSave {
//    [[[BBCoreDataManager sharedInstance] managedObjectContext] save:nil];
//}

- (UIStoryboard *)mainStoryboard {
    if (!_mainStoryboard) {
        _mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    }
    return _mainStoryboard;
}

- (BOOL) splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return NO;
}

@end
