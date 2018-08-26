//
//  FileManager.m
//  qtum wallet
//
//  Created by HenryFan on 26/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import "FileManager.h"

@interface FileManager ()
@property (nonatomic, strong, readwrite) NSArray <FileModel *> *files;
@end

@implementation FileManager

#pragma mark - Public Methods

- (NSArray <FileModel *> *)readFiles {
    NSString *path = [self pathByAppendingApplicationSupportDirectory];
    self.files = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    return self.files;
}

- (void)addNewFile:(FileModel *)file {
    NSMutableArray <FileModel *> *newFiles = [NSMutableArray arrayWithArray:self.files];
    [newFiles addObject:file];
    self.files = [newFiles copy];
    
    [self writeFiles];
}

#pragma mark - Private Methods

- (NSString *)pathByAppendingApplicationSupportDirectory {
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [directory stringByAppendingPathComponent:@"files.dat"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createFileAtPath:path contents:nil attributes:nil];
    }
    return path;
}

- (void)writeFiles {
    NSString *path = [self pathByAppendingApplicationSupportDirectory];
    if ([[NSKeyedArchiver archivedDataWithRootObject:self.files] writeToFile:path atomically:YES]) {
        NSLog(@"NSKeyedArchiver : writeToFile success!");
    } else {
        NSLog(@"NSKeyedArchiver : writeToFile failure!");
    }
}

@end
