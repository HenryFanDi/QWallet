//
//  MainOutput.h
//  qtum wallet
//
//  Created by HenryFan on 8/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainOutputDelegate.h"

@class MainTableSource;

@protocol MainOutput <NSObject>

@property (nonatomic, strong) MainTableSource *tableSource;
@property (nonatomic, weak) id <MainOutputDelegate> delegate;

- (void)reloadTableView;

- (void)failedToGetData;

- (void)failedToGetBalance;

- (void)startLoading;

- (void)stopLoading;

@end
