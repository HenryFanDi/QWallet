//
//  DetailWebViewController.m
//  qtum wallet
//
//  Created by HenryFan on 28/8/2018.
//  Copyright © 2018 QTUM. All rights reserved.
//

#import "DetailWebViewController.h"
#import <WebKit/WebKit.h>

@interface DetailWebViewController () <WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *webViewBackgroundView;
@end

@implementation DetailWebViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.webViewBackgroundView addSubview:self.webView];
    [self setupConstraints];
    
    NSString *URLString;
    switch (self.type) {
        case DetailTypeFile:
            self.titleLabel.text = @"File";
            URLString = [NSString stringWithFormat:@"https://ipfs.io/ipfs/%@", self.model.fileHash];
            break;
        case DetailTypeTxID:
            self.titleLabel.text = @"Transaction ID";
            URLString = [NSString stringWithFormat:@"https://testnet.qtum.org/tx/%@", self.model.txID];
            break;
    }
    
    NSURL *URL = [NSURL URLWithString:URLString];
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:URL];
    [self.webView loadRequest:URLRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private Methods

- (void)setupConstraints {
    NSDictionary *views = @{@"webView" : self.webView};
    NSString *format = @"H:|-0-[webView]-0-|";
    [self.webViewBackgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views]];
    
    format = @"V:|-0-[webView]-0-|";
    [self.webViewBackgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views]];
}

#pragma mark - IBAction

- (IBAction)backButtonDidPress:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Accessors

- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        _webView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _webView;
}

@end
