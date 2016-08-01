//
//  WDInviteOtherViewController.m
//  lovewith
//
//  Created by wangxiaobo on 15/5/18.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTInviteGuestViewController.h"
#import "SharePopView.h"
#import "LWUtil.h"
#import "UserInfoManager.h"
#import "GetService.h"
@interface WTInviteGuestViewController ()<UITextViewDelegate>
@property (nonatomic, copy) NSString *shareTitle;
@property (nonatomic, copy) NSString *imageURL;
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

	self.shareTitle = [NSString stringWithFormat:@"%@&%@的婚礼邀请",[UserInfoManager instance].username_self,[UserInfoManager instance].username_partner];

	descriptionTextView.text = [UserInfoManager instance].guestWords;
	descriptionPlaceholder.hidden = descriptionTextView.text.length > 0;

	//更新分享数据
	void(^ShareViewBlock)(void) = ^(void){
		[self hideLoadingView];
		shareView.shareInfo = [SharePopViewInfo SharePopViewInfoWithTitle:self.shareTitle
														   andDescription:descriptionTextView.text
																andUrlStr:HomePageBaseUrl
															  andImageURL:self.imageURL];
	};

	//获得要分享的图片数据（默认为图片故事的第一张图片若没有则是请柬模板）
	[self showLoadingView];
	[GetService getHomePageStoryWithPage:0 andMediaType:@"image" WithBlock:^(NSDictionary *dict, NSError *error) {
		if(!error && [dict[@"data"] count] > 0)
        {
			WTWeddingStory *story = [WTWeddingStory modelWithDictionary:dict[@"data"][0]];
			self.imageURL = story.path.length > 0 ? story.path:story.media;
            ShareViewBlock();
		}
		else
        {
			[LWAssistUtil getCodeMessage:error defaultStr:@"" noresultStr:@""];
			[GetService getHomepageThemeChoosedWithBlock:^(NSDictionary *result, NSError *error) {
				[LWAssistUtil getCodeMessage:error defaultStr:@"" noresultStr:@""];
				self.imageURL = result[@"data"][@"theme_bg"];
                ShareViewBlock();
			}];
		}
	}];
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
	
    shareView.shareInfo = [SharePopViewInfo SharePopViewInfoWithTitle:self.shareTitle
													   andDescription:descriptionTextView.text
															andUrlStr:HomePageBaseUrl
														  andImageURL:self.imageURL];
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
	shareView = [SharePopView viewWithhareTypes:@[@(WTShareTypeWX),
												  @(WTShareTypeQQ),
												  @(WTShareTypeSina),
												  @(WTShareTypeMessage),
												  @(WTShareTypeBless)]];
	[shareView showInViewAlways:self.view];
    
    float leftGap = 18;
    descriptionPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(leftGap + 5, 20, 0, 30)];
    descriptionPlaceholder.width=100;
    descriptionPlaceholder.text = @"至宾客词..";
    descriptionPlaceholder.font = DefaultFont16;
    descriptionPlaceholder.textColor=[LWUtil colorWithHexString:@"#C6C6C6"];
    [self.view addSubview:descriptionPlaceholder];
    
    descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(leftGap, 20, 0, 200)];
    descriptionTextView.width = self.view.width - 2*descriptionTextView.left;
    descriptionTextView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:descriptionTextView];
	
    descriptionTextView.delegate  = self;
    descriptionTextView.font      = DefaultFont16;
    descriptionTextView.textColor = subTitleLableColor;
    descriptionTextView.returnKeyType = UIReturnKeyDone;
    
    UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackGround)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

@end
