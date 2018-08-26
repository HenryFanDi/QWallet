//
//  FileManager.h
//  qtum wallet
//
//  Created by HenryFan on 26/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FileModel;

@interface FileManager : NSObject
@property (nonatomic, strong, readonly) NSArray <FileModel *> *files;

- (NSArray <FileModel *> *)readFiles;

- (void)addNewFile:(FileModel *)file;

@end
