//
//  MainRequestManager.m
//  qtum wallet
//
//  Created by HenryFan on 18/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import "MainRequestManager.h"
#import "MainNetworkingService.h"

@interface MainRequestManager ()
@property (strong, nonatomic) MainNetworkingService *networkService;
@end

@implementation MainRequestManager

#pragma mark - Lifecycle

- (instancetype)initWithBaseUrl:(NSString *)baseUrl {
    self = [super init];
    if (self != nil) {
        _networkService = [[MainNetworkingService alloc] initWithBaseUrl:baseUrl];
    }
    return self;
}

#pragma mark - Upload

- (void)uploadFile:(NSData *)data success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure {
    NSURL *URL = [NSURL URLWithString:@"http://ipfs.joecwu.com:5001/api/v0/add"];
    [self.networkService uploadTask:URL data:data success:success failure:failure];
}

#pragma mark - Balance

@end
