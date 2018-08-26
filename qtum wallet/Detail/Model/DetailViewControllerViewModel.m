//
//  DetailViewControllerViewModel.m
//  qtum wallet
//
//  Created by HenryFan on 26/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import "DetailViewControllerViewModel.h"

@interface DetailViewControllerViewModel ()
@property (nonatomic, strong, readwrite) NSString *titleLabelString;
@property (nonatomic, strong, readwrite) UIImage *fileImage;
@property (nonatomic, strong, readwrite) NSString *tokenLabelString;
@property (nonatomic, strong, readwrite) NSString *txLabelString;
@end

@implementation DetailViewControllerViewModel

#pragma mark - Lifecycle

- (instancetype)initWithModel:(FileModel *)model {
    self = [super init];
    if (self) {
        self.titleLabelString = model.name;
        self.fileImage = model.object;
        self.tokenLabelString = [NSString stringWithFormat:@"%+.2f BSX", model.amount.floatValue];
        self.txLabelString = [NSString stringWithFormat:@"%@", model.txID];
    }
    return self;
}

@end
