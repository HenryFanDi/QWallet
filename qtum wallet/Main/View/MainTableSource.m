//
//  MainTableSource.m
//  qtum wallet
//
//  Created by HenryFan on 18/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import "MainTableSource.h"

@interface MainTableSource ()
@property (nonatomic, weak) HistoryHeaderVIew *sectionHeaderView;

@end

static NSInteger countOfSections = 2;

@implementation MainTableSource

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *) tableView {
    return countOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    } else {
        return self.files.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 32;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section != 0) {
        HistoryHeaderVIew *sectionHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:SectionHeaderViewIdentifier];
        self.sectionHeaderView = sectionHeaderView;
        return sectionHeaderView;
    } else {
        return nil;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section) {
        [self.delegate didSelectFileItem:nil];
    }
}

#pragma mark - Private Methods

- (HeaderCellType)headerCellType {
    return HeaderCellTypeAllVisible;
}

#pragma mark - Public Methods

- (void)didScrollForheaderCell:(UIScrollView *)scrollView {
    NSIndexPath *headerIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    WalletHeaderCell *headerCell = [self.tableView cellForRowAtIndexPath:headerIndexPath];
    if (!headerCell) {
        return;
    }
    
    if (self.sectionHeaderView) {
        CGFloat headerHeight = [headerCell getHeaderHeight];
        CGFloat headerPosition = self.sectionHeaderView.frame.origin.y - scrollView.contentOffset.y;
        if (headerPosition <= headerHeight) {
            if ([self.controllerDelegate respondsToSelector:@selector(needShowHeaderForSecondSeciton)]) {
                [self.controllerDelegate needShowHeaderForSecondSeciton];
            }
        } else {
            if ([self.controllerDelegate respondsToSelector:@selector(needHideHeaderForSecondSeciton)]) {
                [self.controllerDelegate needHideHeaderForSecondSeciton];
            }
        }
    }
    
    CGFloat position = headerCell.frame.origin.y - scrollView.contentOffset.y;
    [headerCell cellYPositionChanged:position];
    
    if ([headerCell needShowHeader:position]) {
        if ([self.controllerDelegate respondsToSelector:@selector(needShowHeader:)]) {
            [self.controllerDelegate needShowHeader:[headerCell percentForShowHideHeader:position]];
        }
    } else {
        if ([self.controllerDelegate respondsToSelector:@selector(needHideHeader:)]) {
            [self.controllerDelegate needHideHeader:[headerCell percentForShowHideHeader:position]];
        }
    }
}

@end
