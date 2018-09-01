//
//  MainCoordinator.h
//  qtum wallet
//
//  Created by HenryFan on 10/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseCoordinator.h"

@class LanguageCoordinator;

@protocol MainCoordinatorDelegate <NSObject>
- (void)refreshTableViewData;
- (void)didSelectFileItem:(id)item;
@end

@interface MainCoordinator : BaseCoordinator <MainCoordinatorDelegate, Coordinatorable>

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController;

@end
