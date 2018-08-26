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

- (void)fetchWalletBalance {
    [[MainRequestManager new] getWalletBalance:^(id responseObject) {
        NSLog(@"Get Wallet Balance success : %@", responseObject);
    } failure:^(NSError *error) {
        NSLog(@"Get Wallet Balance failure : %@", [error localizedDescription]);
    }];
}

#pragma mark - Private Methods

@end
