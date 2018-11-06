//
//  MainRequestable.h
//  qtum wallet
//
//  Created by HenryFan on 23/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MainRequestable <NSObject>

// Upload
- (void)uploadFile:(NSData *)data name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

// Register
- (void)registerFile:(NSString *)fileHash success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

// Get Wallet Balance
- (void)getWalletBalance:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

@end