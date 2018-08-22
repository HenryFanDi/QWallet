//
//  MainRequestManager.h
//  qtum wallet
//
//  Created by HenryFan on 18/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainRequestable.h"

@interface MainRequestManager : NSObject <MainRequestable>

- (instancetype)initWithBaseUrl:(NSString *)baseUrl;

@end
