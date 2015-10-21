//
//  CommentToolbar.h
//  nihao
//
//  Created by HelloWorld on 7/20/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHMessageTextView.h"
#import "DXFaceView.h"

#define kInputTextViewMinHeight 36
#define kInputTextViewMaxHeight 200
#define kHorizontalPadding 8
#define kVerticalPadding 5

@protocol CommentToolbarDelegate;

@interface CommentToolbar : UIView

@property (nonatomic, assign) id<CommentToolbarDelegate> delegate;

/**
 *  表情的附加页面
 */
@property (strong, nonatomic) UIView *faceView;

/**
 *  操作栏背景图片
 */
@property (strong, nonatomic) UIImage *toolbarBackgroundImage;

/**
 *  背景图片
 */
@property (strong, nonatomic) UIImage *backgroundImage;

/**
 *  用于输入文本消息的输入框
 */
@property (strong, nonatomic) XHMessageTextView *inputTextView;

/**
 *  文字输入区域最大高度，必须 > KInputTextViewMinHeight(最小高度)并且 < KInputTextViewMaxHeight，否则设置无效
 */
@property (nonatomic) CGFloat maxTextInputViewHeight;

@property (nonatomic, copy) NSString *hintText;

/**
 *  初始化方法
 *
 *  @param frame       位置及大小
 *  @param placeholder 提示文字
 *
 *  @return DXMessageToolBar
 */
- (instancetype)initWithFrame:(CGRect)frame withPlaceholderText:(NSString *)placeholder;

/**
 *  默认高度
 *
 *  @return 默认高度
 */
+ (CGFloat)defaultHeight;

@end

@protocol CommentToolbarDelegate <NSObject>

@optional

/**
 *  文字输入框开始编辑
 *
 *  @param inputTextView 输入框对象
 */
- (void)inputTextViewDidBeginEditing:(XHMessageTextView *)messageInputTextView;

/**
 *  文字输入框将要开始编辑
 *
 *  @param inputTextView 输入框对象
 */
- (void)inputTextViewWillBeginEditing:(XHMessageTextView *)messageInputTextView;

/**
 *  发送文字消息，可能包含系统自带表情
 *
 *  @param text 文字消息
 */
- (void)didSendText:(NSString *)text;

/**
 *  发送第三方表情，不会添加到文字输入框中
 *
 *  @param faceLocalPath 选中的表情的本地路径
 */
- (void)didSendFace:(NSString *)faceLocalPath;

@required
/**
 *  高度变到toHeight
 */
- (void)didChangeFrameToHeight:(CGFloat)toHeight;

@end
