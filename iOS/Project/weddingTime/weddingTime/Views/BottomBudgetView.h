//
//  BottomView.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/2.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#define kBottomViewHeight 60
@class BottomBudgetView;
@protocol BottomBudgetViewDelegate <NSObject>
- (void)bottomBudgetViewBudgetSelected;
@end

@interface BottomBudgetView : UIView
@property (nonatomic, weak) id<BottomBudgetViewDelegate> mainDelegate;
+ (instancetype)bootomViewInView:(UIView *)superView;
- (void)setCate:(WTWeddingType)cate;
@end
