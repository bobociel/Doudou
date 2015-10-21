//
//  PolicyViewController.m
//  nihao
//
//  Created by HelloWorld on 8/26/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "PolicyViewController.h"
#import "ListingLoadingStatusView.h"

@interface PolicyViewController () <UIWebViewDelegate> {
	ListingLoadingStatusView *_statusView;
}

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation PolicyViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.title = @"Service Terms";
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

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.webView.frame = self.view.bounds;
}

#pragma mark Lifecycle

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
	
	NSURL *url = [NSURL URLWithString:@"http://www.appnihao.com/policy.html"];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
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
