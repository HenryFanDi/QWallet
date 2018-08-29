//
//  DetailWebViewController.h
//  qtum wallet
//
//  Created by HenryFan on 28/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Presentable.h"
#import "DetailWebOutput.h"
#import "FileModel.h"

typedef NS_ENUM(NSInteger, DetailType) {
    DetailTypeFile,
    DetailTypeTxID
};

@interface DetailWebViewController : UIViewController <Presentable, DetailWebOutput>
@property (nonatomic, assign) DetailType type;
@property (nonatomic, strong) FileModel *model;
@end
