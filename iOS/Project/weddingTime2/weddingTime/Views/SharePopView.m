//
//  SharePopView.m
//  lovewith
//
//  Created by imqiuhang on 15/5/14.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//
#import <SDWebImage/SDWebImageDownloader.h>
#import <SDWebImage/SDImageCache.h>
#import "SharePopView.h"
#import "AlertViewWithBlockOrSEL.h"
#import "WTProgressHUD.h"

#define kMaxTitleLength 40
#define kMaxDescLength  100

#define SharePopViewTag 63746264

#define btnWidth 64
#define topGap 30

#define kThumb100 @"?imageView2/1/w/100/h/100"
#define kThumb600 @"?imageView2/1/w/600/h/600"

@interface SharePopView()
@end

@implementation SharePopView
{
	BOOL isSendBless;
    NSMutableArray *shareWayInfoArr;
    UIView *contentView;
    UIView *tapView ;
}

+ (instancetype)viewWithhareTypes:(NSArray *)shareTypes
{
	SharePopView *view = [[SharePopView alloc] init];
	[view initObjectWithShareTypes:shareTypes];
	[view initView];

	return view;
}

- (void)initObjectWithShareTypes:(NSArray *)shareTypes {
    shareWayInfoArr = [[NSMutableArray alloc] initWithCapacity:7];

	isSendBless = [shareTypes containsObject:@(WTShareTypeBless)];

    if([WXApi isWXAppInstalled] && [shareTypes containsObject:@(WTShareTypeWX)])
	{
        [shareWayInfoArr addObject:@{@"image" : @"shareIcon_wechatFriend",@"title" : @"朋友圈",@"SEL":@"shareWithWechatQuan"}];
        [shareWayInfoArr addObject:@{@"image" : @"shareIcon_wechat",@"title" : @"微信好友",@"SEL":@"shareWithWechatFriend"}];
    }

    if ([TencentOAuth iphoneQQInstalled] && [shareTypes containsObject:@(WTShareTypeQQ)])
	{
        [shareWayInfoArr addObject:@{ @"image" : @"shareIcon_qq", @"title" : @"QQ好友",@"SEL":@"shareWithQQ"}];
    }

	if([WeiboSDK isWeiboAppInstalled] && [shareTypes containsObject:@(WTShareTypeSina)])
	{
		[shareWayInfoArr addObject:@{ @"image":@"shareIcon_sina", @"title" : @"新浪微博",@"SEL":@"shareWithSinaWeibo"}];
	}

	if([shareTypes containsObject:@(WTShareTypeMessage)])
	{
		[shareWayInfoArr addObject:@{@"image":@"shareIcon_message",@"title":@"短信",@"SEL":@"shareWithMessage"}];
	}

	if([shareTypes containsObject:@(WTShareTypeCopy)])
	{
		[shareWayInfoArr addObject:@{@"image":@"shareIcon_copy",@"title":@"复制链接",@"SEL":@"shareWithCopy"}];
	}
}

- (void)initView {
    self.tag=SharePopViewTag;
    self.frame = CGRectMake(0, 0, screenWidth, screenHeight);

    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, (int)(shareWayInfoArr.count/5+1)*btnWidth +(int)(shareWayInfoArr.count/5+2)*topGap)];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.bottom = self.height;
    [self addSubview:contentView];

    for(int i=0; i < shareWayInfoArr.count; i++)
	{
        float gap = (screenWidth - 4*btnWidth) / 5.f;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((i%4+1)*gap+(i%4)*btnWidth, (int)(i/4+1)*topGap+(int)(i/4)*btnWidth, btnWidth, btnWidth)];
        [btn setImage:[UIImage imageNamed :shareWayInfoArr[i][@"image"]] forState:UIControlStateNormal];
        [btn addTarget:self action:NSSelectorFromString(shareWayInfoArr[i][@"SEL"]) forControlEvents:UIControlEventTouchUpInside];
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(btn.left, btn.bottom+5, btn.width, 20)];
        lable.font = DefaultFont12;
        lable.textColor = titleLableColor;
        lable.textAlignment = NSTextAlignmentCenter;
        lable.text = shareWayInfoArr[i][@"title"];
        
        [contentView addSubview:btn];
        [contentView addSubview:lable];
    }

	if(!isSendBless)
	{
		UIImageView *fourthLineView = [[UIImageView alloc] initWithFrame:CGRectMake(0,contentView.frame.size.height + 5 ,screenWidth, 0.5f)];
		fourthLineView.backgroundColor = rgba(230, 230, 230, 1);
		[contentView addSubview:fourthLineView];

		UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cancelButton.frame = CGRectMake(0,contentView.frame.size.height + 5, screenWidth, 40.0);
		[cancelButton setTitleColor:[WeddingTimeAppInfoManager instance].baseColor forState:UIControlStateNormal];
		[cancelButton setTitle:@"取消" forState:UIControlStateNormal];
		[contentView addSubview:cancelButton];
		[cancelButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];

		contentView.frame = CGRectMake(0, 0, screenWidth, contentView.frame.size.height + 50.0);
		contentView.bottom = self.height;
	}

	tapView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-contentView.height)];
	[self addSubview:tapView];
	tapView.backgroundColor = [UIColor blackColor];
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
	[tapView addGestureRecognizer:tap];
}

//根据URL获得图片
- (void)getShareImageWithURL:(NSString *)url callback:(SDWebImageDownloaderCompletedBlock)callback
{
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:url]
                                                          options:SDWebImageDownloaderLowPriority
                                                         progress:nil
                                                        completed:callback];
}


- (void)shareWithWechatQuan {
    [self shareWithWechat:WXSceneTimeline];
}
- (void)shareWithWechatFriend {
    [self shareWithWechat:WXSceneSession];
}

- (void)shareWithWechat:(enum WXScene)aScene
{
    WXMediaMessage *message = [WXMediaMessage message];
    WXWebpageObject *wpo = [WXWebpageObject object];
    wpo.webpageUrl = self.shareInfo.urlStr;
    [message setTitle:self.shareInfo.title];
    [message setDescription:self.shareInfo.sharedescription];
    
    [self getShareImageWithURL:[_shareInfo.imageURL stringByAppendingString:kThumb100]
                      callback:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        [message setThumbImage:image];
        [message setMediaObject:wpo];
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = aScene;
        [WXApi sendReq:req];
    }];

	if(!isSendBless) { [self hide]; }
}

- (void)shareWithQQ {
	
    TencentOAuth* tencentOAuth = [[TencentOAuth alloc] initWithAppId:QQAppId andDelegate:nil];
    if (tencentOAuth) { }

    QQApiNewsObject *newsObj;
    newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:self.shareInfo.urlStr]
									   title:self.shareInfo.title
								 description:self.shareInfo.sharedescription
                             previewImageURL:[NSURL URLWithString:[_shareInfo.imageURL stringByAppendingString:kThumb100]] ];

	SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    [QQApiInterface sendReq:req];

	if(!isSendBless) { [self hide]; }
}

- (void)shareWithSinaWeibo
{
	WBAuthorizeRequest *request = [WBAuthorizeRequest request];
	request.redirectURI = @"http://www.lovewith.me";
	request.scope = @"all";

	WBMessageObject *message = [WBMessageObject message];
	WBImageObject *imageObject = [WBImageObject object];
	message.text = [NSString stringWithFormat:@"%@  %@%@ @婚礼时光",_shareInfo.title,_shareInfo.sharedescription,_shareInfo.urlStr];
    [self getShareImageWithURL:[_shareInfo.imageURL stringByAppendingString:kThumb600]
                      callback:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        imageObject.imageData = UIImageJPEGRepresentation(image, 1.0);
        message.imageObject = imageObject;
        WBSendMessageToWeiboRequest *messageRequest = [WBSendMessageToWeiboRequest requestWithMessage:message];
        [WeiboSDK sendRequest:messageRequest];
    }];

	if(!isSendBless) { [self hide]; }
}

- (void)shareWithCopy
{
	[UIPasteboard generalPasteboard].string = self.shareInfo.urlStr;
	[WTProgressHUD ShowTextHUD:@"链接复制成功" showInView:KEY_WINDOW afterDelay:1.0];
	if(!isSendBless) { [self hide]; }
}

- (void)shareWithMessage {

    if( [MFMessageComposeViewController canSendText] )
	{
        UINavigationController *nav = (UINavigationController *)KEY_WINDOW.rootViewController;
        UIViewController *showVC = nav.topViewController;
        AlertViewWithBlockOrSEL *alertView = [[AlertViewWithBlockOrSEL alloc]
                                              initWithTitle:@"短信发送"
                                              message:@"将使用短信分享内容,发送短信资费由运营商决定。我们不会记录您的任何通讯信息。"];
		alertView.delegate = self;
        [alertView addOtherButtonWithTitle:@"确定" onTapped:^{
             MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init];
             controller.body = [NSString stringWithFormat:@"%@\n%@\n链接:%@",self.shareInfo.title,self.shareInfo.sharedescription,self.shareInfo.urlStr];
             controller.messageComposeDelegate =self;
             [showVC presentViewController:controller animated:YES completion:nil];
		}];
        [alertView setCancelButtonWithTitle:@"取消" onTapped:nil];
        [alertView show];
  
    }
	else
	{
        [WTProgressHUD ShowTextHUD:@"设备不支持发送短信" showInView:self];
    }

	if(!isSendBless) { [self hide]; }
}

#pragma mark - Delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
    switch (result) {
        case MessageComposeResultSent:
           [WTProgressHUD ShowTextHUD:@"邀请成功" showInView:self]; break;
        case MessageComposeResultFailed: break;
        case MessageComposeResultCancelled:
            [WTProgressHUD ShowTextHUD:@"您取消了短信邀请" showInView:self]; break;
        default: break;
    }
}

- (void) hide {
    [UIView animateWithDuration:0.25 animations:^{
        contentView.top = self.height;
        tapView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)show {
    [[KEY_WINDOW viewWithTag:SharePopViewTag] removeFromSuperview];
    [KEY_WINDOW addSubview:self];
    contentView.top = self.height;
    tapView.alpha = 0.f;
    
    [UIView animateWithDuration:0.25 animations:^{
        contentView.bottom = self.height;
        tapView.alpha = 0.6f;
    }];
}

- (void)showInViewAlways:(UIView *)superView
{
	[superView addSubview:self];
	[tapView removeFromSuperview];
	[UIView animateWithDuration:0.2 animations:^{
		contentView.bottom = self.height;
		self.bottom = superView.height-64;
	} completion:^(BOOL finished) {

	}];
}

#pragma mark - 修改alertView,actionSheet字体颜色
- (void)willPresentAlertView:(UIAlertView *)alertView
{
	if([[UIDevice currentDevice].systemVersion doubleValue] >= 8.3){
		[[(UIAlertController *)[alertView valueForKey:@"alertController"] actions] enumerateObjectsUsingBlock:^(UIAlertAction *  obj, NSUInteger idx, BOOL *  stop) {
			[obj setValue:WeddingTimeBaseColor forKey:@"titleTextColor"];
		}];
	}
}
- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
	if([[UIDevice currentDevice].systemVersion doubleValue] >= 8.3){
		[[(UIAlertController *)[actionSheet valueForKey:@"alertController"] actions] enumerateObjectsUsingBlock:^(UIAlertAction *  obj, NSUInteger idx, BOOL *  stop) {
			[obj setValue:WeddingTimeBaseColor forKey:@"titleTextColor"];
		}];
	}
}

@end

@implementation SharePopViewInfo

+ (instancetype)SharePopViewInfoWithTitle:(NSString *)aTitle
							andDescription:(NSString *)aDescription
								andUrlStr:(NSString *)aUrl
								andImageURL:(NSString *)imageURL
{

    SharePopViewInfo *info = [[SharePopViewInfo alloc] init];
	info.title             = aTitle.length > 0 ? aTitle :@"婚礼时光" ;
	info.sharedescription  = aDescription ? : @"" ;
    info.urlStr            = aUrl?aUrl:@"http://www.lovewith.me";
	info.imageURL = imageURL ;
	
	if (info.sharedescription.length > kMaxDescLength)
    {
		info.sharedescription = [info.sharedescription substringToIndex:kMaxDescLength - 1];
	}

	if (info.title.length > kMaxTitleLength)
    {
		info.title = [info.title substringToIndex:kMaxTitleLength - 1];
	}

    return info;
}

@end