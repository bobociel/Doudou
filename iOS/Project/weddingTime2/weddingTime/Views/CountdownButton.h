//
//  CountdownButton.h
//  lovewith
//
//  Created by imqiuhang on 15/4/2.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CountdownButton : UIButton

/**
 *  倒计时过程中每秒的回调
 */
@property (nonatomic,assign)void(^countChangeBlock)(CountdownButton *btn, NSInteger totalTime,NSInteger leftTime);
/**
 *  结束后的回调
 */
@property (nonatomic,assign)void(^endBlock)(CountdownButton *btn);


/**
 *  开始倒计时
 *
 *  @param time 倒计时时间
 */
- (void)startCountDownWithTime:(NSInteger)time;

/**
 *  提前结束倒计时
 *
 *  @param needBlock 是否需要调起结束回调
 */
- (void)endCountDown:(BOOL)needBlock;

@end
