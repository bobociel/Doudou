//
//  WTWebViewViewController.m
//  weddingTime
//
//  Created by wangxiaobo on 16/3/10.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTWebViewViewController.h"
#define kNabvBarHeight 64.0
@interface WTWebViewViewController () <UIWebViewDelegate>
@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) NSURL *webURL;
@end

@implementation WTWebViewViewController

+ (instancetype)instanceViewControllerWithURL:(NSURL *)url
{
	WTWebViewViewController *webVC = [[WTWebViewViewController alloc] init];
	webVC.webURL = url;
	return webVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - kNabvBarHeight)];
	self.webView.delegate = self;
	[self.view addSubview:self.webView];

	if(self.webURL){
		[self.webView loadRequest:[NSURLRequest requestWithURL:self.webURL]];
	}
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[self showLoadingViewTitle:@"加载中..."];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[self hideLoadingView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[WTProgressHUD showLoadingHUDWithTitle:@"加载失败" showInView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
