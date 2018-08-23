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

#import "FileModel.h"

@interface MainCoordinator () <MainOutputDelegate, DetailOutputDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, weak) NSObject <MainOutput> *mainViewController;

@property (nonatomic, strong) MainTableSource *delegateDataSource;
    
@end

@implementation MainCoordinator

#pragma mark - Lifecycle

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController {
    self = [super init];
    if (self) {
        _navigationController = navigationController;
        [self setup];
    }
    return self;
}

- (void)start {
    NSObject <MainOutput> *controller = [SLocator.controllersFactory createMainViewController];
    controller.delegate = self;
    
    self.delegateDataSource = [SLocator.tableSourcesFactory mainWalletSource];
    self.delegateDataSource.delegate = self;
    controller.tableSource = self.delegateDataSource;
    self.mainViewController = controller;
    
    [self.navigationController setViewControllers:@[[controller toPresent]]];
}

#pragma mark - Private Methods

- (void)setup {
    self.navigationController.navigationBar.hidden = YES;
}

#pragma mark - MainCoordinatorDelegate

- (void)didSelectFileItem:(id)item {
    NSObject <DetailOutput> *controller = [SLocator.controllersFactory createDetailViewController];
    controller.delegate = self;
    [self.navigationController pushViewController:[controller toPresent] animated:YES];
}

#pragma mark - MainOutputDelegate

- (void)didReloadTableViewData {
    
}

- (void)didRefreshTableViewBalanceLocal:(BOOL)isLocal {
    
}

- (void)didUploadFile {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Upload file" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
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
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // TODO: To VM
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyyMMddHHmmss";
    NSDate *currentDate = [NSDate date];
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg", [dateFormatter stringFromDate:currentDate]];
    MainRequestManager *requestManager = [MainRequestManager new];
    [requestManager uploadFile:imageData name:imageName fileName:imageName mimeType:@"image/jpg" success:^(NSDictionary * uploadResponseObject) {
        if ((uploadResponseObject).count == 0) {
            return;
        }
        NSString *fileHash = uploadResponseObject[@"Hash"];
        if (!fileHash) {
            return;
        }
        [requestManager registerFile:fileHash success:^(NSDictionary * registerResponseObject) {
            NSLog(@"Register success : %@", registerResponseObject);
            FileModel *model = [[FileModel alloc] initWithUploadResponseObject:uploadResponseObject registerResponseObject:registerResponseObject];
            NSLog(@"model : %@", model);
        } failure:^(NSError *error) {
            NSLog(@"Register failure : %@", [error localizedDescription]);
        }];
    } failure:^(NSError *error) {
        NSLog(@"Upload failure : %@", [error localizedDescription]);
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - DetailOutputDelegate

@end
