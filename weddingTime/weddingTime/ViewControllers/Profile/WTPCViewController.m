//
//  PCViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/17.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//
#import <UIImageView+WebCache.h>
#import <Masonry/Masonry.h>
#import <POPSpringAnimation.h>
#import "WTPCViewController.h"
#import "WTMainViewController.h"
#import "WTHomeViewController.h"
#import "WTWeddingShopViewController.h"
#import "WTBaoViewController.h"
#import "WTProfileViewController.h"
#import "WTSettingViewController.h"
#import "WTChatListViewController.h"
#import "WTChatDetailViewController.h"
#import "WTLikeListViewController.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "LWUtil.h"
#import "WTProgressHUD.h"
#import "WTTopView.h"
#import "CircleImage.h"
#import "SquareButton.h"
#import "UIView+QHUIViewCtg.h"
#import "RQShineLabel.h"
#import "LWAssistUtil.h"
#import "UserInfoManager.h"
#import "GetService.h"
#import "BlingService.h"
#import "UserInfoManager.h"
#import "NetworkManager.h"
#import "ChatMessageManager.h"
#import "Message.h"
#import "ChatListCell.h"
#import "ConversationStore.h"
#import "BlingHelper.h"
#define kSquareWidth  (screenWidth / 3.0)
#define kSquareHeight (screenWidth / 3.0)
#define kSquareCenterY (screenHeight - kSquareWidth * 2 - kTabBarHeight)
#define kSquareBottomY (screenHeight - kSquareWidth - kTabBarHeight)
@interface WTPCViewController ()<UITextFieldDelegate, UserInfoManagerObserver, ChatMessageManagerDelegate,UIScrollViewDelegate,WTTopViewDelegate>
@property (nonatomic, strong) Message      *message;
@property (nonatomic, strong) SquareButton *cardMainSquare;
@property (nonatomic, strong) SquareButton *shopSquare;
@property (nonatomic, strong) SquareButton *baoSquare;
@property (nonatomic, strong) WTTopView    *topView;
@property (nonatomic, strong) UIButton     *unReadButton;
@end

@implementation WTPCViewController
{
    TPKeyboardAvoidingScrollView *scrollView;
    UITextField  *phoneTextField;
    UIView *levelLine;
    UIButton *blingButton;
    UIButton *reBlingButton;
    RQShineLabel *chatLastLabel;
    CircleImage *myImage;
    CircleImage *partner;
    BOOL hasChangePosition;
    BOOL changePositionToCenter;
    UITapGestureRecognizer *avatarTap;
    UITapGestureRecognizer *partnerTap;
}

-(void)dealloc
{
	[[ChatMessageManager instance] removeObserver:self forName:ourUpdateObserver];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setNavWithHidden
{
	[self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [[[SDImageCache sharedImageCache] initWithNamespace:@"Person"] storeImage:nil forKey:nil];
	[self.topView removeFromSuperview];
	[self.view addSubview:self.topView];
	_topView.unreadCount = [[ConversationStore sharedInstance] conversationUnreadCountAll];

	if([[UserInfoManager instance].tokenId_self isNotEmptyCtg]){
		[BlingHelper updateInviteStateCallback:^{ }];
		[GetService getBlessCountWithBlock:^(NSDictionary *result, NSError *error) {
			[UserInfoManager instance].num_bless = [result[@"count"] doubleValue];
			[[UserInfoManager instance] saveOtherToUserDefaults];
			_cardMainSquare.badgeView.frontView.hidden = [[UserInfoManager instance] getUnreadBlessCount].length==0;
		}];
	}
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    UIViewController *pushVC = self.navigationController.viewControllers.lastObject;
    if(![pushVC isKindOfClass:[WTSettingViewController class]] && ![pushVC isKindOfClass:[WTProfileViewController class]]){
     	[[[SDImageCache sharedImageCache] initWithNamespace:@"default"] storeImage:nil forKey:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[[SDImageCache sharedImageCache] initWithNamespace:@"Person"] storeImage:nil forKey:nil];
    avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goProfile)];
    partnerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goProfile)];
    [self showBlurBackgroundView];

    [self addNotify];
    [self setBaseUI];

    BOOL ifBling = [[UserInfoManager instance].userId_partner isNotEmptyCtg];
	BOOL isLogin = [[UserInfoManager instance].tokenId_self isNotEmptyCtg];
    hasChangePosition = NO;
    changePositionToCenter = NO;
	if(isLogin)
	{
		ifBling ? [self setUIWithBling] : [self setUIWithOutBling] ;
		[self updateInviteState];
	}
	else
	{
		[self setupNotLoginUI];
	}

	self.topView = [WTTopView topViewInView:self.view withType:@[@(WTTopViewTypeSet),@(WTTopViewTypeChat),@(WTTopViewTypeLike)]];
	self.topView.delegate = self;
	[_topView.likeButton setImage:[UIImage imageNamed:@"icon_likes"] forState:UIControlStateNormal];
	[_topView.likeButton setImage:[UIImage imageNamed:@"icon_likes"] forState:UIControlStateSelected];
}

- (void)ourConversationMessageArrive{
    AVIMKeyedConversation *ourCon = [ChatMessageManager instance].keyedConversationOur;
    chatLastLabel.text =[ChatListCell getContentWithWithKeyedConversation:ourCon andMessage:[[ChatMessageManager instance] getLastMessageByConversationId:ourCon.conversationId].imMessage];
    [chatLastLabel shine];
    int unReadNum = [[ConversationStore sharedInstance] conversationUnreadCount:ourCon.conversationId];
    NSString *unReadText = [NSString stringWithFormat:@"%d条未读", unReadNum];
    [_unReadButton setTitle:unReadText forState:UIControlStateNormal];
    CGRect rect = [unReadText boundingRectWithSize:CGSizeMake(MAXFLOAT, 24)
										   options:NSStringDrawingUsesLineFragmentOrigin
										attributes:@{NSFontAttributeName:DefaultFont10}
										   context:nil];
	_unReadButton.frame = CGRectMake((screenWidth - ceil(rect.size.width)) / 2.0 - 10, 362 * Height_ato, ceil(rect.size.width) + 20, 25);
}

-(void)unreadNumUpdateNotificationAction:(NSNotification*)not
{
	self.topView.unreadCount = [not.userInfo[key_unread] doubleValue] ;
}

#pragma mark - Action
- (void)topView:(WTTopView *)topView didSelectedSet:(UIControl *)setButton
{
	if([LWAssistUtil isLogin]){
		[self.navigationController pushViewController:[WTSettingViewController new] animated:YES];
	}
}

- (void)topView:(WTTopView *)topView didSelectedChat:(UIControl *)chatButton
{
	if([LWAssistUtil isLogin]){
		[self.navigationController pushViewController:[WTChatListViewController new] animated:YES];
	}
}

- (void)topView:(WTTopView *)topView didSelectedLike:(UIControl *)likeButton
{
	if([LWAssistUtil isLogin]){
		[self.navigationController pushViewController:[WTLikeListViewController new] animated:YES];
	}
}

- (void)goProfile
{
	if([LWAssistUtil isLogin]){
		[self.navigationController pushViewController:[WTProfileViewController new] animated:YES];
	}
}

- (void)cardMainAction
{
	if([LWAssistUtil isLogin]){
		[self.navigationController pushViewController:[WTHomeViewController new] animated:YES];
	}
}

- (void)shopAction
{
	[self.navigationController pushViewController:[WTWeddingShopViewController new] animated:YES];
}

- (void)baoAction
{
	if([LWAssistUtil isLogin]){
		[self.navigationController pushViewController:[WTBaoViewController new] animated:YES];
	}
}

- (void)loginAction:(UIButton *)button
{
	if(![[UserInfoManager instance].tokenId_self isNotEmptyCtg]){
		[LoginManager pushToLoginViewControllerWithAnimation:YES];
	}
}

#pragma mark - 绑定按钮事件
- (void)blingAction:(UIButton *)button
{
    if ([phoneTextField.text isEqualToString:[UserInfoManager instance].phone_self]) {
        [WTProgressHUD ShowTextHUD:@"不要输入自己的手机号码" showInView:self.view];
        return;
    }
    BOOL isPhoneNumber = [LWUtil validatePhoneNumber:phoneTextField.text];
    if (isPhoneNumber) {
        
        phoneTextField.userInteractionEnabled = NO;
        button.hidden = YES;
        button.userInteractionEnabled = NO;
        reBlingButton.userInteractionEnabled = YES;
        reBlingButton.hidden = NO;
        [BlingService blingPartnerWithPhone:phoneTextField.text block:^(NSDictionary *result, NSError *error) {
            NSMutableDictionary *mu = [NSMutableDictionary dictionaryWithDictionary:[UserInfoManager instance].inviteDic];
            [mu setObject:InviteState_invite forKey:[UserInfoManager instance].userId_self];
            [UserInfoManager instance].inviteDic = [NSMutableDictionary dictionaryWithDictionary:mu];
            [[UserInfoManager instance] saveOtherToUserDefaults];
            NSNumber *number = result[@"status"];
            if (number.integerValue == 4001) {
                
            }
            if (number.integerValue == 4002) {
                
            }
        }];
        phoneTextField.text = @"正在等待另一半确认绑定";
        phoneTextField.textAlignment = NSTextAlignmentCenter;
        [UIView animateWithDuration:0.5 animations:^{
            levelLine.alpha = 0;
        }];
    }
	else
	{
        [WTProgressHUD ShowTextHUD:@"请输入正确的手机号码" showInView:[[UIApplication sharedApplication] keyWindow]];
    }
}

- (void)setSingleUI
{
    reBlingButton.hidden = YES;
    reBlingButton.userInteractionEnabled = NO;
    blingButton.hidden = NO;
    blingButton.userInteractionEnabled = YES;
    phoneTextField.userInteractionEnabled = YES;
    phoneTextField.text = nil;
    phoneTextField.textAlignment = NSTextAlignmentLeft;
    [UIView animateWithDuration:0.5 animations:^{
        levelLine.alpha = 1;
    }];
}

- (void)inviteStateUISet
{
	phoneTextField.userInteractionEnabled = NO;
	blingButton.hidden = YES;
	blingButton.userInteractionEnabled = NO;
	reBlingButton.userInteractionEnabled = YES;
	reBlingButton.hidden = NO;
	NSMutableDictionary *mu = [NSMutableDictionary dictionaryWithDictionary:[UserInfoManager instance].inviteDic];
	[mu setObject:InviteState_invite forKey:[UserInfoManager instance].userId_self];
	[UserInfoManager instance].inviteDic = [NSMutableDictionary dictionaryWithDictionary:mu];
	[[UserInfoManager instance] saveOtherToUserDefaults];
	phoneTextField.text = @"正在等待另一半确认绑定";
	phoneTextField.textAlignment = NSTextAlignmentCenter;
	[UIView animateWithDuration:0.5 animations:^{
		levelLine.alpha = 0;
	}];
}

#pragma mark - 重新绑定
- (void)reBlingAction
{
    NSMutableDictionary *mu = [NSMutableDictionary dictionaryWithDictionary:[UserInfoManager instance].inviteDic];
    [mu setObject:InviteState_single forKey:[UserInfoManager instance].userId_self];
    [UserInfoManager instance].inviteDic = [NSMutableDictionary dictionaryWithDictionary:mu];
    [[UserInfoManager instance] saveOtherToUserDefaults];
    reBlingButton.hidden = YES;
    reBlingButton.userInteractionEnabled = NO;
    blingButton.hidden = NO;
    blingButton.userInteractionEnabled = YES;
    phoneTextField.userInteractionEnabled = YES;
    phoneTextField.text = nil;
    phoneTextField.textAlignment = NSTextAlignmentLeft;
    [UIView animateWithDuration:0.5 animations:^{
        levelLine.alpha = 1;
    }];
}

#pragma mark - 跳转至和另一半的聊天详细
- (void)jumpToChatDetail
{
    [_unReadButton setTitle:@"0条未读" forState:UIControlStateNormal];
    [self showLoadingViewTitle:@"获取会话中..."];
    [[ChatMessageManager instance]makeOurConversation:^{
        [self hideLoadingView];
        AVIMKeyedConversation *KeyedConversation=[ChatMessageManager instance].keyedConversationOur;
        NSString*KEY=KeyedConversation.conversationId;
        AVIMConversation *conversation=[[ChatMessageManager instance]getConversationWithId:KEY];
        if (conversation) {
            [WTChatDetailViewController pushToChatDetailWithConversation:conversation];
        }
        else
        {
            [WTChatDetailViewController pushToChatDetailWithKeyConversation:KeyedConversation];
        }
        
    } failure:^{
        [self hideLoadingView];
        [WTProgressHUD ShowTextHUD:@"获取会话失败" showInView:self.view];
    }];
}

#pragma mark - 新消息回调

//- (void)newMessageArrived:(NSString*)message conversation:(NSString*)conv {
//    chatLastLabel.text = conv;
//    [chatLastLabel shine];
//}

#pragma mark - 解除绑定回调
- (void)removeBlingChangeUI
{
	[self.unReadButton removeFromSuperview];
	[chatLastLabel removeFromSuperview];
    
    POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    positionAnimation.toValue             = [NSValue valueWithCGPoint:CGPointMake(screenWidth / 2.0, 75 *screenHeight / 736.0 + 40)];
    positionAnimation.springBounciness    = 15;
    positionAnimation.springSpeed         = 5;
    [myImage pop_addAnimation:positionAnimation forKey:@"myImageAnimation"];
    
    POPSpringAnimation *positionAnimationRight = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    positionAnimationRight.toValue             = [NSValue valueWithCGPoint:CGPointMake(screenWidth / 2.0 , 75 *screenHeight / 736.0 + 40)];
    positionAnimationRight.springBounciness    = 15;
    positionAnimationRight.springSpeed         = 5;
    [partner pop_addAnimation:positionAnimationRight forKey:@"parternerAnimation"];
    
    changePositionToCenter = YES;

	[[UserInfoManager instance].tokenId_self isNotEmptyCtg] ? [self setUIWithOutBling]  : [self setupNotLoginUI];
}

#pragma mark - 基础UI
- (void)setBaseUI
{
	scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
	scrollView.clipsToBounds=NO;
	self.view.backgroundColor      = [UIColor whiteColor];
	scrollView.contentSize         = CGSizeMake(scrollView.width,scrollView.height+0.5);
	scrollView.delegate = self;
	scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
	[self.view addSubview:scrollView];

	_cardMainSquare = [[SquareButton alloc] initWithFrame:CGRectMake(0, kSquareBottomY, kSquareWidth, kSquareHeight)];
	_cardMainSquare.nameLabel.text = @"电子请柬";
	[_cardMainSquare.iconButton setImage:[UIImage imageNamed:@"icon_home_expand"] forState:UIControlStateNormal];
	[self.view addSubview:_cardMainSquare];
	[_cardMainSquare addTarget:self action:@selector(cardMainAction) forControlEvents:UIControlEventTouchUpInside];

	_shopSquare = [[SquareButton alloc] initWithFrame:CGRectMake(kSquareWidth , kSquareBottomY, kSquareWidth, kSquareHeight)];
	_shopSquare.nameLabel.text = @"新娘商店";
	[_shopSquare.iconButton setImage:[UIImage imageNamed:@"icon_shop_wedding"] forState:UIControlStateNormal];
	[self.view addSubview:_shopSquare];
	[_shopSquare addTarget:self action:@selector(shopAction) forControlEvents:UIControlEventTouchUpInside];

    _baoSquare = [[SquareButton alloc] initWithFrame:CGRectMake(kSquareWidth * 2,kSquareBottomY, kSquareWidth , kSquareHeight)];
    _baoSquare.nameLabel.text = @"婚礼宝";
	[_baoSquare.iconButton setImage:[UIImage imageNamed:@"icon_bao"] forState:UIControlStateNormal];
	[self.view addSubview:_baoSquare];
    [_baoSquare addTarget:self action:@selector(baoAction) forControlEvents:UIControlEventTouchUpInside];
}

#pragma marl - 未登录状态的UI
- (void)setupNotLoginUI
{
	[phoneTextField removeFromSuperview];
	[levelLine removeFromSuperview];
	[partner removeFromSuperview];

	[myImage removeFromSuperview];
	myImage = [CircleImage new];
	[myImage addGestureRecognizer:avatarTap];
	[scrollView addSubview:myImage];
	myImage.centerImage.image = [UIImage imageNamed:@"male_default"];
	myImage.centerImage.contentMode = UIViewContentModeScaleAspectFill;
	myImage.frame = CGRectMake(screenWidth / 2.0 - 40, 75 * screenHeight / 736.0, 80, 80);
	myImage.hidden = NO;

	[blingButton removeFromSuperview];
	blingButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[scrollView addSubview:blingButton];
	[blingButton setTitle:@"登录" forState:UIControlStateNormal];
	[blingButton setTitleColor:WHITE forState:UIControlStateNormal];
	[blingButton setTitleColor:LIGHTGRAY forState:UIControlStateHighlighted];
	[blingButton addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
	[blingButton setBackgroundColor:[LWUtil colorWithHexString:@"#FF6499" alpha:1.0]];
	blingButton.layer.cornerRadius = 25 * screenHeight / 736.0;
	[blingButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.mas_equalTo(350 * screenHeight / 736.0);
		make.centerX.mas_equalTo(scrollView);
		make.left.mas_equalTo(47 * screenWidth / 414.0);
		make.height.mas_equalTo(50 * screenHeight / 736.0);
	}];
}

#pragma mark - 未绑定状态下的UI
- (void)setUIWithOutBling
{
	[partner removeFromSuperview];
	partner = [CircleImage new];
	partner.centerImage.contentMode = UIViewContentModeScaleAspectFill;
	[[UserInfoManager instance] setPartnerAvatar:partner.centerImage];
	[partner addGestureRecognizer:partnerTap];
	[scrollView addSubview:partner];
	partner.frame = CGRectMake(screenWidth / 2.0 - 40, 75 * screenHeight / 736.0, 80, 80);
    partner.hidden = YES;

	[myImage removeFromSuperview];
	myImage = [CircleImage new];
	myImage.centerImage.contentMode = UIViewContentModeScaleAspectFill;
	[[UserInfoManager instance] setMyAvatar:myImage.centerImage];
	[myImage addGestureRecognizer:avatarTap];
	[scrollView addSubview:myImage];
	myImage.frame = CGRectMake(screenWidth / 2.0 - 40, 75 * screenHeight / 736.0, 80, 80);

	[phoneTextField removeFromSuperview];
	phoneTextField  = [[UITextField alloc] init];
	phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	[phoneTextField setAsCommInputTextField];
	phoneTextField.top         = 313 * screenHeight / 735.0;
	phoneTextField.delegate    = self;
	phoneTextField.placeholder = @"输入另一半的手机号";
	[phoneTextField setValue:WHITE forKeyPath:@"_placeholderLabel.textColor"];
	phoneTextField.tintColor = WHITE;
	phoneTextField.textColor = WHITE;
	phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
	phoneTextField.returnKeyType=UIReturnKeyNext;
	[scrollView addSubview:phoneTextField];

	[levelLine removeFromSuperview];
	levelLine = [[UIView alloc] initWithFrame:CGRectMake(42.97, phoneTextField.frame.origin.y + phoneTextField.frame.size.height, screenWidth - 42.97 * 2, 0.8 * 736 / screenHeight)];
	levelLine.backgroundColor = WHITE;
	levelLine.alpha = 0.4;
	[scrollView addSubview:levelLine];

	[blingButton removeFromSuperview];
	blingButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[scrollView addSubview:blingButton];
	[blingButton setTitle:@"绑定" forState:UIControlStateNormal];
	[blingButton setTitleColor:WHITE forState:UIControlStateNormal];
	[blingButton setTitleColor:LIGHTGRAY forState:UIControlStateHighlighted];
	[blingButton addTarget:self action:@selector(blingAction:) forControlEvents:UIControlEventTouchUpInside];
	[blingButton setBackgroundColor:[LWUtil colorWithHexString:@"#FF6499" alpha:1.0]];
	blingButton.layer.cornerRadius = 25 * screenHeight / 736.0;
	[blingButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.mas_equalTo(382 * screenHeight / 736.0);
		make.centerX.mas_equalTo(scrollView);
		make.left.mas_equalTo(47 * screenWidth / 414.0);
		make.height.mas_equalTo(50 * screenHeight / 736.0);
	}];

	[reBlingButton removeFromSuperview];
	reBlingButton = [UIButton buttonWithType:UIButtonTypeCustom];
	reBlingButton.userInteractionEnabled = NO;
	[reBlingButton addTarget:self action:@selector(reBlingAction) forControlEvents:UIControlEventTouchUpInside];
	reBlingButton.hidden = YES;
	[reBlingButton setTitle:@"重新绑定" forState:UIControlStateNormal];
	reBlingButton.titleLabel.font = [UIFont systemFontOfSize:15];
	[reBlingButton setTitleColor:WHITE forState:UIControlStateNormal];
	[reBlingButton setTitleColor:LIGHTGRAY forState:UIControlStateHighlighted];
	[scrollView addSubview:reBlingButton];

	reBlingButton.frame = CGRectMake(165 * Width_ato, 372 * Height_ato, 84 * Width_ato, 18 * Height_ato);
}

#pragma mark - 绑定状态下的UI
- (void)setUIWithBling
{
    WS(ws);
	[partner removeFromSuperview];
	partner = [CircleImage new];
	partner.centerImage.contentMode = UIViewContentModeScaleAspectFill;
	[[UserInfoManager instance] setPartnerAvatar:partner.centerImage];
	[partner addGestureRecognizer:partnerTap];
	[scrollView addSubview:partner];
	partner.frame = CGRectMake(screenWidth / 2.0 - 5, 75 * screenHeight / 736.0, 80, 80);

	[myImage removeFromSuperview];
	myImage = [CircleImage new];
	myImage.contentMode = UIViewContentModeScaleAspectFill;
	[[UserInfoManager instance] setMyAvatar:myImage.centerImage];
	[myImage addGestureRecognizer:avatarTap];
	[scrollView addSubview:myImage];
	myImage.frame = CGRectMake(screenWidth / 2.0 - 75, 75 * screenHeight / 736.0, 80, 80);

	[chatLastLabel removeFromSuperview];
	chatLastLabel = [RQShineLabel new];
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpToChatDetail)];
	chatLastLabel.userInteractionEnabled = YES;
	[chatLastLabel addGestureRecognizer:tap];
	chatLastLabel.textAlignment = NSTextAlignmentCenter;
	[scrollView addSubview:chatLastLabel];
	chatLastLabel.text = @"和另一半聊聊吧";
	chatLastLabel.textColor = WHITE;
	chatLastLabel.font = [UIFont systemFontOfSize:21];
	[chatLastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.mas_equalTo(309 * screenHeight / 736.0);
		make.centerX.mas_equalTo(ws.view);
		make.size.mas_equalTo(CGSizeMake(screenWidth, 25));
		make.left.mas_equalTo(0);
	}];

	[_unReadButton removeFromSuperview];
	self.unReadButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_unReadButton.layer.cornerRadius = 24 / 2.0;
	_unReadButton.backgroundColor = WHITE;
	_unReadButton.titleLabel.font = DefaultFont10;
	[_unReadButton setTitle:@"0条未读" forState:UIControlStateNormal];
	[_unReadButton setTitleColor:rgba(100, 100, 100, 1) forState:UIControlStateNormal];
	[_unReadButton setTitleColor:rgba(100, 100, 100, 1) forState:UIControlStateHighlighted];
	[scrollView addSubview:_unReadButton];
	[_unReadButton addTarget:self action:@selector(jumpToChatDetail) forControlEvents:UIControlEventTouchUpInside];
	_unReadButton.frame = CGRectMake((screenWidth - 65) / 2.0, 362 * Height_ato, 65 , 24);
    
    [[ChatMessageManager instance] makeOurConversation:^{
        AVIMKeyedConversation *ourCon = [ChatMessageManager instance].keyedConversationOur;
        _message = [[ChatMessageManager instance] getLastMessageByConversationId:ourCon.conversationId];
        chatLastLabel.text =[ChatListCell getContentWithWithKeyedConversation:ourCon andMessage:_message.imMessage];
        [chatLastLabel shine];
        
        [[ChatMessageManager instance] addObserver:self forName:ourUpdateObserver];
    } failure:^{
        
    }];
}

#pragma mark - UI更新
- (void)updateInviteState
{
	if (![[UserInfoManager instance].userId_partner isNotEmptyCtg]) {
		NSMutableDictionary *muDic = [UserInfoManager instance].inviteDic;
		NSString *inviteState = [muDic objectForKey:[UserInfoManager instance].userId_self];
		if ([inviteState isNotEmptyCtg] && [inviteState isEqualToString:InviteState_invite]) {
			[self inviteStateUISet];
		} else {
			[self setSingleUI];
		}
	}
}

- (void)userInfoUpdate
{
	[[UserInfoManager instance] setMyAvatar:myImage.centerImage];
	myImage.centerImage.contentMode = UIViewContentModeScaleAspectFill;

	if ([[UserInfoManager instance].userId_partner isNotEmptyCtg])
	{
		NSMutableDictionary *mu = [NSMutableDictionary dictionaryWithDictionary:[UserInfoManager instance].inviteDic];
		[mu setObject:InviteState_double forKey:[UserInfoManager instance].userId_self];
		[UserInfoManager instance].inviteDic = [NSMutableDictionary dictionaryWithDictionary:mu];

		[[UserInfoManager instance] setPartnerAvatar:partner.centerImage];

		CGPoint centerPoint = CGPointMake(screenWidth / 2.0 - 35, myImage.center.y);
		CGPoint centerPointRight = CGPointMake(screenWidth / 2.0 + 35, myImage.center.y);

		POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
		positionAnimation.toValue             = [NSValue valueWithCGPoint:centerPoint];
		positionAnimation.springBounciness    = 15;
		positionAnimation.springSpeed         = 5;
		[myImage pop_addAnimation:positionAnimation forKey:@"myImageAnimation"];

		POPSpringAnimation *positionAnimationRight = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
		positionAnimationRight.toValue             = [NSValue valueWithCGPoint:centerPointRight];
		positionAnimationRight.springBounciness    = 15;
		positionAnimationRight.springSpeed         = 5;
		partner.hidden = NO;
		[partner pop_addAnimation:positionAnimationRight forKey:@"parternerAnimation"];

		hasChangePosition = YES;
		[phoneTextField removeFromSuperview];
		[levelLine removeFromSuperview];
		[blingButton removeFromSuperview];
		[reBlingButton removeFromSuperview];

		[self setUIWithBling];
	}
	else
	{
		[self removeBlingChangeUI];
	}
}

#pragma mark - 添加通知
- (void)addNotify
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoUpdate) name:UserInfoUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSingleUI) name:RefuseBinding object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInviteState) name:reLoginNotify object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeBlingChangeUI) name:UserDidRebindSucceedNotify object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unreadNumUpdateNotificationAction:) name:unreadNumUpdateNotification object:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView1{
	CGFloat yOffset = scrollView.contentOffset.y;
	_baoSquare.hidden = yOffset < -50;
	_cardMainSquare.hidden = yOffset < -50;
	_shopSquare.hidden = yOffset < -50;

	if (yOffset < 0)
	{
		CGFloat factor = ((ABS(yOffset)+screenHeight)*screenWidth) / screenHeight;
		CGRect f = CGRectMake(-(factor-screenWidth)/2, yOffset, factor, screenHeight+ABS(yOffset));
		self.blurImageView.frame = f;
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
