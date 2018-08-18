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

@end
