//
//  MainViewController.h
//  qtum wallet
//
//  Created by HenryFan on 8/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Presentable.h"
#import "WalletTableSource.h"
#import "MainOutput.h"

@class ViewWithAnimatedLine;

@interface MainViewController : UIViewController <Presentable, ControllerDelegate, MainOutput>
@property (strong, nonatomic) WalletTableSource *tableSource;
@property (weak, nonatomic) id <MainOutputDelegate> delegate;

@end
