//
//  DetailViewControllerViewModel.m
//  qtum wallet
//
//  Created by HenryFan on 26/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import "DetailViewControllerViewModel.h"

@interface DetailViewControllerViewModel ()
@property (nonatomic, strong, readwrite) FileModel *model;
@property (nonatomic, strong, readwrite) NSString *titleLabelString;
@property (nonatomic, strong, readwrite) UIImage *fileImage;
@property (nonatomic, strong, readwrite) NSString *sizeLabelString;
@property (nonatomic, strong, readwrite) NSString *tokenLabelString;
@property (nonatomic, strong, readwrite) NSString *txLabelString;
@end

@implementation DetailViewControllerViewModel

#pragma mark - Lifecycle

- (instancetype)initWithModel:(FileModel *)model {
    self = [super init];
    if (self) {
        self.model = model;
        self.titleLabelString = model.name;
        self.fileImage = model.object;
        self.sizeLabelString = [NSString stringWithFormat:@"%.2f KB", model.size.floatValue / 1000];
        self.tokenLabelString = [NSString stringWithFormat:@"%+.2f BSX", model.balance.floatValue];
        self.txLabelString = [NSString stringWithFormat:@"%@", model.txID];
    }
    return self;
}

@end
