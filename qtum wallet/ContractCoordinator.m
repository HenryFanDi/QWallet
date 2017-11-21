//
//  ContractCoordinator.m
//  qtum wallet
//
//  Created by Vladimir Lebedevich on 03.03.17.
//  Copyright © 2017 QTUM. All rights reserved.
//

#import "ContractCoordinator.h"
#import "BTCTransactionInput+Extension.h"
#import "ConstructorFromAbiViewController.h"
#import "CreateTokenFinishViewController.h"
#import "TemplateTokenViewController.h"
#import "SmartContractMenuViewController.h"
#import "SmartContractsListViewController.h"
#import "TokenFunctionViewController.h"
#import "TokenFunctionDetailViewController.h"
#import "WatchContractViewController.h"
#import "WatchTokensViewController.h"
#import "RestoreContractsViewController.h"
#import "BackupContractsViewController.h"

#import "QStoreCoordinator.h"

#import "LibraryOutput.h"


@interface ContractCoordinator () <LibraryOutputDelegate,
LibraryTableSourceOutputDelegate,
FavouriteTemplatesCollectionSourceOutputDelegate,
WatchContractOutputDelegate,
SmartContractMenuOutputDelegate,
PublishedContractListOutputDelegate,
TemplatesListOutputDelegate,
RestoreContractsOutputDelegate,
BackupContractOutputDelegate,
ConstructorAbiOutputDelegate,
ContractFunctionDetailOutputDelegate,
ContractFunctionsOutputDelegate,
ContractCreationEndOutputDelegate>

@property (strong, nonatomic) UINavigationController* navigationController;
@property (strong, nonatomic) UINavigationController* modalNavigationController;
@property (strong,nonatomic) NSArray<ResultTokenInputsModel*>* inputs;
@property (strong,nonatomic) TemplateModel* templateModel;

@property (weak, nonatomic) NSObject <ContractFunctionDetailOutput>* functionDetailController;
@property (weak, nonatomic) CreateTokenFinishViewController *createFinishViewController;
@property (weak, nonatomic) NSObject <SmartContractMenuOutput>* smartContractMenuOutput;

@property (weak, nonatomic) NSObject <WatchContractOutput> *wathContractsViewController;
@property (nonatomic) NSObject<FavouriteTemplatesCollectionSourceOutput> *favouriteContractsCollectionSource;

@property (weak, nonatomic) NSObject <WatchContractOutput> *wathTokensViewController;
@property (nonatomic) NSObject<FavouriteTemplatesCollectionSourceOutput> *favouriteTokensCollectionSource;

@property (weak, nonatomic) NSObject<LibraryOutput> *libraryViewController;
@property (nonatomic) NSObject<LibraryTableSourceOutput> *libraryTableSource;
@property (nonatomic) TemplateModel *activeTemplateForLibrary;
@property (nonatomic) BOOL isLibraryViewControllerOnlyForTokens;
@property (copy, nonatomic) NSString* localContractName;

@property (strong, nonatomic) QStoreCoordinator *qStoreCoordinator;

@end

@implementation ContractCoordinator

-(instancetype)initWithNavigationController:(UINavigationController*)navigationController{
    self = [super init];
    if (self) {
        _navigationController = navigationController;
    }
    return self;
}

#pragma mark - Coordinatorable

-(void)start {
    
    NSObject <SmartContractMenuOutput>* output = (NSObject <SmartContractMenuOutput>*)[SLocator.controllersFactory createSmartContractMenuViewController];
    output.delegate = self;
    self.smartContractMenuOutput = output;
    [self.navigationController pushViewController:[output toPresent] animated:YES];
}

#pragma mark - Private Methods 

-(void)showCreateNewToken {
    
    NSObject <TemplatesListOutput>* output  = [SLocator.controllersFactory createTemplateTokenViewController];
    output.delegate = self;
    output.templateModels = [SLocator.templateManager availebaleTemplates];
    [self.navigationController pushViewController:[output toPresent] animated:YES];
}

-(void)showMyPyblishedContract {
    
    NSObject <PublishedContractListOutput>* output = [SLocator.controllersFactory createSmartContractsListViewController];
    output.delegate = self;
    
    NSArray *sortedContracts = [[SLocator.contractManager allContracts] sortedArrayUsingComparator: ^(Contract *t1, Contract *t2) {
        return [t1.creationDate compare:t2.creationDate];
    }];
    
    output.contracts = sortedContracts;
    output.smartContractPretendents = [SLocator.contractManager smartContractPretendentsCopy];
    if (SLocator.appSettings.isRemovingContractTrainingPassed == NO) {
        [output setNeedShowingTrainingScreen];
    }
    [self.navigationController pushViewController:[output toPresent] animated:YES];
}

-(void)showContractStore {
    self.qStoreCoordinator = [[QStoreCoordinator alloc] initWithNavigationController:self.navigationController];
    [self.qStoreCoordinator start];
}

-(void)showWatchContract {
    
    self.activeTemplateForLibrary = nil;
    
    self.wathContractsViewController = (NSObject <WatchContractOutput>*)[SLocator.controllersFactory createWatchContractViewController];
    self.favouriteContractsCollectionSource = [SLocator.tableSourcesFactory createFavouriteTemplatesSource];
    
    self.favouriteContractsCollectionSource.templateModels = [SLocator.templateManager standartPackOfTemplates];
    self.favouriteContractsCollectionSource.delegate = self;
    self.favouriteContractsCollectionSource.activeTemplate = self.activeTemplateForLibrary;
    
    self.wathContractsViewController.collectionSource = self.favouriteContractsCollectionSource;
    self.wathContractsViewController.delegate = self;
    
    [self.navigationController pushViewController:[self.wathContractsViewController toPresent] animated:YES];
}

-(void)showWatchTokens {
    
    self.activeTemplateForLibrary = nil;
    
    self.wathTokensViewController = (NSObject <WatchContractOutput>*)[SLocator.controllersFactory createWatchTokensViewController];
    self.favouriteTokensCollectionSource = [SLocator.tableSourcesFactory createFavouriteTemplatesSource];
    
    self.favouriteTokensCollectionSource.templateModels = [SLocator.templateManager standartPackOfTokenTemplates];
    self.favouriteTokensCollectionSource.delegate = self;
    self.favouriteTokensCollectionSource.activeTemplate = self.activeTemplateForLibrary;
    
    self.wathTokensViewController.collectionSource = self.favouriteTokensCollectionSource;
    self.wathTokensViewController.delegate = self;
    
    [self.navigationController pushViewController:[self.wathTokensViewController toPresent] animated:YES];
}

-(void)showRestoreContract {
    
    NSObject <RestoreContractsOutput>* output = [SLocator.controllersFactory createRestoreContractViewController];
    output.delegate = self;

    [self.navigationController pushViewController:[output toPresent] animated:YES];
}

-(void)showBackupContract {
    
    BackupContractsViewController* controller = (BackupContractsViewController*)[SLocator.controllersFactory createBackupContractViewController];
    controller.delegate = self;
    
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)showStepWithFieldsAndTemplate:(NSString*)template{
    
    NSObject <ConstructorAbiOutput>* output = [SLocator.controllersFactory createConstructorFromAbiViewController];
    output.delegate = self;
    output.contractTitle = self.templateModel.templateName;
    output.formModel = [SLocator.contractInterfaceManager tokenInterfaceWithTemplate:self.templateModel.path];
    [self.navigationController pushViewController:[output toPresent] animated:YES];
}

-(void)showFinishStepWithInputs:(NSArray<ResultTokenInputsModel*>*) inputs {
    
    CreateTokenFinishViewController* controller = (CreateTokenFinishViewController*)[SLocator.controllersFactory createCreateTokenFinishViewController];
    controller.delegate = self;
    self.inputs = inputs;
    controller.inputs = inputs;
    self.createFinishViewController = controller;
    [self.navigationController pushViewController:controller animated:YES];
    
    __weak typeof(self) weakSelf = self;
    [SLocator.popUpsManager showLoaderPopUp];
    [SLocator.transactionManager getFeePerKbWithHandler:^(QTUMBigNumber *feePerKb) {
        QTUMBigNumber* minFee = feePerKb;
        QTUMBigNumber* maxFee = SLocator.paymentValuesManager.maxFee;
        
        [weakSelf.createFinishViewController setMinFee:minFee andMaxFee: maxFee];
        [weakSelf.createFinishViewController setMinGasPrice:SLocator.paymentValuesManager.minGasPrice andMax:SLocator.paymentValuesManager.maxGasPrice step:GasPriceStep];
        [weakSelf.createFinishViewController setMinGasLimit:SLocator.paymentValuesManager.minGasLimit andMax:SLocator.paymentValuesManager.maxGasLimit standart:SLocator.paymentValuesManager.standartGasLimitForCreateContract step:GasLimitStep];
        [SLocator.popUpsManager dismissLoader];
    }];
}

-(void)showContractsFunction:(Contract*) contract {
    
    if (contract.templateModel) {
        NSObject <ContractFunctionsOutput>* output = [SLocator.controllersFactory createTokenFunctionViewController];
        output.formModel = [SLocator.contractInterfaceManager tokenInterfaceWithTemplate:contract.templateModel.path];
        output.delegate = self;
        output.token = contract;
        [self.navigationController pushViewController:[output toPresent] animated:true];
    }
}

-(void)showChooseFromLibrary:(BOOL)tokensOnly {
    
    self.isLibraryViewControllerOnlyForTokens = tokensOnly;
    self.libraryViewController = [SLocator.controllersFactory createLibraryViewController];
    self.libraryTableSource = [SLocator.tableSourcesFactory createLibrarySource];
    self.libraryTableSource.templetes = [self prepareTemplateList:tokensOnly];
    self.libraryTableSource.activeTemplate = self.activeTemplateForLibrary;
    self.libraryTableSource.delegate = self;
    self.libraryViewController.tableSource = self.libraryTableSource;
    self.libraryViewController.delegate = self;
    [self.navigationController pushViewController:[self.libraryViewController toPresent] animated:YES];
}

- (NSArray<TemplateModel *> *)prepareTemplateList:(BOOL)tokensOnly {
    
    return tokensOnly ? [SLocator.templateManager availebaleTokenTemplates] : [SLocator.templateManager availebaleTemplates];
}

#pragma mark - Logic

-(NSArray*)argsFromInputs{
    
    NSMutableArray* args = @[].mutableCopy;
    for (ResultTokenInputsModel* input in self.inputs) {
        [args addObject:input.value];
    }
    return [args copy];
}

-(NSArray<NSNumber*>*)typesFromInputs{
    
    NSMutableArray* args = @[].mutableCopy;
    for (ResultTokenInputsModel* input in self.inputs) {
        [args addObject:input.value];
    }
    return [args copy];
}


#pragma mark - ContractCoordinatorDelegate

-(void)createStepOneCancelDidPressed{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)finishStepBackDidPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)finishStepCancelDidPressed {
    [self.navigationController popToViewController:[self.smartContractMenuOutput toPresent] animated:YES];
}

-(void)finishStepFinishDidPressed:(QTUMBigNumber *)fee gasPrice:(QTUMBigNumber *)gasPrice gasLimit:(QTUMBigNumber *)gasLimit {
    
    __weak __typeof(self)weakSelf = self;
    [SLocator.popUpsManager showLoaderPopUp];
    
    NSData* contractWithArgs = [SLocator.contractInterfaceManager tokenBitecodeWithTemplate:self.templateModel.path andArray:[self argsFromInputs]];
    
    [SLocator.transactionManager createSmartContractWithKeys:SLocator.walletManager.wallet.allKeys
                                                          andBitcode:contractWithArgs
                                                                 fee:fee
                                                            gasPrice:gasPrice
                                                            gasLimit:gasLimit
                                                          andHandler:^(TransactionManagerErrorType errorType, BTCTransaction *transaction, NSString *hashTransaction, QTUMBigNumber *estimatedValue) {
        [SLocator.popUpsManager dismissLoader];
        if (errorType == TransactionManagerErrorTypeNone) {
            BTCTransactionInput* input = transaction.inputs[0];
            DLog(@"%@",input.runTimeAddress);
            [SLocator.contractManager addSmartContractPretendent:@[input.runTimeAddress] forKey:hashTransaction withTemplate:weakSelf.templateModel andLocalContractName:self.localContractName];
            
            [weakSelf.createFinishViewController showCompletedPopUp];
        } else {
            NSString *errorString;
            if (errorType == TransactionManagerErrorTypeNotEnoughFee) {
                errorString = [NSString stringWithFormat:@"Insufficient fee. Please use minimum of %@ QTUM", estimatedValue];
            }
            if (errorType == TransactionManagerErrorTypeNotEnoughGasLimit) {
                errorString = [NSString stringWithFormat:@"Insufficient gas limit. Please use minimum of %@ QTUM", estimatedValue];
            }
            switch (errorType) {
                case TransactionManagerErrorTypeNotEnoughMoney:
                    [weakSelf.createFinishViewController showErrorPopUp:NSLocalizedString(@"You have insufficient funds for this transaction", nil)];
                    break;
                case TransactionManagerErrorTypeInvalidAddress:
                    [weakSelf.createFinishViewController showErrorPopUp:NSLocalizedString(@"Invalid QTUM Address", nil)];
                    break;
                case TransactionManagerErrorTypeNotEnoughMoneyOnAddress:
                    [weakSelf.createFinishViewController showErrorPopUp:NSLocalizedString(@"You have insufficient funds for this transaction at this address", nil)];
                    break;
                case TransactionManagerErrorTypeNotEnoughFee:
                    [weakSelf.createFinishViewController showErrorPopUp:errorString];
                    break;
                case TransactionManagerErrorTypeNotEnoughGasLimit:
                    [weakSelf.createFinishViewController showErrorPopUp:errorString];
                    break;
                default:
                    [weakSelf.createFinishViewController showErrorPopUp:nil];
                    break;
            }
        }
    }];
}

- (void)didSelectFunctionIndexPath:(NSIndexPath *)indexPath withItem:(AbiinterfaceItem*) item andToken:(Contract*) token fromQStore:(BOOL)fromQStore {
    
    NSObject <ContractFunctionDetailOutput>* output = [SLocator.controllersFactory createTokenFunctionDetailViewController];
    output.function = item;
    output.delegate = self;
    output.token = token;
    output.fromQStore = fromQStore;
    
    __weak __typeof(self)weakSelf = self;
    self.functionDetailController = output;
    [self.navigationController pushViewController:[output toPresent] animated:true];
    
    [weakSelf.functionDetailController showLoader];
    [SLocator.transactionManager getFeePerKbWithHandler:^(QTUMBigNumber *feePerKb) {
        
        QTUMBigNumber* minFee = feePerKb;
        QTUMBigNumber* maxFee = SLocator.paymentValuesManager.maxFee;
        
        [weakSelf.functionDetailController setMinFee:minFee andMaxFee: maxFee];
        [weakSelf.functionDetailController setMinGasPrice:SLocator.paymentValuesManager.minGasPrice andMax:SLocator.paymentValuesManager.maxGasPrice step:GasPriceStep];
        [weakSelf.functionDetailController setMinGasLimit:SLocator.paymentValuesManager.minGasLimit andMax:SLocator.paymentValuesManager.maxGasLimit standart:SLocator.paymentValuesManager.standartGasLimit step:GasLimitStep];
        [weakSelf.functionDetailController hideLoader];
    }];
}

-(void)didPressedQuit {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - ContractFunctionsOutputDelegate

- (void)didSelectFunctionIndexPath:(NSIndexPath *)indexPath withItem:(AbiinterfaceItem*) item andToken:(Contract*) token {
    [self didSelectFunctionIndexPath:indexPath withItem:item andToken:token fromQStore:NO];
}

- (void)didDeselectFunctionIndexPath:(NSIndexPath *)indexPath withItem:(AbiinterfaceItem*) item{
    
}

#pragma mark - ContractFunctionDetailOutputDelegate

- (void)didCallFunctionWithItem:(AbiinterfaceItem*) item
                       andParam:(NSArray<ResultTokenInputsModel*>*)inputs
                       andToken:(Contract*) contract
                        andFee:(QTUMBigNumber *)fee
                    andGasPrice:(QTUMBigNumber *)gasPrice
                    andGasLimit:(QTUMBigNumber *)gasLimit {
    
    NSMutableArray* param = @[].mutableCopy;
    for (int i = 0; i < inputs.count; i++) {
        [param addObject:inputs[i].value];
    }
    
    NSArray<NSString*>* addressWithTokensValue = @[contract.contractCreationAddressAddress];
    
    NSData* hashFuction = [SLocator.contractInterfaceManager hashOfFunction:item appendingParam:param];
    
    [self.functionDetailController showLoader];

    __weak __typeof(self)weakSelf = self;
    
    [SLocator.transactionManager callContractWithAddress:[NSString dataFromHexString:contract.contractAddress]
                                                      andBitcode:hashFuction
                                                   fromAddresses:addressWithTokensValue
                                                       toAddress:nil
                                                      walletKeys:SLocator.walletManager.wallet.allKeys
                                                             fee:fee
                                                        gasPrice:gasPrice
                                                        gasLimit:gasLimit
                                                      andHandler:^(TransactionManagerErrorType errorType, BTCTransaction *transaction, NSString *hashTransaction, QTUMBigNumber* estimatedFee) {
        
       [weakSelf.functionDetailController hideLoader];
       if (errorType == TransactionManagerErrorTypeNotEnoughFee) {
           [weakSelf showStatusOfPayment:errorType withEstimateFee:estimatedFee];
       } else if (errorType == TransactionManagerErrorTypeNotEnoughGasLimit) {
           [weakSelf showStatusOfPayment:errorType withEstimateGasLimit:estimatedFee];
       } else {
           [weakSelf showStatusOfPayment:errorType];
       }
        [weakSelf.functionDetailController showResultViewWithOutputs:nil];
    }];
}

- (void)showStatusOfPayment:(TransactionManagerErrorType)errorType {
    
    switch (errorType) {
        case TransactionManagerErrorTypeNone:
            [self.functionDetailController showCompletedPopUp];
            break;
        case TransactionManagerErrorTypeNoInternetConnection:
            break;
        case TransactionManagerErrorTypeNotEnoughMoney:
            [self.functionDetailController showErrorPopUp:NSLocalizedString(@"You have insufficient funds for this transaction", nil)];
            break;
        case TransactionManagerErrorTypeInvalidAddress:
            [self.functionDetailController showErrorPopUp:NSLocalizedString(@"Invalid QTUM Address", nil)];
            break;
        case TransactionManagerErrorTypeNotEnoughMoneyOnAddress:
            [self.functionDetailController showErrorPopUp:NSLocalizedString(@"You have insufficient funds for this transaction at this address", nil)];
            break;
        default:
            [self.functionDetailController showErrorPopUp:nil];
            break;
    }
}

- (void)showStatusOfPayment:(TransactionManagerErrorType)errorType withEstimateFee:(QTUMBigNumber*) estimatedFee{
    
    NSString* errorString = [NSString stringWithFormat:@"Insufficient fee. Please use minimum of %@ QTUM", estimatedFee.stringValue];
    [self.functionDetailController showErrorPopUp:NSLocalizedString(errorString, nil)];
}

- (void)showStatusOfPayment:(TransactionManagerErrorType)errorType withEstimateGasLimit:(QTUMBigNumber*) gasLimit {
    
    NSString* errorString = [NSString stringWithFormat:@"Insufficient gas limit. Please use minimum of %@ QTUM", gasLimit.stringValue];
    [self.functionDetailController showErrorPopUp:NSLocalizedString(errorString, nil)];
}

#pragma mark - PublishedContractListOutputDelegate, LibraryOutputDelegate


-(void)didUnsubscribeFromContract:(Contract*) contract {
    
    [SLocator.contractManager removeContract:contract];
}

-(void)didUnsubscribeFromContractPretendentWithTxHash:(NSString*) hexTransaction {
    
    [SLocator.contractManager removeContractPretendentWithTxHash:hexTransaction];
}

-(void)didTrainingPass {
    [SLocator.appSettings changeIsRemovingContractTrainingPassed:YES];
}

-(void)didPressedBack {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)didSelectContractWithIndexPath:(NSIndexPath*) indexPath withContract:(Contract*) contract {
    [self showContractsFunction:contract];
}

#pragma mark - TemplatesListOutputDelegate


-(void)didSelectTemplateIndexPath:(NSIndexPath*) indexPath withName:(TemplateModel*) templateModel {
    
    self.templateModel = templateModel;
    [self showStepWithFieldsAndTemplate:templateModel.path];
}

#pragma mark - ConstructorAbiOutputDelegate

-(void)createStepOneNextDidPressedWithInputs:(NSArray<ResultTokenInputsModel*>*) inputs andContractName:(NSString*) contractName {
    
    self.localContractName = contractName;
    [self showFinishStepWithInputs:inputs];
}

#pragma mark - WatchContractOutputDelegate

- (void)didSelectChooseFromLibrary:(id)sender {
    [self showChooseFromLibrary:[sender isKindOfClass:[WatchTokensViewController class]]];
}

- (void)didChangeAbiText {
    self.activeTemplateForLibrary = nil;
    self.favouriteTokensCollectionSource.activeTemplate = self.activeTemplateForLibrary;
    self.favouriteContractsCollectionSource.activeTemplate = self.activeTemplateForLibrary;
}

#pragma mark - SmartContractMenuOutputDelegate

-(void)didSelectContractStore {
    [self showContractStore];
}

-(void)didSelectPublishedContracts {
    [self showMyPyblishedContract];
}

-(void)didSelectNewContracts {
    [self showCreateNewToken];
}

-(void)didSelectWatchContracts {
    [self showWatchContract];
}

-(void)didSelectWatchTokens {
    [self showWatchTokens];
}

- (void)didSelectRestoreContract {
    [self showRestoreContract];
}

- (void)didSelectBackupContract {
    [self showBackupContract];
}


#pragma mark - LibraryOutputDelegate, LibraryTableSourceOutputDelegate, FavouriteTemplatesCollectionSourceOutputDelegate, BackupContractOutputDelegate


- (void)didBackPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didSelectTemplate:(TemplateModel *)template sender:(id)sender {
    
    self.activeTemplateForLibrary = template;
    
    if ([sender isEqual:self.libraryTableSource]) {
        if (self.isLibraryViewControllerOnlyForTokens) {
            [self.wathTokensViewController changeStateForSelectedTemplate:template];
        } else {
            [self.wathContractsViewController changeStateForSelectedTemplate:template];
        }
        [self.navigationController popViewControllerAnimated:YES];
        
        self.favouriteTokensCollectionSource.activeTemplate = self.activeTemplateForLibrary;
        self.favouriteContractsCollectionSource.activeTemplate = self.activeTemplateForLibrary;
    }
    if ([sender isEqual:self.favouriteTokensCollectionSource]) {
        [self.wathTokensViewController changeStateForSelectedTemplate:template];
    }
    if ([sender isEqual:self.favouriteContractsCollectionSource]) {
        [self.wathContractsViewController changeStateForSelectedTemplate:template];
    }
}

- (void)didResetToDefaults:(id)sender {
    
    self.activeTemplateForLibrary = nil;

    if ([sender isEqual:self.libraryTableSource]) {
        if (self.isLibraryViewControllerOnlyForTokens) {
            [self.wathTokensViewController changeStateForSelectedTemplate:nil];
        } else {
            [self.wathContractsViewController changeStateForSelectedTemplate:nil];
        }
        
        self.favouriteTokensCollectionSource.activeTemplate = self.activeTemplateForLibrary;
        self.favouriteContractsCollectionSource.activeTemplate = self.activeTemplateForLibrary;
    }
    if ([sender isEqual:self.favouriteTokensCollectionSource]) {
        [self.wathTokensViewController changeStateForSelectedTemplate:nil];
    }
    if ([sender isEqual:self.favouriteContractsCollectionSource]) {
        [self.wathContractsViewController changeStateForSelectedTemplate:nil];
    }
}

@end
