//
//  FileModel.h
//  qtum wallet
//
//  Created by HenryFan on 24/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileModel : NSObject
@property (nonatomic, strong, readonly) NSString *fileHash;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSNumber *size;
@property (nonatomic, strong, readonly) NSNumber *amount;
@property (nonatomic, strong, readonly) NSString *txID;
@property (nonatomic, strong, readonly) NSString *time;

- (instancetype)initWithUploadResponseObject:(NSDictionary *)uploadResponseObject registerResponseObject:(NSDictionary *)registerResponseObject;

@end
