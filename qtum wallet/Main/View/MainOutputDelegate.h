//
//  MainOutputDelegate.h
//  qtum wallet
//
//  Created by HenryFan on 8/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MainOutputDelegate <NSObject>

@required
- (void)didReloadTableViewData;

- (void)didRefreshTableViewBalanceLocal:(BOOL)isLocal;

- (void)didUploadFile;

@end
