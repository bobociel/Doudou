//
//  BottomSupplierView.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/2.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTSupplier.h"
#import "WTHotel.h"
#define kBottomViewHeight 60
@class BottomSupplierViewDelegate;
@protocol BottomSupplierViewDelegate <NSObject>
- (void)bottomSupplierViewConversationSelected;
- (void)bottomSupplierViewCheckSelectedWithDateString:(NSString *)str;
- (void)bottomSupplierViewBaoSelected;
@end

@interface BottomSupplierView : UIView
@property (nonatomic, copy) NSString *supplier_name;
@property (nonatomic, copy) NSString *supplier_avatar;
@property (nonatomic, copy) NSString *tel_num;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *priceLabelTop;
@property (nonatomic, weak) id<BottomSupplierViewDelegate> mainDelegate;
+ (instancetype)bootomViewInView:(UIView *)superView;
- (void)setMinPrice:(NSString *)minPrice andMaxPrice:(NSString *)maxPrice;
@end
