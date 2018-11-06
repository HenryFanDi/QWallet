//
//  MainTableViewCellDark.m
//  qtum wallet
//
//  Created by HenryFan on 20/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import "MainTableViewCellDark.h"

@implementation MainTableViewCellDark

#pragma mark - Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - Public Methods

- (void)setup {
    [super setup];
    
    self.fileImageView.layer.borderColor = [UIColor colorWithRed:46.0f/255.0f green:154.0f/255.0f blue:208.0f/255.0f alpha:1.0f].CGColor;
    self.fileImageView.layer.borderWidth = 1.0f;
}

@end