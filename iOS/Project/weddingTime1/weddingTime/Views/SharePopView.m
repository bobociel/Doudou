//
//  SharePopView.m
//  lovewith
//
//  Created by imqiuhang on 15/5/14.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "SharePopView.h"
#import "WXApi.h"
#import "QQApiInterface.h"
#import "TencentOAuth.h"
#import "AlertViewWithBlockOrSEL.h"
#import "WTProgressHUD.h"
#define maxInfoLength 200

#define SharePopViewTag 63746264

#define btnWidth 64
#define topGap 30


@implementation SharePopView
{
    NSMutableArray *shareWayInfoArr;
    UIView *contentView;
    UIView *tapView ;
    NSString *emptyErr;
}

- (instancetype)init {
    if (self=[super init]) {
        [self initObject];
        [self initView];
    }
    return self;
}

- (void)initObject {
    shareWayInfoArr = [[NSMutableArray alloc] initWithCapacity:7];
    
    if([WXApi isWXAppInstalled]){
        [shareWayInfoArr addObject:@{
									 @"image" : @"shareIcon_wechatFriend",
                                     @"title" : @"朋友圈",
                                     @"SEL":@"shareWithWechatQuan"
                                     }];
        [shareWayInfoArr addObject:@{
                                     @"image" : @"shareIcon_wechat",
                                     @"title" : @"微信好友",
                                     @"SEL":@"shareWithWechatFriend"
                                     }];
    }

    if ([TencentOAuth iphoneQQInstalled]) {
        [shareWayInfoArr addObject:@{
                                     @"image" : @"shareIcon_qq",
                                     @"title" : @"QQ好友",
                                     @"SEL":@"shareWithQQ"
                                     }];
    }
    
    [shareWayInfoArr addObject:@{
                                 @"image" : @"shareIcon_message",
                                 @"title" : @"短信",
                                 @"SEL":@"shareWithMessage"
                                 }];

}

- (void)initView {
    self.tag=SharePopViewTag;
    self.frame = CGRectMake(0, 0, screenWidth, screenHeight);

    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, (int)(shareWayInfoArr.count/5+1)*btnWidth +(int)(shareWayInfoArr.count/5+2)*topGap)];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.bottom = self.height;
    [self addSubview:contentView];

    
    tapView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-contentView.height)];
    [self addSubview:tapView];
    tapView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [tapView addGestureRecognizer:tap];

    for(int i=0;i<shareWayInfoArr.count;i++) {
        float gap = (screenWidth - 4*btnWidth)/5.f;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((i%4+1)*gap+(i%4)*btnWidth, (int)(i/4+1)*topGap+(int)(i/4)*btnWidth, btnWidth, btnWidth)];
        [btn setImage:[UIImage imageNamed :shareWayInfoArr[i][@"image"]] forState:UIControlStateNormal];
        [btn addTarget:self action:NSSelectorFromString(shareWayInfoArr[i][@"SEL"]) forControlEvents:UIControlEventTouchUpInside];
        UILabel *lable      = [[UILabel alloc] initWithFrame:CGRectMake(btn.left, btn.bottom+5, btn.width, 20)];
        lable.font          = defaultFont12;
        lable.textColor     = titleLableColor;
        lable.textAlignment = NSTextAlignmentCenter;
        lable.text =shareWayInfoArr[i][@"title"];
        
        [contentView addSubview:btn];
        [contentView addSubview:lable];
    }
}


- (void)shareWithWechatQuan {
    [self shareWithWechat:WXSceneTimeline];
}
- (void)shareWithWechatFriend {
    [self shareWithWechat:WXSceneSession];
}

- (void)shareWithWechat:(enum WXScene)aScene{

    WXWebpageObject *wpo = [WXWebpageObject object];
    wpo.webpageUrl = self.shareInfo.urlStr;
    WXMediaMessage *message = [WXMediaMessage message];
    [message setMediaObject:wpo];
    

    if (self.shareInfo.sharedescription.length>maxInfoLength) {
        self.shareInfo.sharedescription=[self.shareInfo.sharedescription substringToIndex:maxInfoLength-1];
    }
    
    if (self.shareInfo.title.length>maxInfoLength) {
        self.shareInfo.title=[self.shareInfo.title substringToIndex:maxInfoLength-1];
    }
    
    [message setDescription:self.shareInfo.sharedescription];
    [message setThumbImage:self.shareInfo.image];
    [message setTitle:self.shareInfo.title];
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = aScene;
    [WXApi sendReq:req];
}

- (void)shareWithQQ {
	
    TencentOAuth* tencentOAuth = [[TencentOAuth alloc] initWithAppId:QQAppId andDelegate:nil];
    if (tencentOAuth) {
        
    }
    
    QQApiNewsObject *newsObj;
    

    if (self.shareInfo.sharedescription.length>maxInfoLength) {
        self.shareInfo.sharedescription=[self.shareInfo.sharedescription substringToIndex:maxInfoLength-1];
    }
    newsObj = [QQApiNewsObject
               objectWithURL:[NSURL URLWithString:self.shareInfo.urlStr]
               title: self.shareInfo.title
               description:self.shareInfo.sharedescription
               previewImageData:UIImagePNGRepresentation(self.shareInfo.image) ];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    if ([QQApiInterface sendReq:req]!=0) {
        [WTProgressHUD ShowTextHUD:@"未知原因,分享失败" showInView:self];
    }
    
}

- (void)shareWithMessage {
    if ([emptyErr isNotEmptyCtg]) {
        if (![self.shareInfo.sharedescription isNotEmptyCtg]) {
            [WTProgressHUD ShowTextHUD:emptyErr showInView:self.superview];
            return;
        }
    }
    
    
    if( [MFMessageComposeViewController canSendText] ) {
        UINavigationController *nav = (UINavigationController *)KEY_WINDOW.rootViewController;
        
        UIViewController *showVC = nav.topViewController;
    
        AlertViewWithBlockOrSEL *alertView = [[AlertViewWithBlockOrSEL alloc] initWithTitle:@"短信发送"
																					message:@"将使用短信分享内容,发送短信资费由运营商决定。我们不会记录您的任何通讯信息。"];
		alertView.delegate = self;
        [alertView addOtherButtonWithTitle:@"确定" onTapped:^{
             MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init];
             controller.body = [NSString stringWithFormat:@"%@\n%@\n链接:%@",self.shareInfo.title,self.shareInfo.sharedescription,self.shareInfo.urlStr];
             controller.messageComposeDelegate =self;
             [showVC presentViewController:controller animated:YES completion:nil];
             }];
        [alertView setCancelButtonWithTitle:@"取消" onTapped:^{
             
         }];
        [alertView show];
  
    }else {
        [WTProgressHUD ShowTextHUD:@"设备不支持发送短信" showInView:self];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
    switch (result) {
        case MessageComposeResultSent:
           [WTProgressHUD ShowTextHUD:@"邀请成功" showInView:self];
            break;
            
        case MessageComposeResultFailed:
            //讯息传送失败
            break;
            
        case MessageComposeResultCancelled:
            [WTProgressHUD ShowTextHUD:@"您取消了短信邀请" showInView:self];
            break;
            
        default:
            break;
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

- (void)showInViewAlways:(UIView *)view andEmptyInfo:(NSString *)errstr{
    [view addSubview:self];
    [tapView removeFromSuperview];
    contentView.bottom = self.height;
    self.bottom=view.height-64;
    emptyErr = errstr;
}

- (void)setAsInvite {
    [shareWayInfoArr removeAllObjects];
    
    if([WXApi isWXAppInstalled]){
        [shareWayInfoArr addObject:@{
                                     @"image" : @"shareIcon_wechat",
                                     @"title" : @"微信好友",
                                     @"SEL":@"shareWithWechatFriend"
                                     }];
    }
    
    if ([TencentOAuth iphoneQQInstalled]) {
        [shareWayInfoArr addObject:@{
                                     @"image" : @"shareIcon_qq",
                                     @"title" : @"QQ好友",
                                     @"SEL":@"shareWithQQ"
                                     }];
    }
    
    [shareWayInfoArr addObject:@{
                                 @"image" : @"shareIcon_message",
                                 @"title" : @"短信",
                                 @"SEL":@"shareWithMessage"
                                 }];
    [self removeAllSubviews];
    [self initView];
    UILabel *clable = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, 200, 20)];
    clable.centerX=contentView.width/2.f;
    clable.font=defaultFont14;
    clable.textColor=titleLableColor;
    clable.text=@"通过以下方式邀请";
    clable.textAlignment = NSTextAlignmentCenter;
    [contentView addSubview:clable];
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

+ (instancetype)SharePopViewInfoMakeWithTitle:(NSString *)aTitle
                               andDescription:(NSString *)aDescription
                                    andUrlStr:(NSString *)aUrl
                                     andImage:(UIImage *)aImage {

    SharePopViewInfo *info = [[SharePopViewInfo alloc] init];
	info.title             = aTitle.length > 0 ? aTitle :@"婚礼时光" ;
    info.sharedescription  = aDescription;
    info.urlStr            = aUrl?aUrl:@"http://www.lovewith.me";
    info.image             = aImage?aImage:[UIImage imageNamed :@"icon-40"];
    return info;
}

@end