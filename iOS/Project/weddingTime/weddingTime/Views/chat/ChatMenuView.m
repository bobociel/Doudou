//
//  ChatMenuView.m
//  weddingTime
//
//  Created by 默默 on 15/10/6.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "ChatMenuView.h"
#define selfTag  10109991
#define BtnWidth 92.f
@implementation ChatMenuView
{
    UIView *contentView;
    UIView *tapView;
    UIScrollView *mainScrollView;
    
    NSArray *buttonArray;
}

- (instancetype)init {
    if (self=[super init]) {
        self.frame = CGRectMake(0, 0, screenWidth,  [ChatMenuView getChatMenuViewHeight]);
        [self initView];
        self.backgroundColor=[UIColor clearColor];
        self.tag = selfTag;
        
    }
    return self;
}

- (void)initView {
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, [ChatMenuView getChatMenuViewHeight])];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.bottom=self.height;
    [self addSubview:contentView];
    
    mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, contentView.height)];
    mainScrollView.contentSize = CGSizeMake((WTChatMenuViewBtnTypeEnd+1)*BtnWidth, mainScrollView.contentSize.height);
    mainScrollView.scrollsToTop=NO;
    mainScrollView.pagingEnabled=YES;
    mainScrollView.bounces=YES;
    mainScrollView.showsHorizontalScrollIndicator=NO;
    [contentView addSubview:mainScrollView];

    for(int i=0;i<=WTChatMenuViewBtnTypeEnd;i++) {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(BtnWidth*i, 0, BtnWidth, [ChatMenuView getChatMenuViewHeight]);
       
        
        UILabel *titleBtn=[[UILabel alloc]initWithFrame:CGRectMake(0, 66, btn.width, 12)];
        [titleBtn setTextAlignment:NSTextAlignmentCenter];
        titleBtn.font=[WeddingTimeAppInfoManager fontWithSize:12];
        titleBtn.textColor=rgba(170, 170, 170, 1);
        switch (i) {
            case WTChatMenuViewBtnTypeTakePic:
            {
                [btn setImage:[UIImage imageNamed:@"chat_sendpic"] forState:UIControlStateNormal];
                [titleBtn setText:@"拍照片"];
            }
                break;
            case WTChatMenuViewBtnTypeChoosePic:
            {
                [btn setImage:[UIImage imageNamed:@"chat_choosepic"] forState:UIControlStateNormal];
                [titleBtn setText:@"发图片"];
            }
                break;
            case WTChatMenuViewBtnTypeKiss:
            {
                [btn setImage:[UIImage imageNamed:@"chat_kiss"] forState:UIControlStateNormal];
                [titleBtn setText:@"kiss"];
            }
                break;
            case WTChatMenuViewBtnTypePlan:
            {
                [btn setImage:[UIImage imageNamed:@"chat_plan"] forState:UIControlStateNormal];
                [titleBtn setText:@"创建计划"];
            }
                break;
            case WTChatMenuViewBtnTypeDraw:
            {
                [btn setImage:[UIImage imageNamed:@"chat_draw"] forState:UIControlStateNormal];
                [titleBtn setText:@"一起画"];
            }
                break;
            default:
                break;
        }
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0 ,0, 26, 0)];
        
        [btn addSubview:titleBtn];
        btn.tag=i;
        [btn addTarget:self action:@selector(sendImageBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
        [mainScrollView addSubview:btn];
    }
    
    UILabel *line=[[UILabel alloc]initWithFrame:CGRectMake(0,0, contentView.width, 0.5)];
    line.backgroundColor=[LWUtil colorWithHexString:@"#aaaaaa" alpha:0.5f];
    
    [contentView addSubview:line];
}



- (void)sendImageBtnEvent:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(ChatMenuViewDidTapBtn:)]) {
        [self.delegate ChatMenuViewDidTapBtn:sender.tag];
    }
}

- (void)show {
    if (contentView.bottom<self.height) {
        return;
    }
    [[_baseSuperView viewWithTag:selfTag] removeFromSuperview];
    [_baseSuperView addSubview:self];
    self.bottom=_baseSuperView.height;
    contentView.top=self.height;
    [UIView animateWithDuration:0.25f animations:^{
        contentView.bottom=self.height;
    }];
}

- (void)hide {
    if (contentView.top>=self.height) {
        return;
    }
    [UIView animateWithDuration:0.25f animations:^{
        contentView.top=self.height;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

+ (float)getChatMenuViewHeight {
    return 102;
}
@end
