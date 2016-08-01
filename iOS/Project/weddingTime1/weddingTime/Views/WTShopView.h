//
//  WTShopView.h
//  weddingTime
//
//  Created by wangxiaobo on 16/3/11.
//  Copyright © 2016年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WTShopView;
@protocol WTShopViewDelegate <NSObject>
- (void)shopView:(WTShopView *)shopView didSelectedBuy:(UIControl *)control;
@end

@interface WTShopView : UIView
@property (nonatomic, assign) double price;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (nonatomic,assign) id < WTShopViewDelegate> delegate;
+ (instancetype)shopView:(UIView *)superView;
@end
