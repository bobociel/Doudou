//
//  MerchantDiscountViewController.m
//  nihao
//
//  Created by HelloWorld on 8/14/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "MerchantDiscountViewController.h"
#import "ListingLoadingStatusView.h"
#import "HttpManager.h"
#import "AppConfigure.h"

@interface MerchantDiscountViewController () <UIWebViewDelegate> {
	ListingLoadingStatusView *_statusView;
}

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation MerchantDiscountViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.title = @"Merchant discount";
	self.view.backgroundColor = [UIColor whiteColor];
	
	self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
	self.webView.delegate = self;
	self.webView.scrollView.showsVerticalScrollIndicator = NO;
	self.webView.scrollView.showsHorizontalScrollIndicator = NO;
	self.webView.userInteractionEnabled = YES;
	[self.webView setScalesPageToFit:YES];
	[self.view addSubview:self.webView];
	
	[self setUpLoadView];
	[self loadUrl];
}

#pragma mark - Lifecycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)setUpLoadView {
	_statusView = [[ListingLoadingStatusView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
	[self.view addSubview:_statusView];
	__weak typeof(self) weakSelf = self;
	_statusView.refresh = ^ {
		[weakSelf loadUrl];
	};
}

- (void)loadUrl {
	[_statusView showWithStatus:Loading];
	
	NSString *urlStr = [NSString stringWithFormat:MERCHANT_DISCOUNT_URL, self.merchantID];
	NSURL *url = [NSURL URLWithString:urlStr];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:0 timeoutInterval:30 * 1000];
	NSString *sign = [HttpManager signParams:@{@"mhi_id" : [NSString stringWithFormat:@"%ld", self.merchantID],
											   @"action" : @"pager"}];
	NSString *ci_id = [NSString stringWithFormat:@"%ld", [AppConfigure integerForKey:LOGINED_USER_ID]];
	[request setValue:ci_id forHTTPHeaderField:@"ci_id"];
	[request setValue:sign forHTTPHeaderField:@"sign"];
	[self.webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[_statusView showWithStatus:Done];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	//显示网络异常
	[_statusView showWithStatus:NetErr];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
