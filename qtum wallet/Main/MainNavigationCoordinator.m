//
//  MainNavigationCoordinator.m
//  qtum wallet
//
//  Created by HenryFan on 8/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import "MainNavigationCoordinator.h"

@interface MainNavigationCoordinator ()

@end

@implementation MainNavigationCoordinator

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return SLocator.appSettings.isDarkTheme ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}

@end
