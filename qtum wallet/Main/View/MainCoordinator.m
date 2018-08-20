//
//  MainCoordinator.m
//  qtum wallet
//
//  Created by HenryFan on 10/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import "MainCoordinator.h"
#import "MainOutput.h"
#import "DetailOutput.h"
#import "MainTableSource.h"

@interface MainCoordinator () <MainOutputDelegate, DetailOutputDelegate>
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, weak) NSObject <MainOutput> *mainViewController;

@property (nonatomic, strong) MainTableSource *delegateDataSource;
    
@end

@implementation MainCoordinator

#pragma mark - Lifecycle

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController {
    self = [super init];
    if (self) {
        _navigationController = navigationController;
        [self setup];
    }
    return self;
}

- (void)start {
    NSObject <MainOutput> *controller = [SLocator.controllersFactory createMainViewController];
    controller.delegate = self;
    
    self.delegateDataSource = [SLocator.tableSourcesFactory mainWalletSource];
    self.delegateDataSource.delegate = self;
    controller.tableSource = self.delegateDataSource;
    self.mainViewController = controller;
    
    [self.navigationController setViewControllers:@[[controller toPresent]]];
}

#pragma mark - Private Methods

- (void)setup {
    self.navigationController.navigationBar.hidden = YES;
}

#pragma mark - MainCoordinatorDelegate

- (void)didSelectFileItem:(id)item {
    NSObject <DetailOutput> *controller = [SLocator.controllersFactory createDetailViewController];
    controller.delegate = self;
    [self.navigationController pushViewController:[controller toPresent] animated:YES];
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

#pragma mark - DetailOutputDelegate

@end
