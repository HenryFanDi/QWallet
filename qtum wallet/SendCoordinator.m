//
//  SendCoordinator.m
//  qtum wallet
//
//  Created by Vladimir Lebedevich on 04.07.17.
//  Copyright © 2017 QTUM. All rights reserved.
//

#import "SendCoordinator.h"
#import "PaymentValuesManager.h"
#import "NewPaymentDarkViewController.h"
#import "QRCodeViewController.h"
#import "ChoseTokenPaymentViewController.h"
#import "ChooseTokekPaymentDelegateDataSourceDelegate.h"


@interface SendCoordinator () <NewPaymentOutputDelegate, QRCodeViewControllerDelegate, ChoseTokenPaymentOutputDelegate, ChooseTokekPaymentDelegateDataSourceDelegate, PopUpWithTwoButtonsViewControllerDelegate>

@property (strong, nonatomic) UINavigationController *navigationController;
@property (weak, nonatomic) NSObject <NewPaymentOutput> *paymentOutput;
@property (weak, nonatomic) QRCodeViewController *qrCodeOutput;
@property (weak, nonatomic) NSObject <ChoseTokenPaymentOutput> *tokenPaymentOutput;
@property (strong, nonatomic) Contract *token;

@property (strong, nonatomic) NSString *fromAddressString;
@property (strong, nonatomic) BTCKey *fromAddressKey;

@end

@implementation SendCoordinator

- (instancetype)initWithNavigationController:(UINavigationController *) navigationController {

	self = [super init];
	if (self) {
		_navigationController = navigationController;
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)start {

	NSObject <NewPaymentOutput> *controller = [SLocator.controllersFactory createNewPaymentDarkViewController];
	controller.delegate = self;
	self.paymentOutput = controller;
	[self.navigationController setViewControllers:@[[controller toPresent]]];

	[self.paymentOutput showLoaderPopUp];

	__weak __typeof (self) weakSelf = self;
	[SLocator.transactionManager getFeePerKbWithHandler:^(QTUMBigNumber *feePerKb) {

		QTUMBigNumber *minFee = feePerKb;
		QTUMBigNumber *maxFee = [PaymentValuesManager sharedInstance].maxFee;

		[weakSelf.paymentOutput setMinFee:minFee andMaxFee:maxFee];
		[weakSelf.paymentOutput setMinGasPrice:[PaymentValuesManager sharedInstance].minGasPrice andMax:[PaymentValuesManager sharedInstance].maxGasPrice step:GasPriceStep];
		[weakSelf.paymentOutput setMinGasLimit:[PaymentValuesManager sharedInstance].minGasLimit andMax:[PaymentValuesManager sharedInstance].maxGasLimit standart:[PaymentValuesManager sharedInstance].standartGasLimit step:GasLimitStep];
		[weakSelf.paymentOutput hideLoaderPopUp];
	}];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (tokensDidChange) name:kTokenDidChange object:nil];
}

- (void)setForSendSendInfoItem:(SendInfoItem *) item {

	switch (item.type) {
		case SendInfoItemTypeQtum:
			self.token = nil;
			break;
		case SendInfoItemTypeInvalid:
			[[PopUpsManager sharedInstance] showErrorPopUp:self withContent:[PopUpContentGenerator contentForInvalidQRCodeFormatPopUp] presenter:nil completion:nil];
			item = nil;
			self.token = nil;
			break;
		case SendInfoItemTypeToken: {
			NSArray <Contract *> *tokens = [ContractManager sharedInstance].allActiveTokens;

			BOOL exist = NO;
			for (Contract *token in tokens) {
				if ([token.contractAddress isEqualToString:item.tokenAddress]) {
					self.token = token;
					exist = YES;
					break;
				}
			}

			if (!exist) {
				[[PopUpsManager sharedInstance] showErrorPopUp:self withContent:[PopUpContentGenerator contentForRequestTokenPopUp] presenter:nil completion:nil];
				[self.paymentOutput setSendInfoItem:nil];
				self.token = nil;
				item = nil;
			}
			break;
		}
	}

	[self.paymentOutput updateContentWithContract:self.token];
	[self.paymentOutput setSendInfoItem:item];

	self.fromAddressKey = item.fromQtumAddressKey;
	self.fromAddressString = item.fromQtumAddress;

	//bail if we have open 2 qrcode scaners
	if (self.qrCodeOutput) {
		[self.navigationController popViewControllerAnimated:YES];
	}
	[self updateOutputs];
}

- (void)setForToken:(Contract *) aToken withAddress:(NSString *) address andAmount:(NSString *) amount {

	SendInfoItem *item = [[SendInfoItem alloc] initWithQtumAddress:address tokenAddress:aToken.contractAddress amountString:amount];
	[self setForSendSendInfoItem:item];
}

- (void)didSelectedFromTabbar {

}

#pragma mark - Observing

- (void)tokensDidChange {

	[self updateOutputs];
}

#pragma mark - Private Methods

- (void)updateOutputs {

	__weak __typeof (self) weakSelf = self;

	dispatch_async (dispatch_get_main_queue (), ^{

		NSArray <Contract *> *tokens = [ContractManager sharedInstance].allActiveTokens;
		BOOL tokenExists = NO;

		if (weakSelf.tokenPaymentOutput) {
			[weakSelf.tokenPaymentOutput updateWithTokens:tokens];
		}

		if (self.token && [tokens containsObject:self.token]) {
			tokenExists = YES;
		} else {
			self.token = nil;
		}

		[weakSelf.paymentOutput updateControlsWithTokensExist:tokens.count choosenTokenExist:tokenExists walletBalance:SLocator.walletManager.wallet.balance andUnconfimrmedBalance:SLocator.walletManager.wallet.unconfirmedBalance];
	});
}

- (void)payWithWalletWithAddress:(NSString *) address andAmount:(QTUMBigNumber *) amount andFee:(QTUMBigNumber *) fee {

	if (![self isValidAmount:amount]) {
		return;
	}

	NSArray *array = @[@{@"amount": amount, @"address": address}];

	[self showLoaderPopUp];

	__weak typeof (self) weakSelf = self;
	NSArray<BTCKey *> *addresses = self.fromAddressKey ? @[self.fromAddressKey] : [SLocator.walletManager.wallet allKeys];
	[SLocator.transactionManager sendTransactionWalletKeys:addresses
										toAddressAndAmount:array
													   fee:fee
												andHandler:^(TransactionManagerErrorType errorType,
														id response,
														QTUMBigNumber *estimateFee) {

													[weakSelf hideLoaderPopUp];
													if (errorType == TransactionManagerErrorTypeNotEnoughFee) {
														[self showNotEnoughFeeAlertWithEstimatedFee:estimateFee];
													} else if (errorType == TransactionManagerErrorTypeNotEnoughGasLimit) {
														[weakSelf showStatusOfPayment:errorType withEstimateGasLimit:estimateFee];
													} else {
														[weakSelf showStatusOfPayment:errorType];
													}
												}];
}

- (void)payWithTokenWithAddress:(NSString *) address andAmount:(QTUMBigNumber *) amount fee:(QTUMBigNumber *) fee gasPrice:(QTUMBigNumber *) gasPrice gasLimit:(QTUMBigNumber *) gasLimit {

	QTUMBigNumber *amounDivByDecimals = [amount numberWithPowerOf10:self.token.decimals];

	if (![self isValidAmount:amounDivByDecimals]) {
		return;
	}

	[self showLoaderPopUp];
	__weak typeof (self) weakSelf = self;

	if (self.fromAddressString) {
		[SLocator.transactionManager sendToken:self.token
								   fromAddress:self.fromAddressString
									 toAddress:address
										amount:amounDivByDecimals
										   fee:fee
									  gasPrice:gasPrice
									  gasLimit:gasLimit
									andHandler:^(TransactionManagerErrorType errorType,
											BTCTransaction *transaction,
											NSString *hashTransaction,
											QTUMBigNumber *estimatedFee) {

										[weakSelf hideLoaderPopUp];
										if (errorType == TransactionManagerErrorTypeNotEnoughFee) {
											[weakSelf showNotEnoughFeeAlertWithEstimatedFee:estimatedFee];
										} else {
											[weakSelf showStatusOfPayment:errorType];
										}
									}];
	} else {
		[SLocator.transactionManager sendTransactionToToken:self.token
												  toAddress:address
													 amount:amounDivByDecimals
														fee:fee
												   gasPrice:gasPrice
												   gasLimit:gasLimit
												 andHandler:^(TransactionManagerErrorType errorType,
														 BTCTransaction *transaction, NSString *hashTransaction,
														 QTUMBigNumber *estimateFee) {

													 [weakSelf hideLoaderPopUp];
													 if (errorType == TransactionManagerErrorTypeNotEnoughFee) {
														 [weakSelf showNotEnoughFeeAlertWithEstimatedFee:estimateFee];
													 } else {
														 [weakSelf showStatusOfPayment:errorType];
													 }
												 }];
	}
}

- (void)showStatusOfPayment:(TransactionManagerErrorType) errorType {

	switch (errorType) {
		case TransactionManagerErrorTypeNone:
			[self showCompletedPopUp];
			break;
		case TransactionManagerErrorTypeNoInternetConnection:
			break;
		case TransactionManagerErrorTypeNotEnoughMoney:
			[self showErrorPopUp:NSLocalizedString(@"You have insufficient funds for this transaction", nil)];
			break;
		case TransactionManagerErrorTypeInvalidAddress:
			[self showErrorPopUp:NSLocalizedString(@"Invalid QTUM Address", nil)];
			break;
		case TransactionManagerErrorTypeNotEnoughMoneyOnAddress:
			[self showErrorPopUp:NSLocalizedString(@"You have insufficient funds for this transaction at this address", nil)];
			break;
		default:
			[self showErrorPopUp:nil];
			break;
	}
}

- (void)showNotEnoughFeeAlertWithEstimatedFee:(QTUMBigNumber *) estimatedFee {

	NSString *errorString = [NSString stringWithFormat:@"Insufficient fee. Please use minimum of %@ QTUM", estimatedFee.stringValue];
	[self showErrorPopUp:NSLocalizedString(errorString, nil)];
}

- (void)showStatusOfPayment:(TransactionManagerErrorType) errorType withEstimateGasLimit:(QTUMBigNumber *) gasLimit {

	NSString *errorString = [NSString stringWithFormat:@"Insufficient gas limit. Please use minimum of %@ QTUM", gasLimit.stringValue];
	[self showErrorPopUp:NSLocalizedString(errorString, nil)];
}

- (BOOL)isValidAmount:(QTUMBigNumber *) amount {

	if (![amount isGreaterThanInt:0]) {
		[self showErrorPopUp:NSLocalizedString(@"Transaction amount can't be zero. Please edit your transaction and try again", nil)];
		return NO;
	}

	return YES;
}

#pragma mark - Popup

- (void)hideLoaderPopUp {
	[self.paymentOutput hideLoaderPopUp];
}

- (void)showErrorPopUp:(NSString *) message {
	[self.paymentOutput showErrorPopUp:message];
}

- (void)showCompletedPopUp {
	[self.paymentOutput showCompletedPopUp];
}

- (void)showLoaderPopUp {
	[self.paymentOutput showLoaderPopUp];
}

#pragma mark - NewPaymentViewControllerDelegate

- (void)didViewLoad {

	[self updateOutputs];
}

- (void)didPresseQRCodeScaner {

	QRCodeViewController *controller = (QRCodeViewController *)[SLocator.controllersFactory createQRCodeViewControllerForSend];
	controller.delegate = self;
	self.qrCodeOutput = controller;
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)didPresseChooseToken {

	NSObject <ChoseTokenPaymentOutput> *tokenController = (NSObject <ChoseTokenPaymentOutput> *)[SLocator.controllersFactory createChoseTokenPaymentViewController];
	tokenController.delegate = self;
	tokenController.delegateDataSource = [[TableSourcesFactory sharedInstance] createSendTokenPaymentSource];
	tokenController.delegateDataSource.activeToken = self.token;
	tokenController.delegateDataSource.delegate = self;
	[tokenController updateWithTokens:[ContractManager sharedInstance].allActiveTokens];
	self.tokenPaymentOutput = tokenController;
	[self.navigationController pushViewController:[tokenController toPresent] animated:YES];
}

- (void)didPresseSendActionWithAddress:(NSString *) address andAmount:(QTUMBigNumber *) amount fee:(QTUMBigNumber *) fee gasPrice:(QTUMBigNumber *) gasPrice gasLimit:(QTUMBigNumber *) gasLimit {

	__weak __typeof (self) weakSelf = self;
	[[ApplicationCoordinator sharedInstance] startSecurityFlowWithType:SendVerification WithHandler:^(BOOL success) {
		if (success) {
			[weakSelf payActionWithAddress:address andAmount:amount fee:fee gasPrice:gasPrice gasLimit:gasLimit];
		}
	}];
}

- (void)payActionWithAddress:(NSString *) address andAmount:(QTUMBigNumber *) amount fee:(QTUMBigNumber *) fee gasPrice:(QTUMBigNumber *) gasPrice gasLimit:(QTUMBigNumber *) gasLimit {

	if (self.token) {
		[self payWithTokenWithAddress:address andAmount:amount fee:fee gasPrice:gasPrice gasLimit:gasLimit];
	} else {
		[self payWithWalletWithAddress:address andAmount:amount andFee:fee];
	}
}

- (BOOL)needCheckForChanges {
	return self.fromAddressKey != nil || self.fromAddressString != nil;
}

- (void)changeToStandartOperation {
	self.fromAddressKey = nil;
	self.fromAddressString = nil;
}

#pragma mark - QRCodeViewControllerDelegate

- (void)didQRCodeScannedWithSendInfoItem:(SendInfoItem *) item {

	[self.navigationController popViewControllerAnimated:YES];

	[self setForSendSendInfoItem:item];
}

- (void)didBackPressed {

	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - PopUpWithTwoButtonsViewControllerDelegate

- (void)okButtonPressed:(PopUpViewController *) sender {
	[[PopUpsManager sharedInstance] hideCurrentPopUp:YES completion:nil];
}

- (void)cancelButtonPressed:(PopUpViewController *) sender {
	[[PopUpsManager sharedInstance] hideCurrentPopUp:YES completion:nil];
	[self didPresseQRCodeScaner];
}

#pragma mark - ChoseTokenPaymentViewControllerDelegate

- (void)didPressedBackAction {

	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ChoseTokenPaymentOutputDelegate

- (void)didSelectTokenIndexPath:(NSIndexPath *) indexPath withItem:(Contract *) item {

	self.token = item;
	[self.navigationController popViewControllerAnimated:YES];
	[self.paymentOutput updateContentWithContract:item];
}

- (void)didResetToDefaults {

	[self.paymentOutput updateContentWithContract:nil];
	self.token = nil;
}

@end
