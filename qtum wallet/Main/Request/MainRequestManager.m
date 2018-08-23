//
//  MainRequestManager.m
//  qtum wallet
//
//  Created by HenryFan on 18/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import "MainRequestManager.h"
#import "MainNetworkingService.h"
#import "AFNetworking.h"

@interface MainRequestManager ()
@property (strong, nonatomic) MainNetworkingService *networkService;
@end

static NSString * const kBSXUploadURL = @"http://ipfs.joecwu.com:5001/api/v0/add";

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

- (void)uploadFile:(NSData *)data name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kBSXUploadURL parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:name fileName:fileName mimeType:mimeType];
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        failure(error);
    }];
}

#pragma mark - Balance

@end
