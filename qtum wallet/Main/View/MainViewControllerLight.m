//
//  MainViewControllerLight.m
//  qtum wallet
//
//  Created by HenryFan on 18/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import "MainViewControllerLight.h"

@interface MainViewControllerLight ()

@end

@implementation MainViewControllerLight

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
    
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake (64, 0, 0, 0);
    
    UINib *sectionHeaderNib = [UINib nibWithNibName:@"HistoryTableHeaderViewLight" bundle:nil];
    [self.tableView registerNib:sectionHeaderNib forHeaderFooterViewReuseIdentifier:SectionHeaderViewIdentifier];
}

- (void)configRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshFromRefreshControl) forControlEvents:UIControlEventValueChanged];
    
    CGRect frame = self.view.bounds;
    frame.origin.y = -frame.size.height;
    UIView *refreshBackgroundView = [[UIView alloc] initWithFrame:frame];
    refreshBackgroundView.backgroundColor = [UIColor colorWithRed:54.0f/255.0f green:85.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
    [self.tableView insertSubview:refreshBackgroundView atIndex:0];
}

@end
