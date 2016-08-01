//
//  CountdownButton.m
//  lovewith
//
//  Created by imqiuhang on 15/4/2.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "CountdownButton.h"

@implementation CountdownButton
{
    NSInteger totalTime;
    NSInteger curTime;
    BOOL stop;
}

- (void)startCountDownWithTime:(NSInteger)time {
    
    stop = NO;
    
    if (time ==0) {
        [self endCountDown:YES];
    }
    
    if (time<0) {
        return;
    }
    totalTime = time;
    curTime   = totalTime;
    
    if (self.countChangeBlock) {
        self.countChangeBlock(self,totalTime,curTime);
    }
    
    [self performSelector:@selector(countDown) withObject:nil afterDelay:1];
    
}

- (void)endCountDown:(BOOL)needBlock {
    totalTime=-1;
    stop = YES;
    if (needBlock) {
        if (self.endBlock) {
            self.endBlock(self);
        }
    }
}

- (void)countDown {
    if (stop) {
        return;
    }
    curTime --;
    if (curTime>0) {
        if (self.countChangeBlock) {
            self.countChangeBlock(self,totalTime,curTime);
        }
        [self performSelector:@selector(countDown) withObject:nil afterDelay:1];
    }else {
         self.endBlock(self);
    }
}

@end
