//
//  MainViewController.m
//  qtum wallet
//
//  Created by HenryFan on 8/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *availableLabel;
@property (weak, nonatomic) IBOutlet UIView *viewForHeaderInSecondSection;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;

@end

@implementation MainViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private Methods

- (void)configTableView {
    self.tableView.tableFooterView = [UIView new];
    self.tableView.dataSource = self.tableSource;
    self.tableView.delegate = self.tableSource;
    self.tableSource.tableView = self.tableView;
    self.tableSource.controllerDelegate = self;
}

#pragma mark - MainOutput

- (void)reloadTableView {

}

- (void)failedToGetData {
    
}

- (void)failedToGetBalance {
    
}

- (void)startLoading {
    
}

- (void)stopLoading {
    
}

#pragma mark - TableSourceDelegate

- (void)needShowHeader:(CGFloat)percent {
}

- (void)needHideHeader:(CGFloat)percent {
}

- (void)needShowHeaderForSecondSeciton {
    self.viewForHeaderInSecondSection.hidden = NO;
}

- (void)needHideHeaderForSecondSeciton {
    self.viewForHeaderInSecondSection.hidden = YES;
}

@end
