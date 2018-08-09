//
//  UploadCoordinator.h
//  qtum wallet
//
//  Created by HenryFan on 10/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseCoordinator.h"

@class LanguageCoordinator;

@interface UploadCoordinator : BaseCoordinator <Coordinatorable>

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController;

@end
