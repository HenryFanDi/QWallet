//
//  MainOutput.h
//  qtum wallet
//
//  Created by HenryFan on 8/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainOutputDelegate.h"

@protocol MainOutput <NSObject>

@property (nonatomic, weak) id <MainOutputDelegate> delegate;

@end
