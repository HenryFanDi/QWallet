//
//  ContractManager.m
//  qtum wallet
//
//  Created by Vladimir Lebedevich on 12.04.17.
//  Copyright © 2017 QTUM. All rights reserved.
//

#import "ContractManager.h"
#import "HistoryElement.h"
#import "FXKeychain.h"
#import "Contract.h"
#import "NSData+Extension.h"
#import "SocketManager.h"
#import "InterfaceInputFormModel.h"
#import "WalletManagerRequestAdapter.h"


NSString *const kTokenKeys = @"qtum_token_tokens_keys";
NSString *const kTokenDidChange = @"kTokenDidChange";
NSString *const kContractCreationFailed = @"kContractCreationFailed";

NSString *const kSmartContractPretendentsKey = @"smartContractPretendentsKey";
NSString *const kTemplateModel = @"kTemplateModel";
NSString *const kAddresses = @"kAddress";
NSString *const kLocalContractName = @"kLocalContractName";


@interface ContractManager () <TokenDelegate>

@property (strong, nonatomic) NSMutableDictionary* smartContractPretendents;
@property (nonatomic, strong) NSMutableArray<Contract*> *contracts;
@property (assign, nonatomic) BOOL observingForSpendableFailed;
@property (assign, nonatomic) BOOL observingForSpendableStopped;
@property (assign, nonatomic) BOOL haveAuthUser;

@end

@implementation ContractManager

+ (instancetype)sharedInstance {
    
    static ContractManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super alloc] initUniqueInstance];
    });
    return instance;
}

- (instancetype)initUniqueInstance {
    
    self = [super init];
    if (self != nil) {
        [self load];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didContinieObservingForSpendable)
                                                     name:kSocketDidConnect object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didForceStopObservingForSpendable)
                                                     name:kSocketDidDisconnect object:nil];
    }
    return self;
}

-(void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Observing

-(void)didContinieObservingForSpendable {
    
    if (self.observingForSpendableFailed && !self.observingForSpendableStopped) {
        [self startObservingForAllSpendable];
    }
    self.observingForSpendableFailed = NO;
}

-(void)didForceStopObservingForSpendable {
    
    self.observingForSpendableFailed = YES;
}

#pragma mark - Lazy Getters

-(NSMutableDictionary*)smartContractPretendents{
    
    if (!_smartContractPretendents) {
        _smartContractPretendents = @{}.mutableCopy;
    }
    return _smartContractPretendents;
}

- (NSMutableArray<Contract*>*)contracts {
    
    if (!_contracts) {
        _contracts = @[].mutableCopy;
    }
    return _contracts;
}

#pragma mark - Keychain Methods

- (BOOL)save {
    
    BOOL isSavedTokens = [[FXKeychain defaultKeychain] setObject:self.contracts forKey:kTokenKeys];
    
    BOOL isSavedPretendents = [[FXKeychain defaultKeychain] setObject:[self.smartContractPretendents copy] forKey:kSmartContractPretendentsKey];
    return isSavedTokens && isSavedPretendents;
}

- (void)load {
    
    [NSKeyedUnarchiver setClass:[Contract class] forClassName:@"Token"];
    NSMutableArray *savedTokens = [[[FXKeychain defaultKeychain] objectForKey:kTokenKeys] mutableCopy];
    
    for (Contract *token in savedTokens) {
        token.delegate = self;
        token.manager = self;
        [token loadToMemory];
    }
    self.smartContractPretendents = [[[FXKeychain defaultKeychain] objectForKey:kSmartContractPretendentsKey] mutableCopy];
    self.contracts = savedTokens;
}


#pragma mark - Private Methods

- (BOOL)validateContractAddress:(NSString *)contractAddress {
    
    NSString *addresRegex = @"[0-9a-f]{40,}";
    NSPredicate *addressPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", addresRegex];
    return [addressPredicate evaluateWithObject:contractAddress];
}

#pragma mark - Public Methods

- (void)removeContract:(Contract*)contract {
    
    if (!contract) {
        return;
    }
    
    [self.contracts removeObject:contract];
    [[ApplicationCoordinator sharedInstance].requestManager stopObservingForToken:contract];
    [self tokenDidChange:nil];
}

- (void)removeContractPretendentWithTxHash:(NSString*)txHash {
    
    [self.smartContractPretendents removeObjectForKey:txHash];
    [self save];
}

- (NSArray <Contract*>*)allTokens {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"templateModel.type == %i",TokenType];
    return [self.contracts filteredArrayUsingPredicate:predicate];
}

- (NSArray <Contract*>*)allActiveTokens {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"templateModel.type == %i && isActive == YES",TokenType];
    return [self.contracts filteredArrayUsingPredicate:predicate];
}

- (NSArray <Contract*>*)allContracts {
    
    return self.contracts;
}

- (NSDictionary*)smartContractPretendentsCopy {
    return [self.smartContractPretendents copy];
}

- (void)addNewToken:(Contract*) token {
    
    if (!token) {
        return;
    }
    
    token.delegate = self;
    [self.contracts addObject:token];
    [[ApplicationCoordinator sharedInstance].requestManager startObservingForToken:token withHandler:nil];
    [self tokenDidChange:token];
}

- (void)updateTokenWithContractAddress:(NSString*) address withAddressBalanceDictionary:(NSDictionary*) addressBalance {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contractAddress == %@",address];
    NSArray *filteredArray = [self.contracts filteredArrayUsingPredicate:predicate];
    Contract* token = filteredArray.count ? filteredArray[0] : nil;
    if (token) {
        NSMutableDictionary* newAddressBalance = token.addressBalanceDictionary ? [token.addressBalanceDictionary mutableCopy] : @{}.mutableCopy;
        for (NSDictionary* dict in addressBalance[@"balances"]) {
            
            NSString* addressKey = dict[@"address"];
            NSString* balance = dict[@"balance"];

            if (balance) {
                if ([balance isKindOfClass:[NSNumber class]]) {
                    newAddressBalance[addressKey] = [[QTUMBigNumber alloc] initWithString:[(NSNumber*)balance stringValue]];
                } else if ([balance isKindOfClass:[NSString class]]) {
                    newAddressBalance[addressKey] = [[QTUMBigNumber alloc] initWithString:balance];
                }
            }
        }
        token.addressBalanceDictionary = [newAddressBalance copy];
        [self tokenDidChange:token];
    }
}

- (void)removeAllTokens{
    
    [self.contracts removeAllObjects];
}

- (void)removeAllPretendents{
    
    [self.smartContractPretendents removeAllObjects];
}

-(void)addSmartContractPretendent:(NSArray*) addresses
                           forKey:(NSString*) key
                     withTemplate:(TemplateModel*)templateModel
             andLocalContractName:(NSString*) localName{
    

    if (localName) {
        
        self.smartContractPretendents[key] = @{kAddresses : addresses,
                                               kTemplateModel : templateModel,
                                               kLocalContractName : localName};
    } else {
        self.smartContractPretendents[key] = @{kAddresses : addresses,
                                               kTemplateModel : templateModel};
    }
    
    [self save];
}

-(void)deleteSmartContractPretendentWithKey:(NSString*) key{
    
    [self.smartContractPretendents removeObjectForKey:key];
}

-(void)updateSmartContractPretendent:(BTCTransaction*) transaction{
    //TODO update Token Transaction
}

- (void)checkSmartContractPretendents {
    
    for (NSString* txHash in self.smartContractPretendents) {
        
        [[ApplicationCoordinator sharedInstance].walletManager.requestAdapter updateHistoryElementWithTxHash:txHash withSuccessHandler:^(HistoryElement *historyItem) {
            
            if (historyItem) {
                [self checkSmartContract:historyItem];
            }
            
        } andFailureHandler:^(NSError *error, NSString *message) {
            
            DLog(@"Invalid hisory response");
        }];
    }
}

-(void)checkSmartContract:(HistoryElement*) item {
    
    if ([[[ApplicationCoordinator sharedInstance].walletManager hashTableOfKeys] allKeys].count == 0) {
        return;
    }
    
    if (item.confirmed && item.isSmartContractCreater && [self.smartContractPretendents objectForKey:item.txHash] ) {
        
        NSString* key = item.txHash;
        NSDictionary* tokenInfo = self.smartContractPretendents[key];
        NSArray* addresses = tokenInfo[kAddresses];
        NSString* localContractName = tokenInfo[kLocalContractName];

        TemplateModel* templateModel = (TemplateModel*)tokenInfo[kTemplateModel];
        NSMutableData* hashData = [[NSData reverseData:[NSString dataFromHexString:key]] mutableCopy];
        NSString* contractAddress = [NSString hexadecimalString:hashData];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contractAddress == %@",contractAddress];
        NSArray *filteredArray = [self.contracts filteredArrayUsingPredicate:predicate];
        
        if (tokenInfo && !filteredArray.count) {
            Contract* token = [Contract new];
            uint32_t vinIndex = 0;
            [hashData appendBytes:&vinIndex length:4];
            hashData = [[hashData BTCHash160] mutableCopy];
            token.contractCreationAddressAddress = addresses.firstObject;
            token.adresses =  [[[ApplicationCoordinator sharedInstance].walletManager hashTableOfKeys] allKeys];
            token.contractAddress = [NSString hexadecimalString:hashData];
            token.localName = localContractName ?: [token.contractAddress substringToIndex:15];
            token.templateModel = templateModel;
            token.creationDate = [NSDate date];
            token.isActive = YES;
            //[token setupWithHashTransaction:key andAddresses:addresses andTokenTemplate:templateModel];
            [self addNewToken:token];
            token.manager = self;
            [[ApplicationCoordinator sharedInstance].notificationManager createLocalNotificationWithString:NSLocalizedString(@"Contract Created", nil) andIdentifire:@"contract_created"];
            [self updateSpendableObject:token];
            [self deleteSmartContractPretendentWithKey:key];
            [self save];
        }
    } else if (item.confirmed && [self.smartContractPretendents objectForKey:item.txHash]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kContractCreationFailed object:nil];
    }
}

-(void)addNewTokenWithContractAddress:(NSString*) contractAddress {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contractAddress == %@",contractAddress];
    NSArray *filteredArray = [self.contracts filteredArrayUsingPredicate:predicate];
    
    if (!filteredArray.count && contractAddress) {
        
        Contract* token = [Contract new];
        token.contractAddress = contractAddress;
        token.creationDate = [NSDate date];
        token.localName = [token.contractAddress substringToIndex:contractAddress.length > 15 ? 15 : contractAddress.length];
        token.adresses = [[[ApplicationCoordinator sharedInstance].walletManager hashTableOfKeys] allKeys];
        //[token setupWithContractAddresse:contractAddress];
        token.manager = self;
        [self addNewToken:token];
        [[ApplicationCoordinator sharedInstance].notificationManager createLocalNotificationWithString:NSLocalizedString(@"Contract Created", nil) andIdentifire:@"contract_created"];
        [self updateSpendableObject:token];
        [self tokenDidChange:nil];
    }
}

-(BOOL)addNewContractWithContractAddress:(NSString*) contractAddress
                                 withAbi:(NSString*) abiStr
                             andWithName:(NSString*) contractName
                             errorString:(NSString **)errorString {
    
    if (!contractName || contractName.length == 0) {
        *errorString = NSLocalizedString(@"Invalid Contract Name", nil);
        return NO;
    }
    
    if (![self validateContractAddress:contractAddress]) {
        *errorString = NSLocalizedString(@"Invalid Contract Address", nil);
        return NO;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contractAddress == %@",contractAddress];
    NSArray *filteredArray = [self.contracts filteredArrayUsingPredicate:predicate];
    if (filteredArray.count > 0) {
        *errorString = NSLocalizedString(@"Contract with same address already exists", nil);
        return NO;
    }

    Contract* contract = [Contract new];
    contract.contractAddress = contractAddress;
    contract.creationDate = [NSDate date];
    contract.localName = contractName;
    contract.adresses = [[[ApplicationCoordinator sharedInstance].walletManager hashTableOfKeys] allKeys];
    contract.manager = self;
    
    TemplateModel* template = [SLocator.templateManager createNewContractTemplateWithAbi:abiStr contractAddress:contractAddress andName:contractName];
    
    if (template) {
        
        contract.templateModel = template;
        [self addNewToken:contract];
        [[ApplicationCoordinator sharedInstance].notificationManager createLocalNotificationWithString:NSLocalizedString(@"Contract Created", nil) andIdentifire:@"contract_created"];
        [self updateSpendableObject:contract];
        [self tokenDidChange:nil];
        return YES;
    }
    
    *errorString = NSLocalizedString(@"Something went wrong", nil);
    return NO;
}

- (BOOL)addNewTokenWithContractAddress:(NSString*) contractAddress
                               withAbi:(NSString*) abiStr
                           andWithName:(NSString*) contractName
                           errorString:(NSString **)errorString {
    
    if (!contractName || contractName.length == 0) {
        
        *errorString = NSLocalizedString(@"Invalid Token Name", nil);
        return NO;
    }
    
    if (![self validateContractAddress:contractAddress]) {
        *errorString = NSLocalizedString(@"Invalid Token Address", nil);
        return NO;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contractAddress == %@", contractAddress];
    NSArray *filteredArray = [self.allTokens filteredArrayUsingPredicate:predicate];
    if (filteredArray.count > 0) {
        *errorString = NSLocalizedString(@"Token with same address already exists", nil);
        return NO;
    }
    
    InterfaceInputFormModel* interfaceInput = [[InterfaceInputFormModel alloc] initWithAbi:[SLocator.contractInterfaceManager arrayFromAbiString:abiStr]];
    InterfaceInputFormModel* qrc20interfaceInput = [SLocator.contractInterfaceManager tokenQRC20Interface];
    
    if (![interfaceInput contains:qrc20interfaceInput]) {
        *errorString = NSLocalizedString(@"ABI doesn't match QRC20 standard", nil);
        return NO;
    }
    
    Contract* contract = [Contract new];
    contract.contractAddress = contractAddress;
    contract.creationDate = [NSDate date];
    contract.localName = contractName;
    contract.adresses = [[[ApplicationCoordinator sharedInstance].walletManager hashTableOfKeys] allKeys];
    contract.manager = self;
    contract.isActive = YES;
    
    TemplateModel* template = [SLocator.templateManager createNewTokenTemplateWithAbi:abiStr contractAddress:contractAddress andName:contractName];
    
    if (template) {
        [SLocator.templateManager saveTemplate:template];
        contract.templateModel = template;
        [self addNewToken:contract];
        [[ApplicationCoordinator sharedInstance].notificationManager createLocalNotificationWithString:NSLocalizedString(@"Token Created", nil) andIdentifire:@"contract_created"];
        [self updateSpendableObject:contract];
        [self tokenDidChange:nil];
        
        return YES;
    }
    
    *errorString = NSLocalizedString(@"Something went wrong", nil);
    return NO;
}

#pragma mark - TokenDelegate

- (void)tokenDidChange:(id)token {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTokenDidChange object:nil userInfo:nil];
    [self save];
}

#pragma mark - Managerable

-(void)updateSpendableObject:(Contract*) token {
    
    __weak __typeof(self)weakSelf = self;
    
    if (token.templateModel.type == TokenType) {
        
        AbiinterfaceItem* nameProperty = [SLocator.contractInterfaceManager tokenStandartNamePropertyInterface];
        AbiinterfaceItem* totalSupplyProperty = [SLocator.contractInterfaceManager tokenStandartTotalSupplyPropertyInterface];
        AbiinterfaceItem* symbolProperty = [SLocator.contractInterfaceManager tokenStandartSymbolPropertyInterface];
        AbiinterfaceItem* decimalProperty = [SLocator.contractInterfaceManager tokenStandartDecimalPropertyInterface];
        
        NSString* hashFuctionName = [SLocator.contractInterfaceManager stringHashOfFunction:nameProperty];
        NSString* hashFuctionTotalSupply = [SLocator.contractInterfaceManager stringHashOfFunction:totalSupplyProperty];
        NSString* hashFuctionSymbol = [SLocator.contractInterfaceManager stringHashOfFunction:symbolProperty];
        NSString* hashFuctionDecimal = [SLocator.contractInterfaceManager stringHashOfFunction:decimalProperty];
        
        [[ApplicationCoordinator sharedInstance].requestManager callFunctionToContractAddress:token.contractAddress
                                                                                 frommAddress:nil
                                                                                   withHashes:@[hashFuctionName, hashFuctionTotalSupply, hashFuctionSymbol, hashFuctionDecimal] withHandler:^(id responseObject) {
            
            if (![responseObject isKindOfClass:[NSError class]] && [responseObject[@"items"] isKindOfClass:[NSArray class]]) {
                
                for (NSDictionary* item in responseObject[@"items"]) {
                    NSString* hash = item[@"hash"];
                    NSString* output = item[@"output"];
                    
                    if ([hash isEqualToString:hashFuctionName.uppercaseString]) {
                        NSArray* array = [SLocator.contractArgumentsInterpretator аrrayFromContractArguments:[NSString dataFromHexString:output] andInterface:nameProperty];
                        if (array.count > 0) {
                            token.name = array[0];
                        }
                    } else if ([hash isEqualToString:hashFuctionTotalSupply.uppercaseString]) {
                        
                        NSArray* array = [SLocator.contractArgumentsInterpretator аrrayFromContractArguments:[NSString dataFromHexString:output] andInterface:totalSupplyProperty];
                        if (array.count > 0) {
                            token.totalSupply = array[0];
                        }
                        
                    } else if ([hash isEqualToString:hashFuctionSymbol.uppercaseString]) {
                        
                        NSArray* array = [SLocator.contractArgumentsInterpretator аrrayFromContractArguments:[NSString dataFromHexString:output] andInterface:symbolProperty];
                        if (array.count > 0) {
                            token.symbol = array[0];
                        }
                    } else if ([hash isEqualToString:hashFuctionDecimal.uppercaseString]) {
                        
                        NSArray* array = [SLocator.contractArgumentsInterpretator аrrayFromContractArguments:[NSString dataFromHexString:output] andInterface:decimalProperty];
                        if (array.count > 0) {
                            token.decimals = array[0];
                        }
                    }
                }
            }
            [weakSelf tokenDidChange:token];
        }];
    }
}

-(void)updateBalanceOfSpendableObject:(id <Spendable>) object withHandler:(void (^)(BOOL))complete {
    [complete copy];
    complete(NO);
    DLog(@"complete ->%@",complete);
}

-(void)updateHistoryOfSpendableObject:(id <Spendable>) object withHandler:(void (^)(BOOL))complete andPage:(NSInteger) page{
    [complete copy];
    complete(NO);
    object.historyStorage.pageIndex = page;
    DLog(@"complete ->%@",complete);
}

-(void)startObservingForSpendable:(id <Spendable>) spendable {
    
    self.observingForSpendableStopped = NO;
    [[ApplicationCoordinator sharedInstance].requestManager startObservingForToken:spendable withHandler:nil];
}

-(void)stopObservingForSpendable:(id <Spendable>) spendable {
    
    self.observingForSpendableStopped = YES;
    [[ApplicationCoordinator sharedInstance].requestManager stopObservingForToken:spendable];
}

-(void)startObservingForAllSpendable {
    
    NSArray <Contract*>* activeContract = [self allActiveTokens];
    for (Contract* token in activeContract) {
        [[ApplicationCoordinator sharedInstance].requestManager startObservingForToken:token withHandler:nil];
    }
}

-(void)stopObservingForAllSpendable {
    NSArray <Contract*>* activeContract = [self allActiveTokens];
    for (Contract* token in activeContract) {
        [[ApplicationCoordinator sharedInstance].requestManager stopObservingForToken:token];
    }
}

-(void)loadSpendableObjects {
    [self load];
}

-(void)saveSpendableObjects {
    [self save];
}

-(void)updateSpendableWithObject:(id) updateObject{
    
}


-(void)updateSpendablesBalansesWithObject:(id) updateObject{
    
}

-(void)updateSpendablesHistoriesWithObject:(id) updateObject{
    
}

-(void)spendableDidChange:(id <Spendable>) object{
    [self tokenDidChange:object];
}

-(void)clear {
    
    [self removeAllTokens];
    [self removeAllPretendents];
    [self save];
}

#pragma mark - Backup

static NSString* kPublishDate = @"publish_date";
static NSString* kNameKey = @"name";
static NSString* kContractAddressKey = @"contract_address";
static NSString* kContractCreationAddressKey = @"contract_creation_address";
static NSString* kIsActiveKey = @"is_active";
static NSString* kTypeKey = @"type";
static NSString* kTemplateKey = @"template";

-(NSArray<NSDictionary*>*)decodeDataForBackup {
    
    NSMutableArray* backupArray = @[].mutableCopy;
    
    for (int i = 0; i < self.contracts.count; i++) {
        NSMutableDictionary* backupItem = @{}.mutableCopy;
        Contract* contract = self.contracts[i];
        backupItem[kPublishDate] = contract.creationFormattedDateString;
        backupItem[kNameKey] = contract.localName;
        backupItem[kContractAddressKey] = contract.contractAddress;
        backupItem[kContractCreationAddressKey] = contract.contractCreationAddressAddress ?: @"";
        backupItem[kIsActiveKey] = @(contract.isActive);
        backupItem[kTypeKey] = contract.templateModel.templateTypeStringForBackup;
        backupItem[kTemplateKey] = contract.templateModel.uuid;
        [backupArray addObject:backupItem];
    }
    
    return backupArray.copy;
}

-(BOOL)encodeDataForBacup:(NSArray<NSDictionary*>*) backup withTemplates:(NSArray<TemplateModel*>*) templates {
    
    BOOL processedWithoutError = YES;
    
    for (NSDictionary* contractDict in backup) {

        Contract* contract = [Contract new];
        contract.localName = contractDict[kNameKey];
        contract.contractAddress = contractDict[kContractAddressKey];
        contract.contractCreationAddressAddress = contractDict[kContractCreationAddressKey];
        contract.creationDate = [NSDate date];
        contract.isActive = [contractDict[kIsActiveKey] boolValue];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %@",contractDict[kTemplateKey]];
        NSArray* filteredTemplates = [templates filteredArrayUsingPredicate:predicate];
        NSPredicate *predicateForAddress = [NSPredicate predicateWithFormat:@"contractAddress == %@",contract.contractAddress];
        NSArray *filteredContractAddressArray = [self.contracts filteredArrayUsingPredicate:predicateForAddress];
        
        if (filteredTemplates.count > 0 && !filteredContractAddressArray.count) {
            contract.templateModel = filteredTemplates[0];
            [self addNewToken:contract];
            [[ApplicationCoordinator sharedInstance].notificationManager createLocalNotificationWithString:NSLocalizedString(@"Contract Created", nil) andIdentifire:@"contract_created"];
            [self updateSpendableObject:contract];
            [self save];
            [self tokenDidChange:nil];
        } else {
            processedWithoutError = NO;
        }
    }
    
    return processedWithoutError;
}

@end
