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
@end

static NSString * const kBSXUploadURL = @"http://ipfs.comehere.app/api/v0/add";
static NSString * const kBSXRegisterURL = @"http://qtum.comehere.app/register";
static NSString * const kBSXGetWalletBalanceURL = @"http://qtum.comehere.app/balance";

@implementation MainRequestManager

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

#pragma mark - Register

- (void)registerFile:(NSString *)fileHash success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure {
    MainNetworkingService *networkService = [[MainNetworkingService alloc] initWithBaseUrl:kBSXRegisterURL];
    networkService.senderAddress = @"qR7LMJGTNTktrhd5AUeyNkGQNAnPzdX5eu";
    [networkService requestWithType:POST path:fileHash andParams:nil withSuccessHandler:^(id  _Nonnull responseObject) {
        success(responseObject);
    } andFailureHandler:^(NSError * _Nonnull error, NSString * _Nullable message) {
        failure(error);
    }];
}

#pragma mark - Get Wallet Balance

- (void)getWalletBalance:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure {
    MainNetworkingService *networkService = [[MainNetworkingService alloc] initWithBaseUrl:kBSXGetWalletBalanceURL];
    NSString *walletAddress = @"qVuqcjpBmRYGjjVZm1q1LFa28KJGQYPepC";
    [networkService requestWithType:GET path:walletAddress andParams:nil withSuccessHandler:^(id  _Nonnull responseObject) {
        success(responseObject);
    } andFailureHandler:^(NSError * _Nonnull error, NSString * _Nullable message) {
        failure(error);
    }];
}

@end
