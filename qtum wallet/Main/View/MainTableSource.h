//
//  MainTableSource.h
//  qtum wallet
//
//  Created by HenryFan on 18/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainCoordinator.h"
#import "WalletHeaderCell.h"
#import "HistoryHeaderVIew.h"

@class FileModel;

@protocol MainControllerDelegate <NSObject>
@optional
- (void)needShowHeader:(CGFloat)percent;
- (void)needHideHeader:(CGFloat)percent;
- (void)needShowHeaderForSecondSeciton;
- (void)needHideHeaderForSecondSeciton;
@end

@interface MainTableSource : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id <MainCoordinatorDelegate> delegate;
@property (nonatomic, weak) id <MainControllerDelegate> controllerDelegate;
@property (nonatomic, strong) NSArray <FileModel *> *files;

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) WalletHeaderCell *mainCell;
@property (nonatomic, readonly, weak) HistoryHeaderVIew *sectionHeaderView;

- (HeaderCellType)headerCellType;

- (void)didScrollForheaderCell:(UIScrollView *)scrollView;

@end
