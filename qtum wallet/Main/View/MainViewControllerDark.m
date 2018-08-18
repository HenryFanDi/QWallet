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

@end
