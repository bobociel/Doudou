//
//  ChatFaceImageInputView.m
//  lovewith
//
//  Created by imqiuhang on 15/5/18.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "ChatFaceImageInputView.h"

#define selfTag  70738242
#define imageCount 16
#define gap 10.f

@implementation ChatFaceImageInputView
{
    UIView *contentView;
    UIView *tapView;
    UIScrollView *mainScrollView;
    UIPageControl *pageControl;
}

- (instancetype)init {
    if (self=[super init]) {
        self.frame = CGRectMake(0, 0, screenWidth,  [ChatFaceImageInputView getChatFaceImageInputViewHeight]);
        [self initView];
        self.backgroundColor=[UIColor clearColor];
        self.tag = selfTag;
        
    }
    return self;
}

- (void)initView {
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, [ChatFaceImageInputView getChatFaceImageInputViewHeight])];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.bottom=self.height;
    [self addSubview:contentView];
    
    mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, contentView.height-20)];
    mainScrollView.contentSize = CGSizeMake(screenWidth*2, mainScrollView.contentSize.height);
    
    mainScrollView.pagingEnabled=YES;
    mainScrollView.bounces=YES;
    mainScrollView.showsHorizontalScrollIndicator=NO;
    mainScrollView.delegate=self;
    [contentView addSubview:mainScrollView];
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    pageControl.numberOfPages = 2;
    pageControl.bottom = contentView.height-5;
    pageControl.tintColor = [WeddingTimeAppInfoManager instance].baseColor;
    pageControl.centerX =contentView.width/2.f;
    pageControl.currentPage=0;
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.pageIndicatorTintColor = titleLableColor;
    
    [contentView addSubview:pageControl];
    
    for(int j=0;j<2;j++) {
        UIView *imageContentView = [[UIView alloc] initWithFrame:CGRectMake(j*mainScrollView.width, 0, mainScrollView.width, mainScrollView.height)];
        [mainScrollView addSubview:imageContentView];
        for (int i=0; i<imageCount; i++) {
            float width = (mainScrollView.width-(5*gap))/4;
            UIButton *sendImageBtn = [[UIButton alloc] initWithFrame:CGRectMake((i%4+1)*gap+(i%4)*width, (i/4+1)*gap+(i/4)*width, width,width)];
            [sendImageBtn setImage:[UIImage imageNamed :[NSString stringWithFormat:@"f%i",i+j*8]] forState:UIControlStateNormal];
            [imageContentView addSubview:sendImageBtn];
            sendImageBtn.tag = i+j*8;
            [sendImageBtn addTarget:self action:@selector(sendImageBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    UILabel *line=[[UILabel alloc]initWithFrame:CGRectMake(0,0, contentView.width, 0.5)];
    line.backgroundColor=[LWUtil colorWithHexString:@"#aaaaaa" alpha:0.5f];
    
    [contentView addSubview:line];
}



- (void)sendImageBtnEvent:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(chatFaceImageInputViewdidSendImage:)]) {
        [self.delegate chatFaceImageInputViewdidSendImage:[NSString stringWithFormat:@"f%i",(int)sender.tag]];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    pageControl.currentPage = (int)(mainScrollView.contentOffset.x/screenWidth);
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

+ (float)getChatFaceImageInputViewHeight {
    return ((screenWidth-(5*gap))/4)*2+gap+20+20;
}

@end
