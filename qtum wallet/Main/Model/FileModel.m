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
@property (nonatomic, strong, readwrite, nullable) id object;
@end

@implementation FileModel

#pragma mark - Lifecycle

- (instancetype)initWithUploadResponseObject:(NSDictionary *)uploadResponseObject registerResponseObject:(NSDictionary *)registerResponseObject object:(nullable id)object {
    self = [super init];
    if (self) {
        self.fileHash = uploadResponseObject[@"Hash"] ? : @"";
        self.name = uploadResponseObject[@"Name"] ? : @"";
        self.size = uploadResponseObject[@"Size"] ? [NSNumber numberWithInteger:[uploadResponseObject[@"Size"] integerValue]] : @(0);
        self.amount = registerResponseObject[@"amount"] ? [NSNumber numberWithInteger:[uploadResponseObject[@"amount"] floatValue]] : @(0.0);
        self.txID = registerResponseObject[@"txid"] ? : @"";
        
        self.time = @"";
        if (registerResponseObject[@"time"]) {
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            dateFormatter.dateFormat = @"MMM dd";
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[registerResponseObject[@"time"] integerValue]];
            self.time = [dateFormatter stringFromDate:date];
        }
        if (object) {
            self.object = object;
        }
    }
    return self;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.fileHash = [aDecoder decodeObjectForKey:@"fileHash"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.size = [aDecoder decodeObjectForKey:@"size"];
        self.amount = [aDecoder decodeObjectForKey:@"amount"];
        self.txID = [aDecoder decodeObjectForKey:@"txID"];
        self.time = [aDecoder decodeObjectForKey:@"time"];
        self.object = [aDecoder decodeObjectForKey:@"object"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.fileHash forKey:@"fileHash"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.size forKey:@"size"];
    [coder encodeObject:self.amount forKey:@"amount"];
    [coder encodeObject:self.txID forKey:@"txID"];
    [coder encodeObject:self.time forKey:@"time"];
    [coder encodeObject:self.object forKey:@"object"];
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
