//
//  ChatMenuView.h
//  weddingTime
//
//  Created by 默默 on 15/10/6.
//  Copyright (c) 2015年 默默. All rights reserved.
//

typedef NS_ENUM(NSInteger, WTChatMenuViewBtnType) {
    WTChatMenuViewBtnTypeTakePic = 0,
    WTChatMenuViewBtnTypeChoosePic = 1,
    WTChatMenuViewBtnTypeKiss = 2,
    WTChatMenuViewBtnTypePlan= 3,
    WTChatMenuViewBtnTypeDraw =4,
    WTChatMenuViewBtnTypeEnd =4,
};
@protocol ChatMenuViewDelegate <NSObject>

- (void)ChatMenuViewDidTapBtn:(WTChatMenuViewBtnType)type;

@end
@interface ChatMenuView : UIView
@property(nonatomic,weak)id<ChatMenuViewDelegate>delegate;
-(void)show;
- (void)hide;

+ (float)getChatMenuViewHeight;
@property(nonatomic,strong) UIView *baseSuperView;
@end