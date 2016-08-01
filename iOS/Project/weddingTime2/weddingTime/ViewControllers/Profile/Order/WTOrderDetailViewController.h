//
//  OrderDetailViewController.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/9.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "WTSupplierBaseViewController.h"
typedef NS_OPTIONS(NSUInteger, OrderState) {
    orderstate_waitToGet = 1,
    orderstate_waitToPay,
    orderstate_hasPayed,
    orderstate_isrefunding_nok,
    orderstate_refundDone,
    orderstate_refundFailed,
    orderState_isrefunding_ok,
    OrderState_hasCancael
};

@protocol orderListRefresh <NSObject>

- (void)orderlistrefresh;

@end

@interface WTOrderDetailViewController : WTSupplierBaseViewController

@property (nonatomic, strong) NSString *order_id;
@property (nonatomic, assign) OrderState ordersate;
@property (nonatomic, strong) id<orderListRefresh> delegate;
@end
