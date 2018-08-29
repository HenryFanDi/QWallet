//
//  DetailViewController.m
//  qtum wallet
//
//  Created by HenryFan on 21/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import "DetailViewController.h"
#import "DetailWebViewController.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *fileImageView;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *tokenLabel;
@property (weak, nonatomic) IBOutlet UILabel *txLabel;
@end

@implementation DetailViewController

#pragma mark - Lifecycle

- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupLayout];
    [self bindViewModel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private Methods

- (void)setupLayout {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fileViewDidTap)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    self.fileImageView.userInteractionEnabled = YES;
    [self.fileImageView addGestureRecognizer:tapGestureRecognizer];
    
    self.fileImageView.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    self.fileImageView.layer.shadowRadius = 2.0f;
    self.fileImageView.layer.shadowOpacity = 0.5f;
}

- (void)bindViewModel {
    self.titleLabel.text = self.viewModel.titleLabelString;
    self.fileImageView.image = self.viewModel.fileImage;
    self.sizeLabel.text = self.viewModel.sizeLabelString;
    self.tokenLabel.text = self.viewModel.tokenLabelString;
    self.txLabel.text = self.viewModel.txLabelString;
}

#pragma mark - UITapGestureRecognizer

- (void)fileViewDidTap {
    NSObject <DetailWebOutput> *controller = [SLocator.controllersFactory createDetailWebViewController];
    ((DetailWebViewController *)controller).type = DetailTypeFile;
    ((DetailWebViewController *)controller).model = self.viewModel.model;
    [self.navigationController pushViewController:[controller toPresent] animated:YES];
}

#pragma mark - IBAction

- (IBAction)backButtonDidPress:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)txWebButtonDidPress:(id)sender {
    NSObject <DetailWebOutput> *controller = [SLocator.controllersFactory createDetailWebViewController];
    ((DetailWebViewController *)controller).type = DetailTypeTxID;
    ((DetailWebViewController *)controller).model = self.viewModel.model;
    [self.navigationController pushViewController:[controller toPresent] animated:YES];
}

@end
