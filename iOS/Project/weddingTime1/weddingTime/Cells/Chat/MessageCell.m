//
//  MessageCell.m
//  lovewith
//
//  Created by imqiuhang on 15/4/10.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "MessageCell.h"
#import "MessageFrame.h"
#import "UUAVAudioPlayer.h"
#import "UIImageView+AFNetworking.h"
#import "UIButton+AFNetworking.h"
#import "UUImageAvatarBrowser.h"
#import "NSDate+Utils.h"
#import "UserInfoManager.h"
#import "ChatConversationManager.h"
#import "UIImageView+WebCache.h"
#import "WTHotelViewController.h"
#import "WTSupplierViewController.h"
#import "WTDrawViewController.h"
#import "WTKissViewController.h"
#import "WTDemandDetailViewController.h"
#import "WTOrderDetailViewController.h"
#import "WeddingPlanDetailViewController.h"
#import "WTChatDetailViewController.h"
#import "UIImage+Utils.h"
//#import "SearchInsperationCell.h"
//#import "FXBlurView.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
@interface MessageCell () <UUAVAudioPlayerDelegate> {
    AVAudioPlayer   *player;
    NSString        *voiceURL;
    NSData          *songData;
    UUAVAudioPlayer *audio;
    UIView          *headImageBackView;
    
    
}
@property (nonatomic,strong) UITextField    *titleLabel;
@property (nonatomic,strong) UIView         *titleLabelLargeView;
@property (nonatomic,strong) UIView         *titleLabelSmallView;
@end

@implementation MessageCell
-(UIView*)titleLabelLargeView
{
    if (!_titleLabelLargeView) {
        CGRect frame = self.titleLabel.frame;
        frame.size.width = ChatContentLeft;
        UIView *view = [[UIView alloc] initWithFrame:frame];
        _titleLabelLargeView=view;
    }
    return _titleLabelLargeView;
}

-(UIView*)titleLabelSmallView
{
    if (!_titleLabelSmallView) {
        CGRect frame = self.titleLabel.frame;
        frame.size.width = ChatContentRight;
        UIView *view = [[UIView alloc] initWithFrame:frame];
        _titleLabelSmallView=view;
    }
    return _titleLabelSmallView;
}

-(UITextField*)titleLabel
{
    if (!_titleLabel) {
        _titleLabel=[[UITextField alloc]initWithFrame:CGRectMake(0, self.btnContent.size.height-40, self.btnContent.size.width, 40)];
        _titleLabel.backgroundColor=[LWUtil colorWithHexString:@"000000" alpha:0.4];
        _titleLabel.textAlignment=NSTextAlignmentCenter;
        _titleLabel.textColor=[UIColor whiteColor];
        _titleLabel.adjustsFontSizeToFitWidth=YES;
        _titleLabel.text=[NSString stringWithFormat: @"我喜欢了一个灵感"];
		_titleLabel.userInteractionEnabled = NO;
        self.titleLabel.rightViewMode=UITextFieldViewModeAlways;
        self.titleLabel.leftViewMode = UITextFieldViewModeAlways;
        [self.btnContent addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:nil];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle  = UITableViewCellSelectionStyleNone;
        
        // 创建时间lable
        self.labelTime               = [[UILabel alloc] init];
        self.labelTime.textAlignment = NSTextAlignmentCenter;
        self.labelTime.textColor     = [UIColor whiteColor];
        self.labelTime.font          = ChatTimeFont;
        [self.contentView addSubview:self.labelTime];
        
        // 创建头像和点击头像的btn
        headImageBackView = [[UIView alloc]init];
        headImageBackView.layer.cornerRadius  = 22;
        headImageBackView.layer.masksToBounds = YES;
        [self.contentView addSubview:headImageBackView];
        self.btnHeadImage                     = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnHeadImage.layer.cornerRadius  = 20;
        self.btnHeadImage.layer.masksToBounds = YES;
        //        [self.btnHeadImage addTarget:self action:@selector(btnHeadImageClick:)  forControlEvents:UIControlEventTouchUpInside];
        [headImageBackView addSubview:self.btnHeadImage];
        
        // 创建头像下标
        self.labelNum               = [[UILabel alloc] init];
        self.labelNum.textColor     = [UIColor grayColor];
        self.labelNum.textAlignment = NSTextAlignmentCenter;
        self.labelNum.font          = ChatTimeFont;
        [self.contentView addSubview:self.labelNum];
        self.rightImageView = [[UIImageView alloc] init];
        
        // 创建内容的框的btn
        self.btnContent = [MessageContentButton buttonWithType:UIButtonTypeCustom];
        self.btnContent.titleLabel.font          = ChatContentFont;
        self.btnContent.titleLabel.numberOfLines = 0;
        [self.btnContent setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.btnContent addTarget:self action:@selector(btnContentClick)  forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btnContent];
        [self.btnContent addSubview:self.rightImageView];
        
        [self.btnContent setAlpha:1];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(UUAVAudioPlayerDidFinishPlay) name:@"VoicePlayHasInterrupt" object:nil];
        
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [self.btnContent addGestureRecognizer:recognizer];
        
    }
    return self;
}

//头像点击
//- (void)btnHeadImageClick:(UIButton *)button{
//    if ([self.delegate respondsToSelector:@selector(headImageDidClick:userId:)])  {
//        [self.delegate headImageDidClick:self userId:self.messageFrame.message.byClient];
//    }
//}

- (void)btnContentClick{
    
    //不是富文本消息,普通的文本消息 不过我们发的时候即使是文本也是用kAVIMMessageMediaTypeText发的
    //这样为了兼容以后的版本
    if (![self.messageFrame.message.imMessage isKindOfClass:[AVIMTypedMessage class]]) {
        [self.btnContent becomeFirstResponder];
        
    } else {
        AVIMTypedMessage *typedMessage = (AVIMTypedMessage*)self.messageFrame.message.imMessage;
        switch (typedMessage.mediaType) {
            case kAVIMMessageMediaTypeText:
                if (typedMessage.attributes) {
                    UINavigationController *nav = (UINavigationController *)KEY_WINDOW.rootViewController;
                    if ([typedMessage.attributes[ConversationTypeKey] isEqualToString:ConversationTypeLike]) {
                        if ([typedMessage.attributes[ConversationValueKey][@"type"] isEqualToString:@"h"]) {
                            WTHotelViewController *hotelVC = [[WTHotelViewController alloc] init];
                            hotelVC.hotel_id = typedMessage.attributes[ConversationValueKey][@"id"];
                            [nav pushViewController:hotelVC animated:YES];
                        }else if ([typedMessage.attributes[ConversationValueKey][@"type"] isEqualToString:@"s"]) {
                            WTSupplierViewController *sVC = [[WTSupplierViewController alloc] init];
                            sVC.supplier_id =typedMessage.attributes[ConversationValueKey][@"id"];
                            [nav pushViewController:sVC animated:YES];
                        }
                        else if ([typedMessage.attributes[ConversationValueKey][@"type"] isEqualToString:@"p"]) {
                            WeddingPlanDetailViewController *pVC = [[WeddingPlanDetailViewController alloc] init];
                            pVC.data =typedMessage.attributes[ConversationValueKey][@"id"];
                            [nav pushViewController:pVC animated:YES];
                        }
                    }
                    else if ([typedMessage.attributes[ConversationTypeKey] isEqualToString:ConversationTypeCreateDemand]) {
                        WTDemandDetailViewController *pVC = [[WTDemandDetailViewController alloc] init];
                        pVC.rewardId =[typedMessage.attributes[ConversationValueKey][@"id"]intValue];
                        [nav pushViewController:pVC animated:YES];
                    }
                    else if ([typedMessage.attributes[ConversationTypeKey] isEqualToString:ConversationTypeCreateOrder]) {
                        WTOrderDetailViewController *pVC = [[WTOrderDetailViewController alloc] init];
                        pVC.order_id =[LWUtil getString:typedMessage.attributes[ConversationValueKey][@"id"] andDefaultStr:@""];
                        [nav pushViewController:pVC animated:YES];
                    }
                    else if ([typedMessage.attributes[ConversationTypeKey] isEqualToString:ConversationTypeInviteKiss]) {
                        [WTKissViewController pushViewControllerWithRootViewController:nil isFromJoin:(_isMyMsg) ?YES:NO];
                    }else if ([typedMessage.attributes[ConversationTypeKey] isEqualToString:ConversationTypeInviteDraw]) {
                        [WTDrawViewController pushViewControllerWithRootViewController:nil isFromJoin:(_isMyMsg)?YES:NO isFromChat:YES];
                    }
					else if ( [typedMessage.attributes[ConversationTypeKey] isEqualToString:ConversationTypeInvitePlan]){
						WeddingPlanDetailViewController *pVC = [[WeddingPlanDetailViewController alloc] init];
						pVC.data =typedMessage.attributes[ConversationValueKey][@"id"];
						[nav pushViewController:pVC animated:YES];
					}
                    else if ([typedMessage.attributes[ConversationTypeKey] isEqualToString:ConversationTypeChatWithSupplier]) {
                        WTChatDetailViewController *chatDetailVC = [[WTChatDetailViewController alloc] initWithNibName:@"WTChatDetailViewController" bundle:nil];
                        chatDetailVC.conversationId=typedMessage.attributes[ConversationValueKey][@"conversationId"];
                        NSMutableDictionary *dic;
                        if ([typedMessage.attributes[ConversationValueKey][@"hotel_id"] isNotEmptyCtg]) {
                            dic=[NSMutableDictionary new];
                            [dic setObject:[LWUtil getString:typedMessage.attributes[ConversationValueKey][@"name"] andDefaultStr:@""] forKey:@"hotel_name"];
                            [dic setObject:[LWUtil getString:typedMessage.attributes[ConversationValueKey][@"hotel_avatar"] andDefaultStr:@""] forKey:@"hotel_avatar"];
                        }
                        
                        chatDetailVC.hotelData=dic;
                        [nav pushViewController:chatDetailVC animated:YES];
                    }
                }
                break;
            case kAVIMMessageMediaTypeImage:
                //                if (self.btnContent.backImageView) {
                //                    [UUImageAvatarBrowser showImage:self.btnContent.backImageView];
                //                }
                if ([self.delegate isKindOfClass:[UIViewController class]]) {
                    [[(UIViewController *)self.delegate view] endEditing:YES];
                }
                if (self.delegate&&((AVIMTextMessage *)typedMessage).text==nil) {
                    [self.delegate clickShowListImageWithUrl:((AVIMImageMessage*)typedMessage).file.url imageView:self.btnContent.backImageView];
                    
                }else{
                    [self.delegate clickShowListImageWithUrl:((AVIMImageMessage *)typedMessage).attributes[@"imgUrl"] imageView:self.btnContent.backImageView];
                }
                break;
            case kAVIMMessageMediaTypeAudio:
                //如果正在播放
                if ([UUAVAudioPlayer sharedInstance].playingAudioUrl==voiceURL) {
                    [self UUAVAudioPlayerDidFinishPlay];
                }else {
                    audio = [UUAVAudioPlayer sharedInstance];
                    audio.delegate = self;
                    [audio playSongWithUrl:voiceURL];
                    [self UUAVAudioPlayerBeiginLoadVoice];
                    
                }
                break;
            default:
                break;
        }
    }
}

- (void)UUAVAudioPlayerBeiginLoadVoice {
    [self.btnContent benginLoadVoice];
}

- (void)UUAVAudioPlayerBeiginPlay {
    [self.btnContent didLoadVoice];
}

- (void)UUAVAudioPlayerDidFinishPlay {
    [self.btnContent stopPlay];
    [[UUAVAudioPlayer sharedInstance]stopSound];
}

//内容及Frame设置
- (void)setMessageFrame:(MessageFrame *)messageFrame{
    self.btnContent.layer.mask=nil;
    
    _messageFrame        = messageFrame;
    AVIMMessage *message = messageFrame.message.imMessage;
	self.isMyMsg = [message.clientId isEqual:[UserInfoManager instance].userId_self];
	
    [WeddingTimeAppInfoManager setAvatar:self.btnHeadImage userId:message.clientId];
    //
    // 1、设置时间
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:message.sendTimestamp/1000.0];
    NSString *timeS  = [LWUtil getTimeStringWithDate:date];
    
    
    self.labelTime.text               = timeS;
    
    self.labelTime.frame              = messageFrame.timeF;
    CGSize  fSize = [timeS sizeWithFont:ChatContentFont  constrainedToSize:CGSizeMake(MAXFLOAT, self.labelTime.height) lineBreakMode:NSLineBreakByWordWrapping];
    self.labelTime.width=fSize.width;
    self.labelTime.centerX=screenWidth/2.f;
    self.labelTime.layer.cornerRadius = 10.f;
    self.labelTime.clipsToBounds      = YES;
    self.labelTime.textAlignment=NSTextAlignmentCenter;
    self.labelTime.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    self.labelTime.hidden=!messageFrame.showTime;
    if (!messageFrame.showTime) {
        
    }
    
    NSString *userName = @"";
    headImageBackView.frame = messageFrame.iconF;
    self.btnHeadImage.frame = CGRectMake(2, 2, ChatIconWH-4, ChatIconWH-4);
    
    // 3、设置下标
    self.labelNum.text = userName;
    if (messageFrame.nameF.origin.x > 160) {
        self.labelNum.frame = CGRectMake(messageFrame.nameF.origin.x - 50, messageFrame.nameF.origin.y + 3, 100, messageFrame.nameF.size.height);
        self.labelNum.textAlignment = NSTextAlignmentRight;
    }else{
        self.labelNum.frame = CGRectMake(messageFrame.nameF.origin.x, messageFrame.nameF.origin.y + 3, 80, messageFrame.nameF.size.height);
        self.labelNum.textAlignment = NSTextAlignmentLeft;
    }
    
    // 4、设置内容
    
    [self.btnContent setAttributedTitle:nil forState:UIControlStateNormal];
    self.btnContent.voiceBackView.hidden = YES;
    self.btnContent.backImageView.hidden = YES;
    
    self.btnContent.frame = messageFrame.contentF;
    
    UIColor *titlecolor;
    if (_isMyMsg) {
        self.btnContent.isMyMessage = YES;
        titlecolor=[UIColor whiteColor];
        self.btnContent.contentEdgeInsets = UIEdgeInsetsMake(ChatContentTop, ChatContentRight, ChatContentBottom, ChatContentLeft);
        
    }else{
        self.btnContent.isMyMessage = NO;
        titlecolor=[UIColor grayColor] ;
        self.btnContent.contentEdgeInsets = UIEdgeInsetsMake(ChatContentTop, ChatContentLeft, ChatContentBottom, ChatContentRight);
    }
    
    //背景气泡图  这只图片的适应模式和适应的框架  避免边缘被拉伸  ~。~好难调整
    
    NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSMutableAttributedString *testStr=[LWUtil returnAttributedStringWithString:@"test" andLineWidth:6 andFont:ChatContentFont andColor:[UIColor blackColor]];
    
    CGSize  contentSizeTest = [testStr boundingRectWithSize:CGSizeMake(ChatContentW, CGFLOAT_MAX)
                                                    options:options
                                                    context:nil].size;
    
    BOOL isSinge =messageFrame.contentF.size.height> contentSizeTest.height + ChatContentTop + ChatContentBottom?NO:YES;
    if (((AVIMTypedMessage*)message).mediaType==kAVIMMessageMediaTypeAudio) {
        isSinge=YES;
    }
    
#pragma clang diagnostic pop
    UIEdgeInsets insets;
    UIImage *normal=nil;
    
    if (_isMyMsg) {
        if (isSinge) {
            normal =[UIImage imageNamed :@"talk_bubble_red_single"];
            insets=UIEdgeInsetsMake(0, ChatBackImageEdgeRight, 0, ChatBackImageEdgeLeft);
            normal = [normal resizableImageWithCapInsets:insets];
            self.btnContent.height=normal.size.height;
        }else  {
            normal =[UIImage imageNamed :@"talk_bubble_red"];
            insets = UIEdgeInsetsMake(ChatBackImageEdgeTop,  ChatBackImageEdgeRight, ChatBackImageEdgeBottom,  ChatBackImageEdgeLeft);
            normal = [normal resizableImageWithCapInsets:insets];
        }
    } else {
        if(isSinge) {
            normal =[UIImage imageNamed :@"talk_bubble_white_single"];
            insets =UIEdgeInsetsMake(0,  ChatBackImageEdgeLeft, 0,  ChatBackImageEdgeRight);
            normal = [normal resizableImageWithCapInsets:insets];
            self.btnContent.height=normal.size.height;
            
        }else {
            normal =[UIImage imageNamed :@"talk_bubble_white"];
            insets =UIEdgeInsetsMake(ChatBackImageEdgeTop,  ChatBackImageEdgeLeft, ChatBackImageEdgeBottom,  ChatBackImageEdgeRight);
            normal = [normal resizableImageWithCapInsets:insets];
        }
    }
    
    if ([((AVIMTypedMessage*)message).attributes[ConversationTypeKey] isEqualToString:ConversationTypeSendFaceImage]) {
        [self.btnContent setBackgroundImage:nil forState:UIControlStateNormal];
        [self.btnContent setBackgroundImage:nil forState:UIControlStateHighlighted];
    }else {
        [self.btnContent setBackgroundImage:normal forState:UIControlStateNormal];
        [self.btnContent setBackgroundImage:normal forState:UIControlStateHighlighted];
    }
    
    NSString *conversationTypeKey=[LWUtil getString:((AVIMTypedMessage*)message).attributes[ConversationTypeKey] andDefaultStr:@""];
    
    if ([conversationTypeKey isEqualToString:ConversationTypeLike]
        ||[conversationTypeKey isEqualToString:ConversationTypeInviteKiss]
        ||[conversationTypeKey isEqualToString:ConversationTypeInviteDraw]
        ||[conversationTypeKey isEqualToString:ConversationTypeChatWithSupplier]
        ||[conversationTypeKey isEqualToString:ConversationTypeCreateOrder]
        ||[conversationTypeKey isEqualToString:ConversationTypeCreateDemand]
		||[conversationTypeKey isEqualToString:ConversationTypeInvitePlan])
     {
        self.rightImageView.tintColor = [UIColor whiteColor];

        self.rightImageView.image = (_isMyMsg) ?[[UIImage imageNamed :@"icon_arrow_right"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]:[UIImage imageNamed :@"icon_arrow_right"];
//        self.rightImageView.size = self.rightImageView.image.size;
         self.rightImageView.size = CGSizeMake(self.rightImageView.image.size.width + 10, self.rightImageView.image.size.height);
         self.rightImageView.contentMode = UIViewContentModeLeft;
        self.rightImageView.centerY =self.btnContent.height/2.f;
        self.rightImageView.hidden=NO;
        
        float rightImageViewPadding=5;
        float btnContentWidthAdd=rightImageViewPadding+ self.rightImageView.width-(ChatContentRight-rightImageViewPadding);
        
        self.btnContent.width+=btnContentWidthAdd;

        if (_isMyMsg) {
            self.rightImageView.right =self.btnContent.width-rightImageViewPadding-(ChatContentLeft-ChatContentRight);
            self.btnContent.left-=btnContentWidthAdd;
        }
        else
        {
            self.rightImageView.right =self.btnContent.width-rightImageViewPadding;
        }
        
        self.btnContent.contentEdgeInsets = UIEdgeInsetsMake(self.btnContent.contentEdgeInsets.top,self.btnContent.contentEdgeInsets.left,self.btnContent.contentEdgeInsets.bottom,self.btnContent.contentEdgeInsets.right+btnContentWidthAdd);
        
    }else {
        self.rightImageView.hidden=YES;
    }
    
    if (![message isKindOfClass:[AVIMTypedMessage class]]) {
        NSMutableAttributedString *attrStr=[LWUtil returnAttributedStringWithString:message.content andLineWidth:6 andFont:ChatContentFont andColor:titlecolor];
        
        [self.btnContent setAttributedTitle:attrStr forState:UIControlStateNormal];
        
    } else {
        switch (((AVIMTypedMessage*)message).mediaType) {
            case kAVIMMessageMediaTypeText:
                if (!((AVIMTypedMessage*)message).attributes) {
                    NSMutableAttributedString *attrStr=[LWUtil returnAttributedStringWithString:((AVIMTextMessage*)message).text andLineWidth:6 andFont:ChatContentFont andColor:titlecolor];
                    
                    [self.btnContent setAttributedTitle:attrStr forState:UIControlStateNormal];
                }
                else
                {
                    if ([conversationTypeKey isEqualToString:ConversationTypeSendFaceImage])
                    {
                        //发送表情的时候 直接在附件里面发的是f1 f2这样的标志 而不是发一张图片 这样发送更快 所以接收的时候需要在这里单独处理
                        UIImage *image = [UIImage imageNamed :((AVIMTypedMessage*)message).attributes[ConversationValueKey]];
                        self.btnContent.backImageView.hidden = NO;
                        [self.btnContent.backImageView setImage:image];
                        
                        self.btnContent.backImageView.size = CGSizeMake(self.btnContent.size.width-12, self.btnContent.size.height-10) ;
                        
                    }
                    else if (![conversationTypeKey isEqualToString:ConversationTypeLike]
							 &&![conversationTypeKey isEqualToString:ConversationTypeInviteKiss]
							 &&![conversationTypeKey isEqualToString:ConversationTypeInviteDraw]
							 &&![conversationTypeKey isEqualToString:ConversationTypeChatWithSupplier]
							 &&![conversationTypeKey isEqualToString:ConversationTypeCreateOrder]
							 &&![conversationTypeKey isEqualToString:ConversationTypeCreateDemand]
							 &&![conversationTypeKey isEqualToString:ConversationTypeInvitePlan])
                    {
                        NSString *contentText=[NSString stringWithFormat:@"%@（当前版本不支持此功能）",((AVIMTextMessage*)message).text];
                        NSMutableAttributedString *attrStr=[LWUtil returnAttributedStringWithString:contentText andLineWidth:6 andFont:ChatContentFont andColor:titlecolor];
                        
                        [self.btnContent setAttributedTitle:attrStr forState:UIControlStateNormal];
                    }
                    else {
                        NSMutableAttributedString *attrStr=[LWUtil returnAttributedStringWithString:((AVIMTextMessage*)message).text andLineWidth:6 andFont:ChatContentFont andColor:titlecolor];
                        
                        [self.btnContent setAttributedTitle:attrStr forState:UIControlStateNormal];
                    }
                }
                break;
            case kAVIMMessageMediaTypeAudio:
                self.btnContent.voiceBackView.hidden = NO;
                self.btnContent.second.text = [NSString stringWithFormat:@"%.1f's ",((AVIMAudioMessage*)message).duration];
                voiceURL = ((AVIMAudioMessage*)message).file.url;
                if ([UUAVAudioPlayer sharedInstance].playingAudioUrl==voiceURL) {
                    [self.btnContent didLoadVoice];
                }
                break;
            case kAVIMMessageMediaTypeImage:
            {
                
                self.btnContent.backImageView.hidden = NO;
                self.btnContent.backImageView.size = self.btnContent.size;
                
                UIImage *maskImageDrawnToSize=[[MaskCreator instance] returnMaskWithImageSize:messageFrame.contentF.size outOrIn:(_isMyMsg) ? YES:NO];
                
                CALayer *mask = [CALayer layer];
                
                mask.contents = (id)[maskImageDrawnToSize CGImage];
                
                mask.frame = CGRectMake(0, 0, self.btnContent.backImageView.width, self.btnContent.backImageView.height);
                
                self.btnContent.layer.mask = mask;
                self.btnContent.layer.masksToBounds=YES;
                
                if ([((AVIMImageMessage *)message).text isNotEmptyCtg]) {
                    [self.btnContent.backImageView mp_setImageWithURL:((AVIMImageMessage*)message).attributes[@"imgUrl"] placeholderImage:[UIImage imageNamed:@"defaultPic"]];
                }else{
                    [self.btnContent.backImageView mp_setImageWithURL:((AVIMImageMessage*)message).file.url placeholderImage:[UIImage imageNamed:@"defaultPic"]];
                }
                if ([((AVIMTextMessage *)message).text isNotEmptyCtg]) {
                    self.titleLabel.text=[NSString stringWithFormat:@"灵感：%@",((AVIMTextMessage *)message).text];
                    self.titleLabel.hidden=NO;
                    self.titleLabel.frame=CGRectMake(0, self.btnContent.size.height-40, self.btnContent.size.width, 40);
                    if ((_isMyMsg)) {
                        self.titleLabel.rightView=self.titleLabelSmallView;
                        self.titleLabel.leftView = self.titleLabelLargeView;
                    }else{
                        self.titleLabel.rightView=self.titleLabelLargeView;
                        self.titleLabel.leftView = self.titleLabelSmallView;
                    }
                }
                else
                {
                    self.titleLabel.hidden=YES;
                }
            }
                break;
                
                
            default:
                break;
        };
    }
    NSLog(@"%f",self.btnContent.width);
}

-(UIImage*)convertViewToImage:(UIView*)v{
    
    UIGraphicsBeginImageContext(v.bounds.size);
    
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}

-(BOOL) canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(copy:) );
}
//
-(BOOL)canBecomeFirstResponder {
    return YES;
}

/// this methods will be called for the cell menu items


-(void) copy:(id)sender {
    [UIPasteboard generalPasteboard].string =self.btnContent.titleLabel.text;
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan&&self.btnContent.titleLabel.text) {
        [self becomeFirstResponder];

        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setTargetRect:[self convertRect:self.btnContent.frame toView:self.superview] inView:self.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"VoicePlayHasInterrupt" object:nil];
}
@end
