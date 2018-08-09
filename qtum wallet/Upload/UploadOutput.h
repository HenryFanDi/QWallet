//
//  UploadOutput.h
//  qtum wallet
//
//  Created by HenryFan on 8/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadOutputDelegate.h"

@protocol UploadOutput <NSObject>

@property (nonatomic, weak) id <UploadOutputDelegate> delegate;

@end
