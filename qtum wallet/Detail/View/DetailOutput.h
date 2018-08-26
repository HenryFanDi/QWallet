//
//  DetailOutput.h
//  qtum wallet
//
//  Created by HenryFan on 21/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailOutputDelegate.h"
#import "DetailViewControllerViewModel.h"

@protocol DetailOutput <NSObject>

@property (nonatomic, weak) id <DetailOutputDelegate> delegate;
@property (nonatomic, strong) DetailViewControllerViewModel *viewModel;

@end
