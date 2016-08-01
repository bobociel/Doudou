//
//  PCViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/17.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTPCViewController.h"
#import "WTMainViewController.h"
#import "WTLoginViewController.h"
#import "WTHomeViewController.h"
#import "WTProfileViewController.h"
#import "WTSettingViewController.h"
#import "WTChatDetailViewController.h"
#import "WTLikeListViewController.h"
#import "WTOrderListViewController.h"
#import "WTDemandListViewController.h"
#import "CircleImage.h"
#import "SquareButton.h"
#import "LWUtil.h"
#import "WTProgressHUD.h"
#import "UIView+QHUIViewCtg.h"
#import "BlingService.h"
#import "UserInfoManager.h"
#import "NetworkManager.h"
#import <Masonry/Masonry.h>
#import "RQShineLabel.h"
#import "LWAssistUtil.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"
#import "UserInfoManager.h"
#import <POPSpringAnimation.h>
#import <AVOSCloud.h>
#import "GetService.h"
#import "PostDataService.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "WTLocalDataManager.h"
#import "ChatMessageManager.h"
#import <UIImageView+WebCache.h>
#import "AVOSCloudIM.h"
#import "Message.h"
#import "ChatListCell.h"
#import "ConversationStore.h"
#import "UIImage+YYAdd.h"
#import "KYCuteView.h"
@interface WTPCViewController ()<UITextFieldDelegate, UserInfoManagerObserver, ChatMessageManagerDelegate,UIScrollViewDelegate>
@property (nonatomic, strong) UIButton *homePagebutton;
@property (nonatomic, strong) SquareButton *likeSquare;
@property (nonatomic, strong) SquareButton *orderSquare;
@property (nonatomic, strong) SquareButton *demandSquare;
@property (nonatomic, strong) UIButton *unReadButton;
@property (nonatomic, strong) Message *message;
@property (nonatomic, strong) KYCuteView *badgeView;
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
    UIImageView *image1;
    UIImageView *image2;
    UIImageView *image3;
    UIImageView *image4;
    BOOL hasScroll;
    BOOL hasHidden;
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [[[SDImageCache sharedImageCache] initWithNamespace:@"Person"] storeImage:nil forKey:nil];
    
	self.badgeView.frontView.hidden = YES;
	[GetService getBlessCountWithBlock:^(NSDictionary *result, NSError *error) {
		[UserInfoManager instance].num_bless = [result[@"count"] doubleValue];
		[[UserInfoManager instance] saveBlessCToUserDefaults];
		self.badgeView.frontView.hidden = [[UserInfoManager instance] getUnreadBlessCount].length == 0;
		self.badgeView.bubbleLabel.text = [[UserInfoManager instance] getUnreadBlessCount];
	}];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    UIViewController *pushVC = self.navigationController.viewControllers.lastObject;
    if(![pushVC isKindOfClass:[WTSettingViewController class]] && ![pushVC isKindOfClass:[WTProfileViewController class]]){
     	[[[SDImageCache sharedImageCache] initWithNamespace:@"default"] storeImage:nil forKey:nil];
    }
}

-(void)setNavWithHidden
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)dealloc
{
    [[ChatMessageManager instance] removeObserver:self forName:ourUpdateObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[[SDImageCache sharedImageCache] initWithNamespace:@"Person"] storeImage:nil forKey:nil];
    avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goProfile)];
    partnerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goProfile)];
    [self showBlurBackgroundView];
    scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    scrollView.clipsToBounds=NO;
    self.view.backgroundColor      = [UIColor whiteColor];
    scrollView.contentSize         = CGSizeMake(scrollView.width,scrollView.height+0.5);
    scrollView.delegate = self;
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:scrollView];
    
    [self addNotify];
    [self setBaseUI];
    [self setBaseNum];
    
    [[UserInfoManager instance] addInfoUpdateObserver:self forName:infoUpdateObserver];
    BOOL ifBling = [[UserInfoManager instance].userId_partner isNotEmptyCtg];
    //    [[ChatMessageManager instance] addObserver:self forName:listUpdateObserver];
    hasChangePosition = NO;
    changePositionToCenter = NO;
    if (ifBling) {
        
        [self setUIWithBling];
        NSString *avatar_self = [UserInfoManager instance].avatar_self;
        NSString *avatar_partner = [UserInfoManager instance].avatar_partner;
        if (!([avatar_self isNotEmptyCtg] || [avatar_partner isNotEmptyCtg])) {
            myImage.centerImage.image = [UIImage imageNamed:@"male_default"];
            partner.centerImage.image = [UIImage imageNamed:@"female_default"];
        }
    } else {
        [self setUIWithOutBling];
    }
    [self updateInviteState];
    
   // Do any additional setup after loading the view.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView1{
    CGFloat yOffset   = scrollView.contentOffset.y;
    
    if (hasScroll) {
        
    } else {
        hasScroll = YES;
        image1 = [self.view viewWithTag:1000];
        image2 = [self.view viewWithTag:1001];
        image3 = [self.view viewWithTag:1002];
        image4 = [self.view viewWithTag:1003];
    }
    
    if (yOffset < -50) {
        if (!hasHidden) {
            image1.hidden = YES;
            image2.hidden = YES;
            image3.hidden = YES;
            image4.hidden = YES;
            _likeSquare.hidden = YES;
            _orderSquare.hidden = YES;
            _demandSquare.hidden = YES;
            hasHidden = YES;
        }
        
    } else if(hasHidden){
        
        image1.hidden = NO;
        image2.hidden = NO;
        image3.hidden = NO;
        image4.hidden = NO;
        _likeSquare.hidden = NO;
        _orderSquare.hidden = NO;
        _demandSquare.hidden = NO;
        hasHidden = NO;
    }
    if (yOffset < 0) {
        
        UIImage *back=[UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"image"]];
        if (back) {
            
        }else{
            back = [UIImage imageNamed:@"Bitmap.jpg"];
        }
        float state = (170 + yOffset) / 170;
        if (state < 0.169) {
            return;
        }
        UIImage *blImage = [back imageByBlurRadius:state * 40 tintColor:nil tintMode:0 saturation:1 maskImage:nil];
        
        [self setBlurImageViewWithImage:blImage state:state];
    }
}


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

- (void)ourConversationMessageArrive{
    AVIMKeyedConversation *ourCon = [ChatMessageManager instance].keyedConversationOur;
    chatLastLabel.text =[ChatListCell getContentWithMessage: [[ChatMessageManager instance] getLastMessageByConversationId:ourCon.conversationId].imMessage];
    [chatLastLabel shine];
    int unReadNum = [[ConversationStore sharedInstance] conversationUnreadCount:ourCon.conversationId];
    NSString *unReadText = [NSString stringWithFormat:@"%d条未读", unReadNum];
    [_unReadButton setTitle:unReadText forState:UIControlStateNormal];
    CGRect rect = [unReadText boundingRectWithSize:CGSizeMake(10000, 25) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
    WS(ws);
    [_unReadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(362 * screenHeight / 736.0);
        make.centerX.mas_equalTo(ws.view);
        make.size.mas_equalTo(CGSizeMake(rect.size.width + 30, 25));
    }];
    
}

- (void)setBaseNum
{
    [[UserInfoManager instance] saveToUserDefaults];
    _likeSquare.numLabel.text = [LWUtil getString:[UserInfoManager instance].num_like andDefaultStr:@"0"];
    _orderSquare.numLabel.text = [LWUtil getString:[UserInfoManager instance].num_order andDefaultStr:@"0"];
    NSString *str = [NSString stringWithFormat:@"%@", [UserInfoManager instance].num_demand];
    _demandSquare.numLabel.text = [LWUtil getString:str andDefaultStr:@"0"];
}

#pragma mark - 数据存储
- (void)saveDataWithResult:(NSDictionary *)result
{
    [UserInfoManager instance].avatar_self = result[@"avatar"];
    [UserInfoManager instance].avatar_partner = result[@"half_avatar"];
    [UserInfoManager instance].phone_partner = result[@"half_phone"];
    [UserInfoManager instance].wedding_address = result[@"wedding_address"];
    [UserInfoManager instance].username_partner = result[@"half_username"];
    [UserInfoManager instance].domainName = result[@"domain"];
    [[UserInfoManager instance] saveToUserDefaults];
    [self reLoadData];
}

#pragma mark - UI更新
- (void)reLoadData
{
    UserInfoManager *userMG = [UserInfoManager instance];
    
    UIImage *image;
    UIImage *partnerImage;
    
    if (userMG.userGender == UserGenderMale) {
        
        image = [UIImage imageNamed:@"male_default.png"];
        partnerImage = [UIImage imageNamed:@"female_default.png"];
    } else {
        image = [UIImage imageNamed:@"female_default.png"];
        partnerImage = [UIImage imageNamed:@"male_default.png"];
    }

    [myImage.centerImage sd_setImageWithURL:[NSURL URLWithString:userMG.avatar_self] placeholderImage:image];
    [partner.centerImage sd_setImageWithURL:[NSURL URLWithString:userMG.avatar_partner] placeholderImage:partnerImage];
    myImage.centerImage.contentMode = UIViewContentModeScaleAspectFill;
    partner.centerImage.contentMode = UIViewContentModeScaleAspectFill;
}

#pragma mark - 婚礼主页按钮事件
- (void)homePageAction
{
    [self.navigationController pushViewController:[WTHomeViewController new] animated:YES];
    //[self newMessageArrived:nil conversation:@"老婆，我爱你"];
}

- (void)goProfile
{
    [self.navigationController pushViewController:[WTProfileViewController new] animated:YES];
}

#pragma mark - 设置按钮事件
- (void)setButtonAction
{
    // [self newMessageArrived:nil conversation:@"我爱你"];
    [self.navigationController pushViewController:[WTSettingViewController new] animated:YES];
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
    [[UserInfoManager instance]saveToUserDefaults];
    phoneTextField.text = @"正在等待另一半确认绑定";
    phoneTextField.textAlignment = NSTextAlignmentCenter;
    [UIView animateWithDuration:0.5 animations:^{
        
        levelLine.alpha = 0;
    }];
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
            [[UserInfoManager instance]saveToUserDefaults];
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
    } else {
        // shake?
        //加代码
        
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
#pragma mark - 重新绑定
- (void)reBlingAction
{
    NSMutableDictionary *mu = [NSMutableDictionary dictionaryWithDictionary:[UserInfoManager instance].inviteDic];
    [mu setObject:InviteState_single forKey:[UserInfoManager instance].userId_self];
    [UserInfoManager instance].inviteDic = [NSMutableDictionary dictionaryWithDictionary:mu];
    [[UserInfoManager instance]saveToUserDefaults];
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

#pragma mark - 喜欢按钮事件
- (void)likeButtonAction
{
    WTLikeListViewController *like = [WTLikeListViewController new];
    [self.navigationController pushViewController:like animated:YES];
}

#pragma mark - 订单按钮事件
- (void)orderButtonAction
{
    WTOrderListViewController *order = [WTOrderListViewController new];
    [self.navigationController pushViewController:order animated:YES];
}

#pragma mark - 续期按钮事件
- (void)demandButtonAction
{
    WTDemandListViewController *vc=[WTDemandListViewController new];
    [self.navigationController pushViewController:vc animated:YES];
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

#pragma mark - 绑定成功后的回调
- (void)blingSucceedChangeUI
{
    
    
}

#pragma mark - 解除绑定回调
- (void)removeBlingChangeUI
{
    if (self.unReadButton) {
        [self.unReadButton removeFromSuperview];
    }
    
    self.unReadButton = nil;
    if (chatLastLabel) {
        [chatLastLabel removeFromSuperview];
    }
    chatLastLabel = nil;
    
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
    
    
    [self setUIWithOutBling];
}

#pragma mark - 基础UI
- (void)setBaseUI
{
	self.homePagebutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [scrollView addSubview:_homePagebutton];
    _homePagebutton.layer.cornerRadius = 23;
    [_homePagebutton setBackgroundImage:[UIImage imageNamed:@"main.png"] forState:UIControlStateNormal];
    [_homePagebutton setBackgroundImage:[UIImage imageNamed:@"main_select.png"] forState:UIControlStateHighlighted];
    [_homePagebutton addTarget:self action:@selector(homePageAction) forControlEvents:UIControlEventTouchUpInside];
    [_homePagebutton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(89 * screenHeight / 736.0);
        make.left.mas_equalTo(32 * screenWidth / 414.0);
        make.size.mas_equalTo(CGSizeMake(46, 46));
    }];

	self.badgeView = [_homePagebutton badgeViewWithViewWidth:46.0];

    UIButton *setButton = [UIButton buttonWithType:UIButtonTypeCustom];
    setButton.layer.cornerRadius = 23;
    [setButton setBackgroundImage:[UIImage imageNamed:@"set.png"] forState:UIControlStateNormal];
    [setButton setBackgroundImage:[UIImage imageNamed:@"set_select.png"] forState:UIControlStateHighlighted];
    [setButton addTarget:self action:@selector(setButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:setButton];
    [setButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_homePagebutton.mas_top).with.offset(0);
        make.left.mas_equalTo(326 * screenWidth / 414.0);
        make.size.mas_equalTo(CGSizeMake(46, 46));
    }];
    
    self.likeSquare = [[SquareButton alloc] initWithFrame:CGRectMake(0, screenHeight - screenWidth / 3.0 - 49, screenWidth / 3.0 , screenWidth / 3.0)];
    _likeSquare.nameLabel.text = @"喜欢";
    [_likeSquare addTarget:self action:@selector(likeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_likeSquare];
    
    self.orderSquare = [[SquareButton alloc] initWithFrame:CGRectMake(screenWidth / 3.0, screenHeight - screenWidth / 3.0 - 49, screenWidth / 3.0, screenWidth / 3.0)];
    _orderSquare.nameLabel.text = @"订单";
    [_orderSquare addTarget:self action:@selector(orderButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_orderSquare];
    
    self.demandSquare = [[SquareButton alloc] initWithFrame:CGRectMake(screenWidth / 3.0 * 2, screenHeight - screenWidth / 3.0 - 49, screenWidth / 3.0, screenWidth / 3.0)];
    _demandSquare.nameLabel.text = @"需求";
    [_demandSquare addTarget:self action:@selector(demandButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_demandSquare];

    UIImageView *levelImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, screenHeight - screenWidth / 3.0 - 49, screenWidth, 1 * 736 / screenHeight)];
    levelImage.image = [LWUtil imageWithColor:rgba(255, 255, 255, 0.4) frame:CGRectMake(0, 0, screenWidth, 0.4)];
    levelImage.tag = 1000;
    [self.view addSubview:levelImage];
    for (int i = 1; i < 3; i++) {
        UIImageView *verticalLine = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth / 3.0 * i, screenHeight - screenWidth / 3.0 - 49, 1 * 736 / screenHeight, screenWidth / 3.0)];
        verticalLine.tag = 1000 + i;
        verticalLine.image = [LWUtil imageWithColor:rgba(255, 255, 255, 0.4) frame:CGRectMake(0, 0, screenWidth, 0.4)];
        [self.view addSubview:verticalLine];
    }
    
}

#pragma mark - 未绑定状态下的UI
- (void)setUIWithOutBling
{
    UserGender usergender = [UserInfoManager instance].userGender;
    if (!partner) {
        partner = [CircleImage new];
        [partner addGestureRecognizer:partnerTap];
        [scrollView addSubview:partner];
        if (usergender == UserGenderMale) {
            [partner.centerImage sd_setImageWithURL:[NSURL URLWithString:[UserInfoManager instance].avatar_partner] placeholderImage:[UIImage imageNamed:@"female_default"]] ;
        } else {
            [partner.centerImage sd_setImageWithURL:[NSURL URLWithString:[UserInfoManager instance].avatar_partner] placeholderImage:[UIImage imageNamed:@"male_default"]] ;
        }
        partner.centerImage.contentMode = UIViewContentModeScaleAspectFill;
        partner.frame = CGRectMake(screenWidth / 2.0 - 40, 75 * screenHeight / 736.0, 80, 80);
    }
    partner.hidden = YES;
    if (!myImage) {
        myImage = [CircleImage new];
        [myImage addGestureRecognizer:avatarTap];
        [scrollView addSubview:myImage];
        
        if (usergender == UserGenderMale) {
            [myImage.centerImage sd_setImageWithURL:[NSURL URLWithString:[UserInfoManager instance].avatar_self] placeholderImage:[UIImage imageNamed:@"male_default"]] ;
        } else {
            [myImage.centerImage sd_setImageWithURL:[NSURL URLWithString:[UserInfoManager instance].avatar_self] placeholderImage:[UIImage imageNamed:@"female_default"]] ;
        }
        myImage.centerImage.contentMode = UIViewContentModeScaleAspectFill;
        
        myImage.frame = CGRectMake(screenWidth / 2.0 - 40, 75 * screenHeight / 736.0, 80, 80);
    }
    if (!phoneTextField) {
        phoneTextField             = [[UITextField alloc] init];
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
        
        levelLine = [[UIView alloc] initWithFrame:CGRectMake(42.97, phoneTextField.frame.origin.y + phoneTextField.frame.size.height, screenWidth - 42.97 * 2, 0.8 * 736 / screenHeight)];
        levelLine.backgroundColor = WHITE;
        levelLine.alpha = 0.4;
        [scrollView addSubview:levelLine];
    }
    if (!blingButton) {
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
    }
    
    if (!reBlingButton) {
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
}

#pragma mark - 绑定状态下的UI
- (void)setUIWithBling
{
    WS(ws);
    if (!partner) {
        partner = [CircleImage new];
        [partner addGestureRecognizer:partnerTap];
        
        [scrollView addSubview:partner];
        
        if ([UserInfoManager instance].userGender == UserGenderMale) {
            [partner.centerImage sd_setImageWithURL:[NSURL URLWithString:[UserInfoManager instance].avatar_partner] placeholderImage:[UIImage imageNamed:@"female_default"]] ;
        } else {
            [partner.centerImage sd_setImageWithURL:[NSURL URLWithString:[UserInfoManager instance].avatar_partner] placeholderImage:[UIImage imageNamed:@"male_default"]] ;
        }
        partner.centerImage.contentMode = UIViewContentModeScaleAspectFill;
        partner.hidden = NO;
        partner.frame = CGRectMake(screenWidth / 2.0 - 5, 75 * screenHeight / 736.0, 80, 80);
    }
    
    if (!myImage) {
        myImage = [CircleImage new];
        [myImage addGestureRecognizer:avatarTap];
        [scrollView addSubview:myImage];
        
        if ([UserInfoManager instance].userGender == UserGenderMale) {
            [myImage.centerImage sd_setImageWithURL:[NSURL URLWithString:[UserInfoManager instance].avatar_self] placeholderImage:[UIImage imageNamed:@"male_default"]] ;
        } else {
            [myImage.centerImage sd_setImageWithURL:[NSURL URLWithString:[UserInfoManager instance].avatar_self] placeholderImage:[UIImage imageNamed:@"female_default"]] ;
        }
        myImage.contentMode = UIViewContentModeScaleAspectFill;
        myImage.frame = CGRectMake(screenWidth / 2.0 - 75, 75 * screenHeight / 736.0, 80, 80);
    }
    if (!chatLastLabel) {
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
        
        self.unReadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _unReadButton.layer.cornerRadius = 25 / 2.0;
        _unReadButton.backgroundColor = WHITE;
        _unReadButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_unReadButton setTitle:@"0条未读" forState:UIControlStateNormal];
        [_unReadButton setTitleColor:BLACK forState:UIControlStateNormal];
        [scrollView addSubview:_unReadButton];
        [_unReadButton setTitleColor:LIGHTGRAY forState:UIControlStateHighlighted];
        [_unReadButton addTarget:self action:@selector(jumpToChatDetail) forControlEvents:UIControlEventTouchUpInside];
        [_unReadButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(362 * screenHeight / 736.0);
            make.centerX.mas_equalTo(ws.view);
            make.size.mas_equalTo(CGSizeMake(80, 25));
        }];
        
    }
    
    [[ChatMessageManager instance] makeOurConversation:^{
        AVIMKeyedConversation *ourCon = [ChatMessageManager instance].keyedConversationOur;
        _message = [[ChatMessageManager instance] getLastMessageByConversationId:ourCon.conversationId];
        chatLastLabel.text =[ChatListCell getContentWithMessage: _message.imMessage];
        [chatLastLabel shine];
        
        [[ChatMessageManager instance] addObserver:self forName:ourUpdateObserver];
    } failure:^{
        
    }];
}

#pragma mark - 用户数据更新

- (NSString *)getPlusStrWith:(NSString *)string
{
    if (string.intValue < 0) {
        string = @"0";
    }
    return string;
}

- (void)userInfoUpdate
{
    if ([[UserInfoManager instance].num_like isNotEmptyCtg]) {
        
        _likeSquare.numLabel.text = [self getPlusStrWith:[UserInfoManager instance].num_like];
    }
    
    if ([[UserInfoManager instance].num_order isNotEmptyCtg]) {
        _orderSquare.numLabel.text = [UserInfoManager instance].num_order;
    }
    if ([[UserInfoManager instance].num_demand isNotEmptyCtg]) {
        NSString *str = [NSString stringWithFormat:@"%@", [UserInfoManager instance].num_demand];
        _demandSquare.numLabel.text = str;
    }
    UIImage *image;
    UIImage *anImage;
    if ([UserInfoManager instance].userGender == UserGenderFemale) {
        image = [UIImage imageNamed:@"female_default"];
        anImage = [UIImage imageNamed:@"male_default"];
    } else {
        anImage = [UIImage imageNamed:@"female_default"];
        image = [UIImage imageNamed:@"male_default"];
    }
    [myImage.centerImage sd_setImageWithURL:[NSURL URLWithString:[UserInfoManager instance].avatar_self] placeholderImage:image];
    myImage.centerImage.contentMode = UIViewContentModeScaleAspectFill;
    if ([[UserInfoManager instance].userId_partner isNotEmptyCtg]) {
        NSMutableDictionary *mu = [NSMutableDictionary dictionaryWithDictionary:[UserInfoManager instance].inviteDic];
        [mu setObject:InviteState_double forKey:[UserInfoManager instance].userId_self];
        [UserInfoManager instance].inviteDic = [NSMutableDictionary dictionaryWithDictionary:mu];
        
        [partner.centerImage sd_setImageWithURL:[NSURL URLWithString:[UserInfoManager instance].avatar_partner] placeholderImage:anImage];
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
        
        
        if (phoneTextField) {
            [phoneTextField removeFromSuperview];
            
        }
        if (levelLine) {
            [levelLine removeFromSuperview];
        }
        if (blingButton) {
            [blingButton removeFromSuperview];
        }
        if (reBlingButton) {
            [reBlingButton removeFromSuperview];
        }
        
        phoneTextField = nil;
        levelLine = nil;
        blingButton = nil;
        reBlingButton = nil;
        partner.hidden = NO;
        [self setUIWithBling];
    } else {
        [self removeBlingChangeUI];
    }
    
}

-(void)jumpToDemaindVC{
    [self.navigationController pushViewController:[WTDemandListViewController new] animated:YES];
}

#pragma mark - 添加通知
- (void)addNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSingleUI) name:RefuseBinding object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInviteState) name:reLoginNotify object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blingSucceedChangeUI) name:UserDidBindingPartnerNotify object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeBlingChangeUI) name:UserDidRebindSucceedNotify object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setBaseUI) name:BaseNumChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blingSucceedChangeUI) name:PushRemoteIdBindingPartner object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeBlingChangeUI) name:PushRemoteIdReBindingPartner object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(jumpToDemaindVC) name:PushRemotUpdateRequirement object:nil]; 
    // Do any additional setup after loading the view.
}

-(void)changeBackgroundImage{
    [self showBlurBackgroundView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
