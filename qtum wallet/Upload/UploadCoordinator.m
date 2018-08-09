//
//  UploadCoordinator.m
//  qtum wallet
//
//  Created by HenryFan on 10/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import "UploadCoordinator.h"
#import "UploadOutput.h"

@interface UploadCoordinator () <UploadOutputDelegate>

@property (nonatomic, strong) UINavigationController *navigationController;
//@property (nonatomic, weak) NSObject <UploadOutput> *uploadViewController;

@end

@implementation UploadCoordinator

#pragma mark - Lifecycle

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController {
    self = [super init];
    if (self) {
        _navigationController = navigationController;
    }
    return self;
}

- (void)start {
//    self.uploadViewController = (NSObject <UploadOutput> *)[self.navigationController.viewControllers firstObject];
//    self.uploadViewController.delegate = self;
    
//    NSObject <UploadOutput> *controller = [SLocator.controllersFactory createUploadViewController];
//    controller.delegate = self;
//    [self.navigationController pushViewController:[controller toPresent] animated:YES];
}

#pragma mark - UploadOutputDelegate

- (void)uploadImageFile {
    
}

- (void)uploadVideoFile {
    
}

@end
