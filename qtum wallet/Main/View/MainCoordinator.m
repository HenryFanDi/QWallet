//
//  MainCoordinator.m
//  qtum wallet
//
//  Created by HenryFan on 10/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import "MainCoordinator.h"
#import "MainOutput.h"
#import "DetailOutput.h"
#import "MainTableSource.h"
#import "MainRequestManager.h"
#import "MainViewControllerViewModel.h"
#import "DetailViewControllerViewModel.h"

#import "FileModel.h"
#import "FileManager.h"
#import "ConfirmPopUpViewController.h"

@interface MainCoordinator () <MainOutputDelegate, DetailOutputDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, weak) NSObject <MainOutput> *mainViewController;

@property (nonatomic, strong) dispatch_queue_t mainQueue;
@property (nonatomic, strong) MainTableSource *delegateDataSource;
    
@end

@implementation MainCoordinator

#pragma mark - Lifecycle

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController {
    self = [super init];
    if (self) {
        _navigationController = navigationController;
        _mainQueue = dispatch_queue_create("org.qtum.mainQueue", DISPATCH_QUEUE_SERIAL);
        [self setup];
    }
    return self;
}

- (void)start {
    NSObject <MainOutput> *controller = [SLocator.controllersFactory createMainViewController];
    controller.delegate = self;
    
    MainViewControllerViewModel *viewModel = [[MainViewControllerViewModel alloc] initWithViewController:(MainViewController *)controller];
    controller.viewModel = viewModel;
    
    self.delegateDataSource = [SLocator.tableSourcesFactory mainSource];
    self.delegateDataSource.delegate = self;
    
    controller.tableSource = self.delegateDataSource;
    self.mainViewController = controller;
    
    [self.navigationController setViewControllers:@[[controller toPresent]]];
    [self.mainViewController updateWallet];
}

#pragma mark - Private Methods

- (void)setup {
    self.navigationController.navigationBar.hidden = YES;
}

#pragma mark - MainCoordinatorDelegate

- (void)refreshTableViewData {
}

- (void)didSelectFileItem:(id)item {
    NSObject <DetailOutput> *controller = [SLocator.controllersFactory createDetailViewController];
    controller.delegate = self;
    
    DetailViewControllerViewModel *viewModel = [[DetailViewControllerViewModel alloc] initWithModel:item];
    controller.viewModel = viewModel;
    [self.navigationController pushViewController:[controller toPresent] animated:YES];
}

#pragma mark - MainOutputDelegate

- (void)didRefreshTableViewBalanceLocal:(BOOL)isLocal {
}

- (void)didUploadFile {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Share file" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:@"Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self openLibrary];
    }];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self openCamera];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    
    [alertController addAction:libraryAction];
    [alertController addAction:cameraAction];
    [alertController addAction:cancelAction];
    [(UIViewController *)self.mainViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)openLibrary {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [UIImagePickerController new];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = YES;
        picker.delegate = self;
        [(UIViewController *)self.mainViewController presentViewController:picker animated:YES completion:nil];
    }
}

- (void)openCamera {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [UIImagePickerController new];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = YES;
        picker.delegate = self;
        [(UIViewController *)self.mainViewController presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Share file" message:@"How would you like to share your file?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *freeAction = [UIAlertAction actionWithTitle:@"Share for free" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [picker dismissViewControllerAnimated:YES completion:^{
            [self uploadAndRegisterFileWithImage:info[UIImagePickerControllerOriginalImage]];
        }];
    }];
    
    UIAlertAction *licenseAction = [UIAlertAction actionWithTitle:@"Share for License" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [picker dismissViewControllerAnimated:YES completion:^{
            [self uploadAndRegisterFileWithImage:info[UIImagePickerControllerOriginalImage]];
        }];
    }];
    
    [alertController addAction:freeAction];
    [alertController addAction:licenseAction];
    [picker presentViewController:alertController animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Methods

- (void)uploadAndRegisterFileWithImage:(UIImage *)image {
    NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyyMMddHHmmss";
    NSDate *currentDate = [NSDate date];
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg", [dateFormatter stringFromDate:currentDate]];
    
    MainRequestManager *requestManager = [MainRequestManager new];
    
    __weak typeof(self) weakSelf = self;
    
    // Upload file
    [self.mainViewController startLoading];
    dispatch_async(self.mainQueue, ^{
        [requestManager uploadFile:imageData name:imageName fileName:imageName mimeType:@"image/jpg" success:^(NSDictionary * uploadResponseObject) {
            __strong typeof(weakSelf) self = weakSelf;
            if ((uploadResponseObject).count == 0) {
                return;
            }
            NSString *fileHash = uploadResponseObject[@"Hash"];
            if (!fileHash) {
                return;
            }
            // Register file
            [requestManager registerFile:fileHash success:^(NSDictionary *registerResponseObject) {
                [self.mainViewController stopLoading];
                FileModel *file = [[FileModel alloc] initWithUploadResponseObject:uploadResponseObject registerResponseObject:registerResponseObject object:image];
                [SLocator.fileManager addNewFile:file];
                [self.mainViewController updateWallet];
            } failure:^(NSError *error) {
                __strong typeof(weakSelf) self = weakSelf;
                [self.mainViewController stopLoading];
                NSLog(@"Register failure : %@", [error localizedDescription]);
            }];
        } failure:^(NSError *error) {
            __strong typeof(weakSelf) self = weakSelf;
            [self.mainViewController stopLoading];
            NSLog(@"Upload failure : %@", [error localizedDescription]);
        }];
    });
}

#pragma mark - DetailOutputDelegate

@end
