//
//  MainTableViewCellViewModel.m
//  qtum wallet
//
//  Created by HenryFan on 26/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import "MainTableViewCellViewModel.h"

@interface MainTableViewCellViewModel ()
@property (nonatomic, strong, readwrite) UIImage *fileImage;
@property (nonatomic, strong, readwrite) NSString *sizeLabelString;
@property (nonatomic, strong, readwrite) NSString *fileNameLabelString;
@property (nonatomic, strong, readwrite) NSString *timeLabelString;
@property (nonatomic, strong, readwrite) NSString *tokenLabelString;
@property (nonatomic, strong, readwrite) NSString *txLabelString;
@end

@implementation MainTableViewCellViewModel

- (instancetype)initWithModel:(FileModel *)model {
    self = [super init];
    if (self) {
        self.fileImage = model.object;
        self.sizeLabelString = [NSString stringWithFormat:@"%.2f KB", model.size.floatValue / 1000];
        self.fileNameLabelString = model.name;
        self.timeLabelString = model.time;
        self.tokenLabelString = [NSString stringWithFormat:@"+%.2f BSX", model.balance.floatValue];
        self.txLabelString = [NSString stringWithFormat:@"Tx:%@", model.txID];
    }
    return self;
}

@end
