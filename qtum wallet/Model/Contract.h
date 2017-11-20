//
//  TokenModel.h
//  qtum wallet
//
//  Created by Vladimir Lebedevich on 17.04.17.
//  Copyright © 2017 QTUM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HistoryElementProtocol.h"
#import "Managerable.h"
#import "TemplateModel.h"
#import "ContractManager.h"
#import "QTUMBigNumber.h"

@class Contract;

@protocol TokenDelegate <NSObject>

@required
- (void)tokenDidChange:(Contract *)contract;

@end

@interface Contract : NSObject <Spendable>

@property (copy, nonatomic) NSString* name;
@property (copy, nonatomic) NSString* localName;
@property (assign, nonatomic) BOOL isActive;
@property (strong, nonatomic) QTUMBigNumber *balance;
@property (strong, nonatomic) QTUMBigNumber *unconfirmedBalance;
@property (copy, nonatomic)NSArray <HistoryElementProtocol>*historyArray;
@property (copy, nonatomic)NSString* mainAddress;
@property (copy, nonatomic)NSString* symbol;
@property (weak, nonatomic) ContractManager* manager;
@property (strong, nonatomic) HistoryDataStorage* historyStorage;

@property (copy, nonatomic)NSString* contractAddress;
@property (copy, nonatomic)NSString* contractCreationAddressAddress;
@property (copy, nonatomic)NSArray* adresses;
@property (strong, nonatomic) QTUMBigNumber* decimals;
@property (strong, nonatomic) QTUMBigNumber* totalSupply;
@property (strong, nonatomic) TemplateModel* templateModel;
@property (strong, nonatomic) NSDate* creationDate;
@property (copy, nonatomic, readonly) NSString* creationDateString;
@property (copy, nonatomic, readonly) NSString* creationFormattedDateString;
@property (copy, nonatomic, readonly) NSDictionary <NSString*,NSDictionary<NSString*,NSString*>*>* addressBalanceDivByDecimalDictionary;
@property (copy, nonatomic) NSDictionary <NSString*,QTUMBigNumber*>* addressBalanceDictionary;
@property (nonatomic, weak) id<TokenDelegate> delegate;

- (NSString*)balanceString;
- (NSString*)shortBalanceString;
- (NSString*)totalSupplyString;
- (NSString*)shortTotalSupplyString;

@end
