//
//  FileModel.m
//  qtum wallet
//
//  Created by HenryFan on 24/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import "FileModel.h"

@interface FileModel ()
@property (nonatomic, strong, readwrite) NSString *fileHash;
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSNumber *size;
@property (nonatomic, strong, readwrite) NSNumber *amount;
@property (nonatomic, strong, readwrite) NSString *txID;
@property (nonatomic, strong, readwrite) NSString *time;
@end

@implementation FileModel

#pragma mark - Lifecycle

- (instancetype)initWithUploadResponseObject:(NSDictionary *)uploadResponseObject registerResponseObject:(NSDictionary *)registerResponseObject {
    self = [super init];
    if (self) {
        self.fileHash = uploadResponseObject[@"Hash"] ? : @"";
        self.name = uploadResponseObject[@"Name"] ? : @"";
        self.size = uploadResponseObject[@"Size"] ? [NSNumber numberWithInteger:[uploadResponseObject[@"Size"] integerValue]] : @(0);
        self.amount = registerResponseObject[@"amount"] ? [NSNumber numberWithInteger:[uploadResponseObject[@"amount"] integerValue]] : @(0);
        self.txID = registerResponseObject[@"txid"] ? : @"";
        
        self.time = @"";
        if (registerResponseObject[@"time"]) {
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            dateFormatter.dateFormat = @"MMM dd";
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[registerResponseObject[@"time"] integerValue]];
            self.time = [dateFormatter stringFromDate:date];
        }
    }
    return self;
}

#pragma mark - Private Methods

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}

@end
