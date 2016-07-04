//
//  NetWorkingFailDoErr.m
//  weddingTime
//
//  Created by 默默 on 15/9/24.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "NetWorkingFailDoErr.h"
#import "QHNavigationController.h"
#import "LoginManager.h"

@implementation NetWorkingFailDoErr

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(void)awakeFromNib
{
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchEvent)]];
}

-(void)touchEvent
{
    if(self.touchBlock)
        self.touchBlock();
}

+(void)errWithView:(UIView*)view content:(NSString*)content tapBlock:(NetWorkingFailDoErrTouchBlock)block
{
    [self errWithView:view frame:view.bounds backColor:nil font:nil textColor:nil content:content tapBlock:block];
}

+(void)errWithView:(UIView*)view frame:(CGRect)frame backColor:(UIColor*)backColor font:(UIFont*)textFont textColor:(UIColor*)textColor content:(NSString*)content tapBlock:(NetWorkingFailDoErrTouchBlock)block
{
    NetWorkingFailDoErr *errView= (NetWorkingFailDoErr*)([[NSBundle mainBundle] loadNibNamed:@"NetWorkingFailDoErr" owner:nil options:nil][0]);
    errView.contentLabel.text=content;
    errView.frame=frame;
    if (backColor) {
        errView.backgroundColor=backColor;
    }
    if (textFont) {
        errView.contentLabel.font=textFont;
    }
    if (textColor) {
	errView.contentLabel.textColor= textColor;
    }
    errView.touchBlock=block;
    [view addSubview:errView];
}

+(void)errSearchWithView:(UIView*)view content:(NSString*)content tapBlock:(NetWorkingFailDoErrTouchBlock)block
{
    NetWorkingFailDoErr *errView= (NetWorkingFailDoErr*)([[NSBundle mainBundle] loadNibNamed:@"NetWorkingFailDoErr" owner:nil options:nil][0]);
    errView.contentLabel.text=content;
    errView.frame=view.bounds;
    errView.touchBlock=block;
    [view addSubview:errView];
}

+(void)removeAllErrorViewAtView:(UIView*)view
{
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:self]) {
            [subview removeFromSuperview];
        }
    }
}
@end
