//
//  UITabBar+badge.m
//  nihao
//
//  Created by 刘志 on 15/9/1.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "UITabBar+badge.h"

@implementation UITabBar (badge)

static const NSUInteger BADGE_TAG = 888;

- (void) showBadgeAtIndex:(NSUInteger)index {
    [self removeBadgeAtIndex:index];
    UIView *badge = [[UIView alloc] init];
    badge.tag = BADGE_TAG + index;
    badge.layer.cornerRadius = 4;
    badge.backgroundColor = [UIColor redColor];
    CGRect tabFrame = self.frame;
    //确定小红点的位置
    float percentX = (index + 0.65) / self.items.count;
    CGFloat x = ceilf(percentX * tabFrame.size.width);
    CGFloat y = ceilf(0.1 * tabFrame.size.height);
    //圆形大小为10
    badge.frame = CGRectMake(x, y, 8, 8);
    [self addSubview:badge];
}

- (void) hideBadgeAtIndex:(NSUInteger)index {
    [self removeBadgeAtIndex:index];
}

- (void) removeBadgeAtIndex : (NSUInteger) index {
    for(UIView *subView in self.subviews) {
        if(subView.tag == (index + BADGE_TAG)) {
            [subView removeFromSuperview];
            break;
        }
    }
}

@end
