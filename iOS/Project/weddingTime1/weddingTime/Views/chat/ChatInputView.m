//
//  ChatInputView.m
//  lovewith
//
//  Created by imqiuhang on 15/4/21.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "ChatInputView.h"
#import "LWUtil.h"
#import "QHAudioPlayer.h"
#import "WTProgressHUD.h"
#import "WTKissViewController.h"
#import "WTDrawViewController.h"
#import "WeddingPlanContainerViewController.h"
#import "SetDefaultWeddingTimeViewController.h"
#import "UUAVAudioPlayer.h"
#import "WTAlertView.h"
#import "ChatMessageManager.h"
#import "UserInfoManager.h"
typedef NS_ENUM(NSInteger,KeyBoardState)
{
    KeyBoardStateNone=0,
    KeyBoardStateText,
    KeyBoardStateFace,
    KeyBoardStateMenu
};
//#import "InviteViewController.h"

#define BounceButtonTime 0.5f             //加号按钮弹出的动画时
#define chatMenuExpandButtonWith 32

@implementation ChatInputView
{
    KeyBoardState keyBoardStateNow;
    
    UITextView *textViewInput;
    UITextView *placeholderLabel;
    
    UIView *inputBackGroundView;
    UITapGestureRecognizer *tapGestureRecognizer;
    UIButton *audioBtn;
    UIButton *sendeFaceImageBtn;
    UIButton *sendeImageBtn;
    UIButton *longpressAudioBtn;
    UIButton *backToKeyBoardBtn;
    
    QHVoiceHUD *audioRecordView;
    ChatFaceImageInputView *chatFaceImageInputView;
    ChatMenuView *chatMenuView;
    UIButton *chatMenuExpandButton;
    
    UIView  *chatStatusView;
    UILabel *chatStatusLable;
    
    float originBottom;
    
    BOOL ifWithHomeMenuOpenButtonExpandView;
    
    ChatErrorStatus ChatStatusNow_self;
    ChatErrorStatus ChatStatusLast_self;
    
    NSString *histoaryText;
}
- (instancetype)initWithWeakViewController:(BaseViewController *)weakViewController withHomeMenuOpenButtonExpandView:(BOOL)ifwith{
    if (self=[super init]) {
        originBottom=-1;
        histoaryText=@"";
        ifWithHomeMenuOpenButtonExpandView=ifwith;
        self.inputDelegate=(id<ChatInputViewDelegate>)weakViewController;
        self.weakViewController=weakViewController;
        
        self.frame=(CGRect){0,0,screenWidth,ChatInputViewHeigh};
        self.bottom=self.weakViewController.view.height;
        self.backgroundColor=[UIColor whiteColor];
        [self initView];
        [self addTap];
        self.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    originBottom=self.weakViewController.view.height;
}

#pragma mark - sound

- (void)audioBtnEvent {
    histoaryText=textViewInput.text;
    [self clearTextView];
    
    [self tapBackGround];
    [textViewInput resignFirstResponder];
    inputBackGroundView.hidden=NO;
    [self addSubview:longpressAudioBtn] ;
    [self addSubview:backToKeyBoardBtn];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        longpressAudioBtn.alpha   = 1.f;
        backToKeyBoardBtn.alpha   = 1.f;
        inputBackGroundView.alpha = 0.f;
    } completion:^(BOOL finished) {
        inputBackGroundView.hidden=YES;
        
    }];
}

- (void)backToKeyBoard {
    textViewInput.text=histoaryText;
    [self resetTextView:textViewInput];
    
    [self tapBackGround];
    inputBackGroundView.hidden=NO;
    inputBackGroundView.alpha=0.f;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        longpressAudioBtn.alpha   = 0.f;
        backToKeyBoardBtn.alpha   = 0.f;
        inputBackGroundView.alpha = 1.f;
    } completion:^(BOOL finished) {
        [longpressAudioBtn removeFromSuperview];
        [backToKeyBoardBtn removeFromSuperview];
        
    }];
}

- (void)POVoiceHUD:(QHVoiceHUD *)voiceHUD voiceRecorded:(NSString *)recordPath length:(float)recordLength {
    if (recordLength<=0.5f) {
        [WTProgressHUD ShowTextHUD:@"录音时间太短啦" showInView:KEY_WINDOW];
        return;
    }
    
    [ChatConversationManager sendVoice:recordPath andLenth:recordLength conversation:self.conversation push:YES success:^{
        
    } failure:^(NSError *error) {
        
    }];
}

- (NSString *)fullPathAtCache:(NSString *)fileName{
    NSError *error;
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (YES != [fm fileExistsAtPath:path]) {
        if (YES != [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
        }
    }
    return [path stringByAppendingPathComponent:fileName];
}

#pragma mark - 加入点击背景收缩键盘的手势
- (void)addTap {
    if (!tapGestureRecognizer) {
        tapGestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackGround)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
    }
    
    [self.weakViewController.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)removeTap {
    [self.weakViewController.view removeGestureRecognizer:tapGestureRecognizer];
}

- (void)tapBackGround {
    switch (keyBoardStateNow) {
        case KeyBoardStateNone:
            break;
        case KeyBoardStateFace:
            [self chatFaceImageInputViewShouldHide];
            break;
        case KeyBoardStateText:
            [textViewInput resignFirstResponder];
            break;
        case KeyBoardStateMenu:
            [self chatMenuViewShouldHide];
            break;
        default:
            break;
    }
}

#pragma  mark -keyboardNotify

- (void)keyboardWillShow:(NSNotification *)notification {
    switch (keyBoardStateNow) {
        case KeyBoardStateNone:
            break;
        case KeyBoardStateFace:
            [self chatFaceImageInputViewShouldHide];
            break;
        case KeyBoardStateText:
            break;
        case KeyBoardStateMenu:
            [self chatMenuViewShouldHide];
            break;
        default:
            break;
    }
    keyBoardStateNow=KeyBoardStateText;
    animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyboardHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    CGFloat deltaY=keyboardHeight;
    CGRect rect=self.frame;
    rect.origin.y = originBottom-self.frame.size.height-deltaY;
    if (self.inputDelegate) {
        [self.inputDelegate tableviewAdjustWithkeyboardNotification:rect.origin.y animation:animationDuration];
    }
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.frame=rect;
                         //self.weakViewController.view.top=-keyboardHeight+64;
                     }
                     completion:^(BOOL finished) {
                     }
     ];
}

float animationDuration;
- (void)keyboardWillHide:(NSNotification *)notification {
    animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [self dismissKeyBoard];
}

-(void)dismissKeyBoard{
    keyBoardStateNow=KeyBoardStateNone;
    if (self.inputDelegate&&originBottom!=-1) {
        [self.inputDelegate tableviewAdjustWithkeyboardNotification:originBottom-self.frame.size.height animation:animationDuration];
    }
    
    [UIView animateWithDuration:animationDuration animations:^{
        self.frame = CGRectMake(0, originBottom-self.frame.size.height,  self.frame.size.width,self.frame.size.height);
    }
                     completion:^(BOOL finished) {
                     }
     ];
}

-(void)resetTextView:(UITextView *)textView
{
    float height;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        CGRect textFrame=[[textView layoutManager]usedRectForTextContainer:[textView textContainer]];
        height = textFrame.size.height;
        
    }else {
        height = textView.contentSize.height;
    }
    height+=16;
    textView.scrollEnabled=YES;
    if (textView.height!=height) {
        float deltay=textView.height-height;

        float top=self.top+deltay;
        [UIView animateWithDuration:0.15 animations:^{
            textView.height=height;
            inputBackGroundView.height=height+11.6;
            self.height=inputBackGroundView.height;
            self.top=top;
        }
                         completion:^(BOOL finished) {
                             
                         }
         ];
        
        [textView setContentOffset:CGPointZero animated:YES];
        if (self.inputDelegate) {
            [self.inputDelegate tableviewAdjustWithkeyboardNotification:top animation:0.1];
        }
    }
}

-(void)clearTextView
{
    if ([textViewInput.text isNotEmptyCtg]) {
        textViewInput.text=@"";
        [self resetTextView:textViewInput];
    }
}

#pragma mark - textViewDelegate
-(void)textViewDidChange:(UITextView *)textView
{
    [self resetTextView:textView];
    if (textView.text.length<1) {
        [placeholderLabel setHidden:NO];
    }
    else
    {
        [placeholderLabel setHidden:YES];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    NSString *inputText = [textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    inputText = [inputText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([text isEqualToString:@"\n"]) {
        if ([inputText isNotEmptyCtg]) {
            [ChatConversationManager sendMessage:inputText conversation:self.conversation push:YES success:^{
                
            } failure:^(NSError *error) {
                
            }];
        }
        [self clearTextView];
        //        if ([self.inputDelegate respondsToSelector:@selector(didSendMessage:)]) {
        //            [self.inputDelegate didSendMessage:inputText];
        //
        //        }
        return NO;
    }
    return YES;
}

#pragma mark - 下面菜单按钮的事件和delegate

- (void)choosePicToSend{
    [self tapBackGround];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"发送照片"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"拍照",@"从相册中选" ,nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    FSMediaPicker *mediaPicker = [[FSMediaPicker alloc] init];
    mediaPicker.mediaType = FSMediaTypePhoto;
    mediaPicker.editMode=FSEditModeNone;
    mediaPicker.delegate = self;
    if (buttonIndex==0) {
        [mediaPicker takePhotoFromCamera];
    }else if (buttonIndex==1) {
        [mediaPicker takePhotoFromPhotoLibrary];
    } else{
    }
}

- (void)mediaPicker:(FSMediaPicker *)mediaPicker didFinishWithMediaInfo:(NSDictionary *)mediaInfo {
    
    UIImage *resultImage=mediaPicker.editMode == FSEditModeNone?mediaInfo.originalImage:mediaInfo.editedImage;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"sendeImage.jpg"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:NULL];
    [UIImageJPEGRepresentation(resultImage, 0.6) writeToFile:filePath atomically:YES];
    
    [ChatConversationManager sendImage:filePath text:nil attributes:nil conversation:self.conversation push:YES success:^{
        
    } failure:^(NSError *error) {
        
    }];
    //    if ([self.inputDelegate respondsToSelector:@selector(didSendImage:)]) {
    //        [self.inputDelegate didSendImage:filePath];
    //    }
}

#pragma mark - 发表情
- (void)chatFaceImageInputViewdidSendImage:(NSString *)imageName {
    [ChatConversationManager sendCustomMessageWithPushName:@"[表情]" andConversationTypeKey:ConversationTypeSendFaceImage andConversationValue:imageName andCovTitle:nil conversation:self.conversation push:YES success:^{
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)showOrHideChatFaceImageSendeView:(UIButton *)sender {
    if (sender.tag==0) {
        [self chatFaceImageInputViewShouldShow];
    }else {
        [self chatFaceImageInputViewShouldHide];
    }
}

- (void)chatFaceImageInputViewShouldHide {
    [self dismissKeyBoard];
    [chatFaceImageInputView hide];
    sendeFaceImageBtn.tag=0;
    // [sfbBackImage setImage:[UIImage imageNamed :@"talk_faceimage"]];
}

- (void)chatFaceImageInputViewShouldShow {
    [self tapBackGround];
    [chatFaceImageInputView show];
    keyBoardStateNow=KeyBoardStateFace;
    
    animationDuration=0.25;
    float ChatFaceImageInputViewHeight=  [ChatFaceImageInputView getChatFaceImageInputViewHeight];
    if (self.inputDelegate&&originBottom!=-1) {
        [self.inputDelegate tableviewAdjustWithkeyboardNotification:originBottom-self.frame.size.height-ChatFaceImageInputViewHeight animation:animationDuration];
    }
    [UIView animateWithDuration:animationDuration animations:^{
        self.frame = CGRectMake(0,originBottom-self.frame.size.height-ChatFaceImageInputViewHeight,  self.frame.size.width,self.frame.size.height);
    }
                     completion:^(BOOL finished) {
                     }
     ];
    sendeFaceImageBtn.tag=1;
}

#pragma mark - 按住录音的一系列东西

- (void)beginRecordVoice:(UIButton *)button {
    if(!audioRecordView) {
        audioRecordView=[[QHVoiceHUD alloc] initWithParentView:KEY_WINDOW];
        audioRecordView.delegate=self;
    }
    [audioRecordView setAsNomore];
    [[UUAVAudioPlayer sharedInstance] stopSound];
    //[QHAudioPlayer playSoundWithSoundId:QHAudioPlayer_sound_record_on];
    [self.weakViewController.view addSubview:audioRecordView];
    [audioRecordView startForFilePath:[self fullPathAtCache:@"record.wav"]];
    [self.superview bringSubviewToFront:self];
    
}

- (void)endRecordVoice:(UIButton *)button {
    if (audioRecordView) {
        //[QHAudioPlayer playSoundWithSoundId:QHAudioPlayer_sound_record_off];
        [audioRecordView commitRecording];
    }
}

- (void)cancelRecordVoice:(UIButton *)button {
    if (audioRecordView) {
        [audioRecordView cancelRecording];
    }
}

- (void)RemindDragExit:(UIButton *)button {
    if (audioRecordView) {
        [audioRecordView setAsRelaceToCance];
    }
}

- (void)RemindDragEnter:(UIButton *)button {
    if (audioRecordView) {
        [audioRecordView setAsNomore];
    }
}

#pragma mark - init

-(void)dealloc
{
    [self removeKeyboardNot];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)addKeyboardNot
{
    [self removeKeyboardNot];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)removeKeyboardNot
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)initView {
    UIView *whiteBack=[[UIView alloc]initWithFrame:(CGRect){0,0,screenWidth,screenHeight}];
    whiteBack.backgroundColor=[UIColor whiteColor];
    [self addSubview:whiteBack];
    
    [self addKeyboardNot];
    
    //输入框底座
    inputBackGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, ChatInputViewHeigh)];
    inputBackGroundView.center=CGPointMake(self.width/2, self.height/2);
    inputBackGroundView.backgroundColor = [UIColor whiteColor];
    [self addSubview:inputBackGroundView];
    //按住说话的按钮
    longpressAudioBtn = [[UIButton alloc] initWithFrame:inputBackGroundView.frame];
    longpressAudioBtn.layer.cornerRadius=longpressAudioBtn.height/2.f;
    longpressAudioBtn.backgroundColor=[UIColor whiteColor];
    longpressAudioBtn.titleLabel.font=defaultFont16;
    [longpressAudioBtn setTitleColor:[WeddingTimeAppInfoManager instance].baseColor forState:UIControlStateNormal];
    [longpressAudioBtn setTitleColor:[WeddingTimeAppInfoManager instance].baseColor forState:UIControlStateSelected];
    longpressAudioBtn.width=longpressAudioBtn.width-36;
    
    //@"向上滑动取消发送"
    [longpressAudioBtn setTitle:@"按住说话" forState:UIControlStateNormal];
    [longpressAudioBtn setTitle:@"向上滑动并松开－取消发送" forState:UIControlStateHighlighted];
    [longpressAudioBtn addTarget:self action:@selector(beginRecordVoice:) forControlEvents:UIControlEventTouchDown];
    [longpressAudioBtn addTarget:self action:@selector(endRecordVoice:) forControlEvents:UIControlEventTouchUpInside];
    [longpressAudioBtn addTarget:self action:@selector(cancelRecordVoice:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    [longpressAudioBtn addTarget:self action:@selector(RemindDragExit:) forControlEvents:UIControlEventTouchDragExit];
    [longpressAudioBtn addTarget:self action:@selector(RemindDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
    
    //取消录音的按钮
    backToKeyBoardBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, longpressAudioBtn.top, inputBackGroundView.height, longpressAudioBtn.height)];
    backToKeyBoardBtn.centerX=inputBackGroundView.width-24;
    backToKeyBoardBtn.layer.cornerRadius=backToKeyBoardBtn.height/2.f;
    backToKeyBoardBtn.clipsToBounds=YES;
    [backToKeyBoardBtn addTarget:self action:@selector(backToKeyBoard) forControlEvents:UIControlEventTouchUpInside];
    [backToKeyBoardBtn setImage:[UIImage imageNamed :@"talk_keyboard"] forState:UIControlStateNormal];
    //输入框
    float leftMargin =44;
    float rightMargin =90;
    
    placeholderLabel= [[UITextView alloc]initWithFrame:CGRectMake(leftMargin, 0, inputBackGroundView.width-leftMargin-rightMargin, 22.4+16)];
    placeholderLabel.backgroundColor=[UIColor whiteColor];
    placeholderLabel.centerY=inputBackGroundView.height/2;
    placeholderLabel.textColor     = [UIColor lightGrayColor];
    placeholderLabel.text=@"说点什么吧...";
    placeholderLabel.font          = defaultFont16;
    placeholderLabel.textContainerInset = UIEdgeInsetsMake(8, 0, 8, 0);
    placeholderLabel.scrollsToTop=NO;
    [inputBackGroundView addSubview:placeholderLabel];
    
    textViewInput = [[UITextView alloc]initWithFrame:CGRectMake(leftMargin, 0, inputBackGroundView.width-leftMargin-rightMargin, 22.4+16)];
    textViewInput.backgroundColor=[UIColor clearColor];
    textViewInput.centerY=inputBackGroundView.height/2;
    textViewInput.scrollsToTop=NO;
    textViewInput.delegate = self;
    textViewInput.showsHorizontalScrollIndicator=NO;
    textViewInput.showsVerticalScrollIndicator=NO;
    textViewInput.textColor     = titleLableColor;
    textViewInput.font          = defaultFont16;
    textViewInput.returnKeyType = UIReturnKeySend;
    textViewInput.textContainerInset = UIEdgeInsetsMake(8, 0, 8, 0);

    [inputBackGroundView addSubview:textViewInput];
    
    //录音
    audioBtn = [[UIButton alloc] initWithFrame:CGRectMake(14, 5, 23, 20)];
    [audioBtn setImage:[UIImage imageNamed :@"talk_voice"] forState:UIControlStateNormal];
    audioBtn.clipsToBounds=YES;
    audioBtn.centerY=inputBackGroundView.height/2.f;
    [audioBtn addTarget:self action:@selector(audioBtnEvent) forControlEvents:UIControlEventTouchUpInside];
    
    //表情
    chatFaceImageInputView =  [[ChatFaceImageInputView alloc] init];
    chatFaceImageInputView.baseSuperView=self.weakViewController.view;
    chatFaceImageInputView.delegate=self;
    
    chatMenuView =  [[ChatMenuView alloc] init];
    chatMenuView.baseSuperView=self.weakViewController.view;
    chatMenuView.delegate=self;
    
    sendeFaceImageBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 30,30)];
    [sendeFaceImageBtn setImage:[UIImage imageNamed :@"talk_faceimage"] forState:UIControlStateNormal];
    sendeFaceImageBtn.centerX=inputBackGroundView.width-68;
    sendeFaceImageBtn.centerY=inputBackGroundView.height/2;
    sendeFaceImageBtn.tag=0;
    [sendeFaceImageBtn addTarget:self action:@selector(showOrHideChatFaceImageSendeView:) forControlEvents:UIControlEventTouchUpInside];
    
    
    sendeFaceImageBtn.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    audioBtn.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    [inputBackGroundView addSubview:sendeFaceImageBtn];
    [inputBackGroundView addSubview:audioBtn];
    
    if (!ifWithHomeMenuOpenButtonExpandView) {
        //添加图片
        sendeImageBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [sendeImageBtn setImage:[UIImage imageNamed :@"choose_Pic"] forState:UIControlStateNormal];
        sendeImageBtn.clipsToBounds=YES;
        sendeImageBtn.centerX=inputBackGroundView.width-24;
        sendeImageBtn.centerY=inputBackGroundView.height/2.f;

        [sendeImageBtn addTarget:self action:@selector(choosePicToSend) forControlEvents:UIControlEventTouchUpInside];
        sendeImageBtn.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
        
        [inputBackGroundView addSubview:sendeImageBtn];
    }
    else
    {
        chatMenuExpandButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, chatMenuExpandButtonWith, chatMenuExpandButtonWith)];
        chatMenuExpandButton.centerX=inputBackGroundView.width-24;
        chatMenuExpandButton.centerY=inputBackGroundView.height/2.f;
        
        chatMenuExpandButton.tag=0;
        [chatMenuExpandButton addTarget:self action:@selector(chatMenuBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
        [chatMenuExpandButton setImage:[UIImage imageNamed :@"aso_more"] forState:UIControlStateNormal];
        chatMenuExpandButton.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
        [inputBackGroundView addSubview:chatMenuExpandButton];
    }
    
    [self chatStatusSetWithStatus:inputStatus];
}

#pragma mark ChatMenuViewDelegate
-(void)ChatMenuViewDidTapBtn:(WTChatMenuViewBtnType)type
{
    switch (type) {
        case WTChatMenuViewBtnTypeTakePic:
        {
            FSMediaPicker *mediaPicker = [[FSMediaPicker alloc] init];
            mediaPicker.mediaType = FSMediaTypePhoto;
            mediaPicker.editMode=FSEditModeNone;
            mediaPicker.delegate = self;
            [mediaPicker takePhotoFromCamera];
        }
            break;
        case WTChatMenuViewBtnTypeChoosePic:
        {
            FSMediaPicker *mediaPicker = [[FSMediaPicker alloc] init];
            mediaPicker.mediaType = FSMediaTypePhoto;
            mediaPicker.editMode=FSEditModeNone;
            mediaPicker.delegate = self;
            [mediaPicker takePhotoFromPhotoLibrary];
        }
            break;
        case WTChatMenuViewBtnTypeKiss:
        {
            [WTKissViewController pushViewControllerWithRootViewController:nil isFromJoin:NO];
        }
            break;
        case WTChatMenuViewBtnTypeDraw:
        {
            [WTDrawViewController pushViewControllerWithRootViewController:nil isFromJoin:NO isFromChat:YES];
        }
            break;
        case WTChatMenuViewBtnTypePlan:
        {
            UINavigationController *nav=(UINavigationController*)KEY_WINDOW.rootViewController;
            if ([UserInfoManager instance].weddingTime>0) {
                [nav pushViewController:[WeddingPlanContainerViewController new] animated:YES];
            }else {
                SetDefaultWeddingTimeViewController *setCon=[SetDefaultWeddingTimeViewController new];
                setCon.isFromMain=YES;
                [nav pushViewController:setCon animated:YES];
            }
        }
            break;
        default:
            break;
    }
}

- (void)chatMenuBtnEvent:(UIButton *)sender {
    if (sender.tag==0) {
        [self chatMenuViewShouldShow];
    }else {
        [self chatMenuViewShouldHide];
    }
}

- (void)chatMenuViewShouldHide {
    [self dismissKeyBoard];
    [chatMenuView hide];
    chatMenuExpandButton.tag=0;
    // [sfbBackImage setImage:[UIImage imageNamed :@"talk_faceimage"]];
}

- (void)chatMenuViewShouldShow {
    [self tapBackGround];
    [chatMenuView show];
    animationDuration=0.25;
    keyBoardStateNow=KeyBoardStateMenu;
    
    float ChatMenuViewHeight=  [ChatMenuView getChatMenuViewHeight];
    if (self.inputDelegate&&originBottom!=-1) {
        [self.inputDelegate tableviewAdjustWithkeyboardNotification:originBottom-self.frame.size.height-ChatMenuViewHeight animation:animationDuration];
    }
    [UIView animateWithDuration:animationDuration animations:^{
        self.frame = CGRectMake(0,originBottom-self.frame.size.height-ChatMenuViewHeight,  self.frame.size.width,self.frame.size.height);
    }
                     completion:^(BOOL finished) {
                     }
     ];
    chatMenuExpandButton.tag=1;
}

- (void)reOpenChatNotifyEvent  {
    [[ChatMessageManager instance]openClient];
}

-(void)chatStatusSetWithStatus:(ChatErrorStatus)status
{
    if (ChatStatusNow_self==chatErrorStatusNoPartner&&status!=ChatErrorStatusLoadConversation) {//如果在未绑定状态，则不能被改变(不能用useridparter来判断，不然其他页面的input也会被影响);同时ChatErrorStatusLoadConversation状态可以打破这个状态，因为会话肯定存在了
        return;
    }
    ChatStatusLast_self=ChatStatusNow_self;
    ChatStatusNow_self=status;
    if (!chatStatusView) {
        chatStatusView = [[UIView alloc] initWithFrame:inputBackGroundView.bounds];
        chatStatusView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        chatStatusLable  = [[UILabel alloc] initWithFrame:placeholderLabel.frame];
        chatStatusLable.textColor = [UIColor whiteColor];
        chatStatusLable.font = [WeddingTimeAppInfoManager fontWithSize:14];
        chatStatusLable.textAlignment=NSTextAlignmentCenter;
        [chatStatusView addSubview:chatStatusLable];
    }
    [chatStatusView removeAllGestureRecognizers];
    placeholderLabel.hidden=YES;
    switch (status) {
        case ChatErrorStatusSucceed:
            if (![textViewInput.text isEqualToString:histoaryText]) {
                textViewInput.text=histoaryText;
                [self resetTextView:textViewInput];
            }
            placeholderLabel.hidden=NO;
            [chatStatusView removeFromSuperview];
            break;
        case ChatErrorStatusOpenChatFaild: {
            [self tapBackGround];
            histoaryText=textViewInput.text;
            [self clearTextView];
            [inputBackGroundView addSubview:chatStatusView];
            chatStatusLable.text = @"连接聊天服务器失败,点击重试";
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reOpenChatNotifyEvent)];
            [chatStatusView addGestureRecognizer:tap];
            break;
        }
        case ChatErrorStatusCollecting: {
            [self tapBackGround];
            histoaryText=textViewInput.text;
            [self clearTextView];
            [inputBackGroundView addSubview:chatStatusView];
            chatStatusLable.text = @"正在连接聊天服务器...";
            break;
        }
        case ChatErrorStatusLoadConversation: {
            [self tapBackGround];
            histoaryText=textViewInput.text;
            [self clearTextView];
            [inputBackGroundView addSubview:chatStatusView];
            chatStatusLable.text = @"正在获取会话...";
            break;
        }
        case ChatErrorStatusLoadConversationFaild: {
            [self tapBackGround];
            histoaryText=textViewInput.text;
            [self clearTextView];
            [inputBackGroundView addSubview:chatStatusView];
            chatStatusLable.text = @"获取会话失败,点击重试";
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postReGetConversation)];
            [chatStatusView addGestureRecognizer:tap];
            break;
        }
        case chatErrorStatusNoPartner:{
            [self tapBackGround];
            histoaryText=textViewInput.text;
            [self clearTextView];
            [inputBackGroundView addSubview:chatStatusView];
            chatStatusLable.text = @"点击绑定另一半";
//            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(invitePartner)];
//            [chatStatusView addGestureRecognizer:tap];
            break;
        }
        default:
            break;
    }
}

- (void)postReGetConversation  {
    if (self.inputDelegate&&[self.inputDelegate respondsToSelector:@selector(reGetConversation)]) {
        [self.inputDelegate reGetConversation];
    }
}
@end


