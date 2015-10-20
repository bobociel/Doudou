//
//  UITabBar+badge.h
//  nihao
//
//  Created by 刘志 on 15/9/1.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (badge)

- (void) showBadgeAtIndex : (NSUInteger) index;

- (void) hideBadgeAtIndex : (NSUInteger) index;

@end
