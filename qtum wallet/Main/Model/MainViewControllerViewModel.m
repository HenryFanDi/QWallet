//
//  MainViewControllerViewModel.m
//  qtum wallet
//
//  Created by HenryFan on 24/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import "MainViewControllerViewModel.h"
#import "MainRequestManager.h"

@interface MainViewControllerViewModel ()

@end

@implementation MainViewControllerViewModel

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - Public Methods

- (void)fetchWalletBalance:(void (^)(NSString *wallet, NSString *balance))success failure:(void (^)(void))failure {
    [[MainRequestManager new] getWalletBalance:^(id responseObject) {
        NSLog(@"Get Wallet Balance success : %@", responseObject);
        NSString *wallet = responseObject[@"wallet"];
        NSString *balance = [NSString stringWithFormat:@"%.2f BSX", [responseObject[@"balance"] floatValue]];
        success(wallet, balance);
    } failure:^(NSError *error) {
        NSLog(@"Get Wallet Balance failure : %@", [error localizedDescription]);
        failure();
    }];
}

#pragma mark - Private Methods

@end
