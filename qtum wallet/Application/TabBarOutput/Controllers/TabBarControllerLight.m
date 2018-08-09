//
//  TabBarControllerLight.m
//  qtum wallet
//
//  Created by Vladimir Lebedevich on 06.07.17.
//  Copyright © 2017 QTUM. All rights reserved.
//

#import "TabBarControllerLight.h"

@interface TabBarControllerLight ()

@end

@implementation TabBarControllerLight

- (void)viewDidLoad {

	[super viewDidLoad];
	[self configTabBar];
}

#pragma mark - Configuration

- (void)configTabBar {

	self.tabBar.translucent = NO;
	self.tabBar.tintColor = lightDarkGrayColor ();
	self.tabBar.barTintColor = lightBlueColor ();
}

- (void)configTabsWithNews:(UIViewController *)newsController
					  send:(UIViewController *)sendController
					wallet:(UIViewController *)walletController
                   profile:(UIViewController *)profileController
                    upload:(UIViewController *)uploadController {
    [self setViewControllers:@[walletController, profileController, newsController, sendController, uploadController] animated:YES];
    
    profileController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Profile", "Tabs") image:[UIImage imageNamed:@"profile"] tag:0];
    walletController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Wallet", "Tabs") image:[UIImage imageNamed:@"history"] tag:1];
    newsController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"News", "Tabs") image:[UIImage imageNamed:@"news"] tag:2];
    sendController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Send", "Tabs") image:[UIImage imageNamed:@"send"] tag:3];
    uploadController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Upload" image:[UIImage imageNamed:@"profile"] tag:4];
    
    [profileController.tabBarItem setTitlePositionAdjustment:UIOffsetMake (0, -3)];
    [walletController.tabBarItem setTitlePositionAdjustment:UIOffsetMake (0, -3)];
    [newsController.tabBarItem setTitlePositionAdjustment:UIOffsetMake (0, -3)];
    [sendController.tabBarItem setTitlePositionAdjustment:UIOffsetMake (0, -3)];
    [uploadController.tabBarItem setTitlePositionAdjustment:UIOffsetMake (0, -3)];
}

#pragma mark TabbarOutput

- (void)setControllerForNews:(UIViewController *)newsController
                     forSend:(UIViewController *)sendController
                   forWallet:(UIViewController *)walletController
                  forProfile:(UIViewController *)profileController
                   forUpload:(UIViewController *)uploadController {
    [self configTabsWithNews:newsController send:sendController wallet:walletController profile:profileController upload:uploadController];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

@end
