//
//  DetailViewControllerViewModel.h
//  qtum wallet
//
//  Created by HenryFan on 26/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileModel.h"

@interface DetailViewControllerViewModel : NSObject
@property (nonatomic, strong, readonly) FileModel *model;
@property (nonatomic, strong, readonly) NSString *titleLabelString;
@property (nonatomic, strong, readonly) UIImage *fileImage;
@property (nonatomic, strong, readonly) NSString *tokenLabelString;
@property (nonatomic, strong, readonly) NSString *txLabelString;

- (instancetype)initWithModel:(FileModel *)model;

@end
