//
//  MainViewControllerViewModel.m
//  qtum wallet
//
//  Created by HenryFan on 24/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import "MainViewControllerViewModel.h"
#import "MainRequestManager.h"
#import "MainViewController.h"

@interface MainViewControllerViewModel ()
@property (nonatomic, strong) MainViewController *viewController;
@property (nonatomic, strong, readwrite) NSString *walletAddress;
@end

@implementation MainViewControllerViewModel

#pragma mark - Lifecycle

- (instancetype)initWithViewController:(MainViewController *)viewController {
    self = [super init];
    if (self) {
        self.viewController = viewController;
    }
    return self;
}

#pragma mark - Public Methods

- (void)getWalletBalance:(void (^)(NSNumber *balance))success failure:(void (^)(void))failure {
    __weak typeof(self) weakSelf = self;
    MainRequestManager *requestManager = [MainRequestManager new];
    [requestManager getWalletBalance:^(NSDictionary *walletBalanceResponseObject) {
        __strong typeof(weakSelf) self = weakSelf;
        self.walletAddress = walletBalanceResponseObject[@"wallet"] ? : @"";
        NSNumber *balance = walletBalanceResponseObject[@"balance"] ? [NSNumber numberWithInteger:[walletBalanceResponseObject[@"balance"] floatValue]] : @(0.0);
        success(balance);
    } failure:^(NSError *error) {
        NSLog(@"Get Wallet Balance failure : %@", [error localizedDescription]);
        failure();
    }];
}

#pragma mark - Private Methods

@end
