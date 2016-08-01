//
//  BaseViewController.h
//  weddingTime
//
//  Created by 默默 on 15/9/8.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QHNavigationController.h"
#import "MBProgressHUD.h"
#import "LoginManager.h"
#import "WTTicket.h"
#define kNavBarHeight 64.0
#define kTabBarHeight 50.0
typedef void(^WTLikeBlock)(BOOL isLike);
typedef void(^WTRefreshBlock)(BOOL refresh);
typedef void(^TicketUsedBlock)(WTTicket *ticket);
typedef void(^TicketRefreshBlock)(WTTicket *ticket);

typedef NS_ENUM(NSInteger,WTWeddingType) {
    WTWeddingTypePlan        = 6,   // 6    婚礼策划
    WTWeddingTypeCapture     = 7,   // 7    婚礼跟拍
    WTWeddingTypeMakeUp      = 8,   // 8    化妆造型
    WTWeddingTypeDress       = 9,   // 9	婚纱礼服
    WTWeddingTypePhoto       = 11,  // 11	婚纱写真
    WTWeddingTypeVideo       = 12,  // 12	婚礼摄像
    WTWeddingTypeHost        = 14,  // 14	婚礼主持
    WTWeddingTypeHotel       = 22,  // 22   婚礼酒店
    WTWeddingTypeInspiration = 23,  // 23   婚礼灵感

	WTWeddingTypeShopMain    = 888  // 888  新娘商店精选 (客户端自定义)
};

typedef NS_ENUM(NSInteger, WTConversationType) {
	WTConversationTypePartner  = 0,
	WTConversationTypeSupplier = 1,
	WTConversationTypeHotelOrCustomer    = 2,

	WTConversationTypePost     = 3 //自己使用
};

typedef NS_ENUM(NSInteger,WTSupplierLevel) {
	WTSupplierLevelV0 = 0,  //未合作商家
	WTSupplierLevelV  = 1,  //小编
	WTSupplierLevelV1,      //合作商家
	WTSupplierLevelV2,      //认证商家
	WTSupplierLevelV3       //品牌商家
};

typedef NS_ENUM(NSInteger,WTSegmentType) {
	WTSegmentTypePost,
	WTSegmentTypeSupplier
};

typedef NS_ENUM(NSInteger,WTLogType) {
	WTLogTypeNone = 0,
	WTLogTypeSupplier = 1,
	WTLogTypePost = 2,
	WTLogTypeADs  = 3
};

//    10	花艺设计
//    13	婚戒珠宝
//    15	婚礼场地
//    16	蛋糕甜品
//    17	定制商品
//    19	蜜月旅行
//    20	婚房家居
//    21	其他

@interface BaseViewController : UIViewController
{
    id            data;
    MBProgressHUD *loadingHUD;
    LoginManager  *loginManager;
}

@property (nonatomic,strong) MBProgressHUD *loadingHUD;
@property (nonatomic,strong) UIImageView *blurImageView;
@property (nonatomic,strong) UIImageView *dimingImageView;
//请求完成后的数据源
@property (nonatomic,retain)id data;

//如果需要用到tableView
@property (nonatomic,strong)UITableView *dataTableView;

//请求数据,请在子类里面处理 无需调用super
- (void)loadData;

//重新请求数据,请在子类里面处理 无需调用super
- (void)reloadData;

- (void)cleanData;

- (void)setDataTableViewAsDefault:(CGRect)frame;
//返回
- (void)back;

-(void)setNavWithClearColor;

/**
 如果需要隐藏，需要重写这个方法加入[self.navigationController setNavigationBarHidden:YES animated:YES];
 */
-(void)setNavWithHidden;

- (void)rightNavBtnEvent;

- (void)setRightBtnWithTitle:(NSString *)aTitle;

- (void)setRightBtnWithTitle:(NSString *)aTitle andColor:(UIColor *)color;

- (void)setRightBtnWithImage:(UIImage *)aImage ;

- (void)showLoadingViewTitle:(NSString*)title;
- (void)showLoadingView;
- (void)hideLoadingView;
- (void)hideLoadingViewAfterDelay:(CGFloat)time;

- (void)showLoadingView:(UIView *)aView;
- (void)showLoadingView:(UIView *)aView top:(CGFloat)top;

-(void)showBlurBackgroundView;
- (void)setBlurImageViewWithImage:(UIImage *)image state:(float)state;
//- (void)setRightBtnWithTitle:(NSString *)aTitle andColor:(UIColor *)color;

- (void)addTapButton;
- (void)addTapButtonPink;
- (void)addTapButtonWhite;
//- (void)hideBackButton;
//- (void)showBackButton;
@end
