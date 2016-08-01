//
//  WTTopView.h
//  weddingTime
//
//  Created by wangxiaobo on 16/3/11.
//  Copyright © 2016年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTSupplier.h"
#import "WTHotel.h"
@class WTTopView;
typedef NS_ENUM(NSInteger,WTTopViewType) {
	WTTopViewTypeBack,
	WTTopViewTypeLike,
	WTTopViewTypeShare,
    WTTopViewTypeFilter,
    WTTopViewTypeSearch,
	WTTopViewTypeCityFilter,
	WTTopViewTypeBigSearch,
	WTTopViewTypeSet,
	WTTopViewTypeChat,
	WTTopViewTypeSetBG
};

@protocol WTTopViewDelegate <NSObject>
@optional
- (void)topView:(WTTopView *)topView didSelectedBack:(UIControl *)backButton;
- (void)topView:(WTTopView *)topView didSelectedCityFilter:(UIControl *)likeButton;
- (void)topView:(WTTopView *)topView didSelectedFilter:(UIControl *)likeButton;
- (void)topView:(WTTopView *)topView didSelectedSearch:(UIControl *)likeButton;
- (void)topView:(WTTopView *)topView didSelectedLike:(UIControl *)likeButton;
- (void)topView:(WTTopView *)topView didSelectedShare:(UIControl *)shareButton;
- (void)topView:(WTTopView *)topView didSelectedSet:(UIControl *)setButton;
- (void)topView:(WTTopView *)topView didSelectedChat:(UIControl *)chatButton;
- (void)topView:(WTTopView *)topView didSelectedSetBG:(UIControl *)chatButton;
@end

@interface WTTopView : UIView
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;

@property (nonatomic, assign) double unreadCount;
@property (nonatomic, assign) BOOL is_like;
@property (nonatomic, copy) NSString *supplier_id;
@property (nonatomic, copy) NSString *hotel_id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *supplier_avatar;
@property (nonatomic,assign) id<WTTopViewDelegate> delegate;
+ (instancetype)topViewInView:(UIView *)superView withType:(NSArray *)type;
@end
