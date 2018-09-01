//
//  MainTableViewCell.m
//  qtum wallet
//
//  Created by HenryFan on 20/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import "MainTableViewCell.h"

@implementation MainTableViewCell

#pragma mark - Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - Public Methods

- (void)configure:(MainTableViewCellViewModel *)viewModel {
    self.fileImageView.image = viewModel.fileImage;
    self.sizeLabel.text = viewModel.sizeLabelString;
    self.fileNameLabel.text = viewModel.fileNameLabelString;
    self.timeLabel.text = viewModel.timeLabelString;
    self.tokenLabel.text = viewModel.tokenLabelString;
    self.txLabel.text = viewModel.txLabelString;
}

- (void)setup {
}

@end
