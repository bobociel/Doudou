//
//  SettingMenu.h
//  nihao
//
//  Created by 刘志 on 15/7/3.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingMenuDelegate <UITableViewDataSource,UITableViewDelegate>

@end

@interface SettingMenu : UIView

- (void) setData : (NSArray *) data;

- (void) showInView : (UIView *) view;

- (void) dismiss;

@property (nonatomic, copy) void(^menuClickAtIndex)(NSInteger item);
@property (nonatomic, copy) void(^menuDismissed)();

@end
