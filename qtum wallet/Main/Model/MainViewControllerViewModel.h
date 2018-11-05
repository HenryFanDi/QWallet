//
//  MainViewControllerViewModel.h
//  qtum wallet
//
//  Created by HenryFan on 24/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MainViewController;

@interface MainViewControllerViewModel : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithViewController:(MainViewController *)viewController;

@property (nonatomic, strong, readonly) NSString *walletAddress;

- (void)getWalletBalance:(void (^)(NSNumber *balance))success failure:(void (^)(void))failure;

@end
