//
//  NewsViewController.m
//  nihao
//
//  Created by 刘志 on 15/6/25.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "NewsViewController.h"
#import "News.h"
#import "ListingLoadingStatusView.h"
#import "FXBlurView.h"
#import "HttpManager.h"
#import <pop/POP.h>
#import "AppConfigure.h"
#import "HttpManager.h"
#import "NewsCommentListViewController.h"

@interface NewsViewController () <UIWebViewDelegate>{
    ListingLoadingStatusView *_statusView;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet FXBlurView *blurView;
- (IBAction)addOrCancelLike:(id)sender;
- (IBAction)addComment:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *likeImage;
@property (weak, nonatomic) IBOutlet UILabel *likeNum;
@property (weak, nonatomic) IBOutlet UILabel *commentNum;

@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"News";
    [self dontShowBackButtonTitle];
    [self initBlurView];
    [self initViews];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	self.hidesBottomBarWhenPushed = YES;
	if (_news) {
		_commentNum.text = [NSString stringWithFormat:@"%d", _news.ni_sum_cmi_count];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 初始化控件
- (void) initBlurView {
    [_blurView setTintColor:[UIColor grayColor]];
    _blurView.dynamic = YES;
    _blurView.blurRadius = 40;
}

- (void) initViews {
    _statusView = [[ListingLoadingStatusView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    [self.view addSubview:_statusView];
    __weak NewsViewController *weakSelf = self;
    _statusView.refresh = ^ {
        [weakSelf loadUrl];
    };
    _webView.delegate = self;
    _webView.scrollView.showsVerticalScrollIndicator = NO;
    _webView.scrollView.showsHorizontalScrollIndicator = NO;
    _webView.userInteractionEnabled = YES;
    [_webView setScalesPageToFit:YES];
    [self loadUrl];
    
    if(_news.pii_is_praise == 0) {
        _likeImage.image = [UIImage imageNamed:@"common_icon_like"];
        _likeNum.textColor = ColorWithRGB(150, 150, 150);
    } else {
        _likeImage.image = [UIImage imageNamed:@"common_icon_liked"];
        _likeNum.textColor = ColorWithRGB(80, 183, 249);
    }
    
    _likeNum.text = [NSString stringWithFormat:@"%d",_news.ni_sum_pii_count];
    _commentNum.text = [NSString stringWithFormat:@"%d",_news.ni_sum_cmi_count];
    
    UIView *topSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
    topSeperator.backgroundColor = SeparatorColor;
    [_blurView addSubview:topSeperator];
    
    UIView *middleSeperator = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2, 0, 0.5, CGRectGetHeight(_blurView.frame))];
    middleSeperator.backgroundColor = SeparatorColor;
    [_blurView addSubview:middleSeperator];
}

#pragma mark - load url
- (void) loadUrl {
    [_statusView showWithStatus:Loading];
    NSString *urlStr = [NSString stringWithFormat:NEWS_URL,_news.ni_id];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:0 timeoutInterval:30 * 1000];
    NSString *sign = [HttpManager signParams:@{@"ni_id":[NSString stringWithFormat:@"%d",_news.ni_id]}];
    NSString *ci_id = [NSString stringWithFormat:@"%ld",[AppConfigure integerForKey:LOGINED_USER_ID]];
    [request setValue:ci_id forHTTPHeaderField:@"ci_id"];
    [request setValue:sign forHTTPHeaderField:@"sign"];
    [_webView loadRequest:request];
}

#pragma mark - uiwebview delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_statusView showWithStatus:Done];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    //显示网络异常
    [_statusView showWithStatus:NetErr];
}

- (IBAction)addOrCancelLike:(id)sender {
    NSInteger distance = 8;
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    anim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, CGRectGetWidth(_likeImage.frame) + distance, CGRectGetHeight(_likeImage.frame) + distance)];
    anim.springBounciness = 20;
    anim.completionBlock = ^(POPAnimation *anim,BOOL finished) {
        if(finished) {
            POPSpringAnimation *animSmaller = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
            animSmaller.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, CGRectGetWidth(_likeImage.frame) - distance, CGRectGetHeight(_likeImage.frame) - distance)];
            animSmaller.springBounciness = 20;
            animSmaller.removedOnCompletion = YES;
            [_likeImage.layer pop_addAnimation:animSmaller forKey:@"size_smaller"];
            
            NSString *uid = [AppConfigure objectForKey:LOGINED_USER_ID];
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:uid forKey:@"pii_ci_id"];
            [params setObject:[NSString stringWithFormat:@"%d",_news.ni_id] forKey:@"pii_source_id"];
            [params setObject:@"2" forKey:@"pii_source_type"];
            //点赞或取消点赞
            if(_news.pii_is_praise == 0) {
				[HttpManager userPraiseByParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
					
				} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
					
				}];
                _news.ni_sum_pii_count ++;
                _news.pii_is_praise = 1;
                _likeNum.textColor = ColorWithRGB(80, 183, 249);
            } else {
				[HttpManager userCancelPraiseByParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
					
				} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
					
				}];
                _news.ni_sum_pii_count --;
                _news.pii_is_praise = 0;
                _likeNum.textColor = ColorWithRGB(150, 150, 150);
            }
            self.like(_news);
            _likeNum.text = [NSString stringWithFormat:@"%d",_news.ni_sum_pii_count];
        }
    };
    anim.removedOnCompletion = YES;
    [_likeImage.layer pop_addAnimation:anim forKey:@"size_bigger"];
    NSString *likeImageName = (_news.pii_is_praise == 0) ? @"common_icon_liked" : @"common_icon_like";
    _likeImage.image = [UIImage imageNamed:likeImageName];
}

- (IBAction)addComment:(id)sender {
	NewsCommentListViewController *newsCommentListViewController = [[NewsCommentListViewController alloc] init];
	newsCommentListViewController.news = _news;
	[self.navigationController pushViewController:newsCommentListViewController animated:YES];
}

@end
