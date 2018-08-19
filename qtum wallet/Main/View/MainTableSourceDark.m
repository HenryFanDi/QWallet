//
//  MainTableSourceDark.m
//  qtum wallet
//
//  Created by HenryFan on 18/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import "MainTableSourceDark.h"
#import "WalletHeaderCellDark.h"
#import "HistoryTableViewCellDark.h"
#import "MainTableViewCellDark.h"

@implementation MainTableSourceDark

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch ([self headerCellType]) {
            case HeaderCellTypeWithoutPageControl:
                return 192.0;
            case HeaderCellTypeWithoutNotCorfirmedBalance:
                return 161.0;
            case HeaderCellTypeWithoutAll:
                return 152.0;
            case HeaderCellTypeAllVisible:
            default:
                return 100.0;
        }
    } else {
        return 80.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        WalletHeaderCellDark *cell = [tableView dequeueReusableCellWithIdentifier:@"WalletHeaderCellDark"];
        
//        cell.delegate = self.delegate;
        [cell setCellType:[self headerCellType]];
//        [cell setData:self.wallet];
        [self didScrollForheaderCell:tableView];
        
        self.mainCell = cell;
        return cell;
    } else {
        MainTableViewCellDark *cell = [tableView dequeueReusableCellWithIdentifier:@"MainTableViewCellDark"];
        return cell;
    }
}

@end
