//
//  MainNetworkingServiceProtocol.h
//  qtum wallet
//
//  Created by HenryFan on 18/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkDefenitions.h"

@protocol MainNetworkingServiceProtocol <NSObject>

- (instancetype _Nullable)initWithBaseUrl:(NSString *_Nonnull)baseUrl;

- (void)uploadTask:(NSURL *)URL data:(NSData *)data success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

- (void)requestWithType:(RequestType)type
                   path:(NSString *_Nonnull)path
              andParams:(NSDictionary *_Nullable)param
     withSuccessHandler:(void (^ _Nullable)(id _Nonnull responseObject))success
      andFailureHandler:(void (^ _Nullable)(NSError *_Nonnull error, NSString *_Nullable message))failure;

@optional
@property (nonatomic, readwrite, copy, nullable) NSString *accessToken;

@end
