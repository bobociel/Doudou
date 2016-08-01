//
//  ChatInputView.h
//  lovewith
//
//  Created by imqiuhang on 15/4/21.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "QHVoiceHUD.h"
#import "FSMediaPicker.h"
#import "ChatFaceImageInputView.h"
#import "ChatConversationManager.h"
#import "ChatMenuView.h"
#define ChatInputViewHeigh 50.f
#define selfBottomPadding 64
#define chatStatusChnagedNotify @"chatStatusChnagedNotify"
#define chatShouldReOpenNotify  @"chatShouldReOpenNotify"

typedef NS_ENUM(NSInteger, ChatErrorStatus) {
    ChatErrorStatusSucceed = 0,
    ChatErrorStatusOpenChatFaild = 1,
    ChatErrorStatusCollecting =2,
    chatErrorStatusNoPartner=3,
    
    ChatErrorStatusLoadConversation =4,
    ChatErrorStatusLoadConversationFaild =5,
    
};

@protocol ChatInputViewDelegate <NSObject>

//- (void)didSendMessage:(NSString *)message __deprecated_msg("ChatInputViewDelegate已经废弃了,刚开始是用delegate通知到聊天窗口在聊天窗口直接发的,现在为了兼容后续版本 直接用ChatConversationManager里面的方法发送");
//- (void)didSendVoice:(NSString *)filePath andLenth:(float)lenth __deprecated_msg("ChatInputViewDelegate已经废弃了,为了兼容后续版本 直接用ChatConversationManager里面的方法发送");
//- (void)didSendImage:(NSString *)imagePath __deprecated_msg("ChatInputViewDelegate已经废弃了,为了兼容后续版本 直接用ChatConversationManager里面的方法发送");
//- (void)didSendFaceImage:(NSString *)imageName __deprecated_msg("ChatInputViewDelegate已经废弃了,为了兼容后续版本 直接用ChatConversationManager里面的方法发送");

-(void)tableviewAdjustWithkeyboardNotification:(float)Y animation:(NSTimeInterval)animationTime;

-(void)reGetConversation;
@end
static ChatErrorStatus inputStatus;//全局初始状态：ChatErrorStatusSucceed ChatErrorStatusOpenChatFaild ChatErrorStatusCollecting

@interface ChatInputView : UIView <UITextViewDelegate,QHVoiceHUDDelegate,UIActionSheetDelegate,FSMediaPickerDelegate,ChatFaceImageInputViewDelegate,ChatMenuViewDelegate>

@property (nonatomic,weak)id<ChatInputViewDelegate>inputDelegate;
@property (nonatomic,weak)BaseViewController *weakViewController;
@property (nonatomic,weak)AVIMConversation *conversation;
- (instancetype)initWithWeakViewController:(BaseViewController *)weakViewController withHomeMenuOpenButtonExpandView:(BOOL)ifwith;

-(void)chatStatusSetWithStatus:(ChatErrorStatus)status;//只针对一个
- (void)tapBackGround;

- (void)addKeyboardNot;
- (void)removeKeyboardNot;
@end
