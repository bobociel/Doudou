//
//  HYSegmentedControl.h
//  CustomSegControlView
//
//  Created by sxzw on 14-6-12.
//  Copyright (c) 2014年 sxzw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HYSegmentedControl;

@protocol HYSegmentedControlDataSource <NSObject>
@required
- (NSArray*) titlesForSegmentControl:(HYSegmentedControl*)segmentControl;
@end

@protocol HYSegmentedControlDelegate <NSObject>

@required
//代理函数 获取当前下标
- (void)hySegmentedControlSelectAtIndex:(NSInteger)index;

@end

@interface HYSegmentedControl : UIView

@property (assign, nonatomic) IBOutlet id<HYSegmentedControlDelegate>delegate;
@property (assign, nonatomic) IBOutlet id<HYSegmentedControlDataSource>dataSource;
@property (nonatomic, readonly) int curIndex;

//初始化函数 
//- (id)initWithOriginY:(CGFloat)y Titles:(NSArray *)titles delegate:(id)delegate;
//提供方法改变 index
- (void)changeSegmentedControlWithIndex:(NSInteger)index;

- (void) doInit;
//- (void) reloadData;

@end
