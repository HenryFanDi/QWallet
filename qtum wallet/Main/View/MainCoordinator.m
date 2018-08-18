//
//  MainCoordinator.m
//  qtum wallet
//
//  Created by HenryFan on 10/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import "MainCoordinator.h"
#import "MainOutput.h"

@interface MainCoordinator () <MainOutputDelegate>

@property (nonatomic, strong) UINavigationController *navigationController;
    
@end

@implementation MainCoordinator

#pragma mark - Lifecycle

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController {
    self = [super init];
    if (self) {
        _navigationController = navigationController;
    }
    return self;
}

- (void)start {
}

#pragma mark - MainOutputDelegate

- (void)didReloadTableViewData {
    
}

- (void)didRefreshTableViewBalanceLocal:(BOOL)isLocal {
    
}

- (void)didShowQRCodeScan {
    
}

- (void)didShowAddressControl {
    
}

@end
