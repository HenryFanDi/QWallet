//
//  DetailViewController.h
//  qtum wallet
//
//  Created by HenryFan on 21/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Presentable.h"
#import "DetailOutput.h"

@interface DetailViewController : UIViewController <Presentable, DetailOutput>

@property (nonatomic, weak) id <DetailOutputDelegate> delegate;

@end
