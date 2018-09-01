//
//  MainTableSourceLight.m
//  qtum wallet
//
//  Created by HenryFan on 18/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import "MainTableSourceLight.h"
#import "WalletHeaderCellLight.h"
#import "MainTableViewCellLight.h"

@implementation MainTableSourceLight

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
        WalletHeaderCellLight *cell = [tableView dequeueReusableCellWithIdentifier:@"WalletHeaderCellLight"];
        [cell setCellType:[self headerCellType]];
        [self didScrollForheaderCell:tableView];
        
        NSArray <FileModel *> *files = self.files;
        CGFloat totalValue = 0.0f;
        for (FileModel *file in files) {
            totalValue += file.balance.floatValue;
        }
        
        cell.valueLabel.text = [NSString stringWithFormat:@"%.2f BSX", totalValue];
        self.mainCell = cell;
        return cell;
    } else {
        MainTableViewCellLight *cell = [tableView dequeueReusableCellWithIdentifier:@"MainTableViewCellLight"];
        MainTableViewCellViewModel *viewModel = [[MainTableViewCellViewModel alloc] initWithModel:self.files[indexPath.row]];
        [cell configure:viewModel];
        return cell;
    }
}

@end
