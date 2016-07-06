/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "EMChatViewBaseCell.h"

#import "EMChatTextBubbleView.h"
#import "EMChatImageBubbleView.h"
#import "EMChatAudioBubbleView.h"
#import "EMChatVideoBubbleView.h"
#import "EMChatLocationBubbleView.h"

#define SEND_STATUS_SIZE 20 // 发送状态View的Size
#define ACTIVTIYVIEW_BUBBLE_PADDING 5 // 菊花和bubbleView之间的间距

#define TRANSLATE_BTN_WIDTH			60
#define TRANSLATE_BTN_INTERVAL		15

extern NSString *const kResendButtonTapEventName;
extern NSString *const kShouldResendCell;
extern NSString *const kRouterEventAudioBubbleShowTranslationEventName;
extern NSString *const kRouterEventAudioBubbleHideTranslationEventName;
extern NSString *const kShowTranlationCell;
extern NSString *const kRouterEventChatCellAtTapEventName;

@interface EMChatViewCell : EMChatViewBaseCell

//sender
@property (nonatomic, strong) UIActivityIndicatorView *activtiy;
@property (nonatomic, strong) UIView *activityView;
@property (nonatomic, strong) UIButton *retryButton;

//receiver
@property (nonatomic, strong) UIButton *showTranslationBtn;
@property (nonatomic, strong) UIView	*tranlationView;
@property (nonatomic, strong) UILabel	*tranlationLabel;
@property (nonatomic, strong) UIActivityIndicatorView	*tranlatingIndicator;

@property (nonatomic) BOOL isShowTranslation;

@end
