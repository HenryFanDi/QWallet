//
//  MainViewControllerDark.m
//  qtum wallet
//
//  Created by HenryFan on 18/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import "MainViewControllerDark.h"

@interface MainViewControllerDark ()

@end

@implementation MainViewControllerDark

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private Methods

- (void)configTableView {
    [super configTableView];
    
    UINib *sectionHeaderNib = [UINib nibWithNibName:@"HistoryTableHeaderViewDark" bundle:nil];
    [self.tableView registerNib:sectionHeaderNib forHeaderFooterViewReuseIdentifier:SectionHeaderViewIdentifier];
}

- (void)configRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = customBlackColor();
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshFromRefreshControl) forControlEvents:UIControlEventValueChanged];
    
    CGRect frame = self.view.bounds;
    frame.origin.y = -frame.size.height;
    UIView *refreshBackgroundView = [[UIView alloc] initWithFrame:frame];
    refreshBackgroundView.backgroundColor = customBlueColor();
    [self.tableView insertSubview:refreshBackgroundView atIndex:0];
}

@end
