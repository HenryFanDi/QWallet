//
//  FileModel.h
//  qtum wallet
//
//  Created by HenryFan on 24/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileModel : NSObject <NSCoding>
@property (nonatomic, strong, readonly) NSString *fileHash;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSNumber *size;
@property (nonatomic, strong, readonly) NSString *txID;
@property (nonatomic, strong, readonly) NSString *time;
@property (nonatomic, strong, readonly, nullable) id object;
@property (nonatomic, strong, readonly) NSString *wallet;
@property (nonatomic, strong, readonly) NSNumber *balance;

- (instancetype)initWithUploadResponseObject:(NSDictionary *)uploadResponseObject
                      registerResponseObject:(NSDictionary *)registerResponseObject
                 walletBalanceResponseObject:(NSDictionary *)walletBalanceResponseObject
                                      object:(nullable id)object;

@end
