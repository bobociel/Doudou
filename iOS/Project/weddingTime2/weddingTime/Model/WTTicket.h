//
//  WTTicket.h
//  weddingTime
//
//  Created by wangxiaobo on 16/5/10.
//  Copyright © 2016年 默默. All rights reserved.
//

typedef NS_ENUM(NSInteger,WTTicketState) {
	WTTicketStateNone,        //
	WTTicketStateNoUsed,      //等待使用
	WTTicketStateNoWithdraw,  //待提现
	WTTicketStateWithdraw,    //申请提现
	WTTicketStateWithdrawing, //提现中
	WTTicketStateWaitServer,  //商家确认
	WTTicketStateWithdrew     //提现成功
};

@interface WTTicket : NSObject
@property (nonatomic,copy) NSString *ID;        //用户持有优惠券ID
@property (nonatomic,copy) NSString *coupon_id; //商家的优惠券ID
@property (nonatomic,copy) NSString *supplier_user_id;
@property (nonatomic,assign) BOOL has_obtain;   
@property (nonatomic,assign) WTTicketState status;
@property (nonatomic,copy) NSString *company;
@property (nonatomic,copy) NSString *avatar;
@property (nonatomic,copy) NSString *amount;
@property (nonatomic,copy) NSString *desc;
@property (nonatomic,copy) NSString *expire_time;
@property (nonatomic,copy) NSString *alipay_account;

@property (nonatomic,copy) NSString *state_name;
@property (nonatomic,strong) UIColor *ticketColor;
@end
