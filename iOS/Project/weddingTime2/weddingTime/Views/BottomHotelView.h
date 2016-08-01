//
//  BottomView.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/2.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTSupplier.h"
#import "WTHotel.h"
#define kBottomViewHeight 60
@class BottomHotelView;
@protocol BottomHotelViewDelegate <NSObject>
@optional
- (void)bottomHotelViewConversationSelected;
- (void)bottomHotelViewCheckSelectedWithDateString:(NSString *)str;
@end

@interface BottomHotelView : UIView
@property (nonatomic, copy) NSString *supplier_name;
@property (nonatomic, copy) NSString *supplier_avatar;
@property (nonatomic, copy) NSString *tel_num;
@property (nonatomic, weak) id<BottomHotelViewDelegate> mainDelegate;
+ (instancetype)bootomViewInView:(UIView *)superView;
@end
