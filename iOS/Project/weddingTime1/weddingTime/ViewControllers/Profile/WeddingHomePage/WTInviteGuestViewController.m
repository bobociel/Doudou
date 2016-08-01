//
//  WDInviteOtherViewController.m
//  lovewith
//
//  Created by wangxiaobo on 15/5/18.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <SDWebImage/SDWebImageDownloader.h>
#import <SDWebImage/SDImageCache.h>
#import "WTInviteGuestViewController.h"
#import "SharePopView.h"
#import "LWUtil.h"
#import "UserInfoManager.h"
#import "GetService.h"
@interface WTInviteGuestViewController ()<UITextViewDelegate>
@property (nonatomic, copy) NSString *shareTitle;
@property (nonatomic, strong) UIImage *shareImage;
@end

@implementation WTInviteGuestViewController
{
    SharePopView *shareView;
    UILabel *descriptionPlaceholder;
    UITextView *descriptionTextView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];

	self.shareTitle = [NSString stringWithFormat:@"%@和%@的婚礼邀请",[UserInfoManager instance].username_self,[UserInfoManager instance].username_partner];

	if([UserInfoManager instance].guestWords.length == 0)
	{
		[UserInfoManager instance].guestWords = [NSString stringWithFormat:@"我们要结婚了!%@,诚邀您的光临.",[[UserInfoManager instance] weddingTimeStringYMD]];
		[[UserInfoManager instance] saveToUserDefaults];
	}

	descriptionTextView.text = [UserInfoManager instance].guestWords;
	descriptionPlaceholder.hidden = descriptionTextView.text.length > 0;

	//更新分享数据
	void(^ShareViewBlock)(void) = ^(void){
		[self hideLoadingView];
		self.shareImage = [LWUtil OriginImage:self.shareImage scaleToSize:CGSizeMake(300, 300)];
		shareView.shareInfo = [SharePopViewInfo SharePopViewInfoMakeWithTitle:self.shareTitle
															   andDescription:descriptionTextView.text
																	andUrlStr:HomePageBaseUrl
																	 andImage:self.shareImage];
	};

	//获得要分享的图片数据（默认为图片故事的第一张图片若没有则是请柬模板）
	[self showLoadingView];
	[GetService getHomePageStoryWithPage:0 andMediaType:@"image" WithBlock:^(NSDictionary *dict, NSError *error) {
		if(!error && [dict[@"data"] count] > 0){
			WTWeddingStory *story = [WTWeddingStory modelWithDictionary:dict[@"data"][0]];
			NSString *imageURL = story.path.length > 0 ? story.path:story.media;
			self.shareImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageURL];
			if(!self.shareImage){
				[self getShareImageWithURL:imageURL callback:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
					self.shareImage = image;
					ShareViewBlock();
				}];
			}else{
				ShareViewBlock();
			}
		}
		else{
			[GetService getHomepageThemeChoosedWithBlock:^(NSDictionary *result, NSError *error) {
				NSString *themeURLString = result[@"data"][@"theme_bg"];
				self.shareImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:themeURLString];
				if(self.shareImage == nil){
					[self getShareImageWithURL:themeURLString callback:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
						self.shareImage = image;
						ShareViewBlock();
					}];
				}
				else{
					ShareViewBlock();
				}
			}];
		}
	}];

}

//根据URL获得图片
- (void)getShareImageWithURL:(NSString *)url callback:(SDWebImageDownloaderCompletedBlock)callback
{
	[[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:url]
														  options:SDWebImageDownloaderLowPriority
														 progress:nil
														completed:callback];
}

#pragma mark - Text View

- (void)textViewDidBeginEditing:(UITextView *)textView {
	if(textView.text.length == 0){
		descriptionPlaceholder.hidden= YES;
	}else{
		descriptionPlaceholder.hidden = YES;
	}
}

-(void)textViewDidChange:(UITextView *)textView
{
	descriptionPlaceholder.hidden = textView.text.length > 0;

	[UserInfoManager instance].guestWords = textView.text;
	[[UserInfoManager instance] saveToUserDefaults];
	
    shareView.shareInfo = [SharePopViewInfo SharePopViewInfoMakeWithTitle:self.shareTitle
														   andDescription:descriptionTextView.text
																andUrlStr:HomePageBaseUrl
																 andImage:self.shareImage];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"] ) {
        [textView resignFirstResponder];
    }
    return YES;
}

- (void)tapBackGround {
    [descriptionTextView resignFirstResponder];
}

- (void)initView {
    self.title = @"邀请宾客";
    shareView = [[SharePopView alloc] init];
	[shareView showInViewAlways:self.view andEmptyInfo:@""];
    
    float leftGap = 18;
    descriptionPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(leftGap + 5, 20, 0, 30)];
    descriptionPlaceholder.width=100;
    descriptionPlaceholder.text = @"至宾客词..";
    descriptionPlaceholder.font=defaultFont16;
    descriptionPlaceholder.textColor=[LWUtil colorWithHexString:@"#C6C6C6"];
    [self.view addSubview:descriptionPlaceholder];
    
    descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(leftGap, 20, 0, 200)];
    descriptionTextView.width=self.view.width-2*descriptionTextView.left;
    descriptionTextView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:descriptionTextView];
	
    descriptionTextView.delegate  = self;
    descriptionTextView.font      = defaultFont16;
    descriptionTextView.textColor = subTitleLableColor;
    
    descriptionTextView.returnKeyType  =UIReturnKeyDone;
    
    UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackGround)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

@end
