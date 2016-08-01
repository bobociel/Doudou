//
//  WTTicket.m
//  weddingTime
//
//  Created by wangxiaobo on 16/5/10.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTTicket.h"

@implementation WTTicket
+ (NSDictionary *)modelCustomPropertyMapper{
	return @{@"ID":@"id",@"account":@"alipay_account"};
}

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

- (NSString *)state_name
{
	NSString *name = @"";
	if(_status == WTTicketStateNone){
		name = _has_obtain ? @"已领取" : @"马上领取" ;
	}
	if(_status == WTTicketStateNoUsed){
		name = @"等待使用";
	}else if (_status == WTTicketStateNoWithdraw){
		name = @"待提现";
	}else if (_status == WTTicketStateWithdraw){
		name = @"提现中";
	}else if (_status == WTTicketStateWithdrawing){
		name = @"提现中";
	}else if (_status == WTTicketStateWaitServer){
		name = @"提现中";
	}else if (_status == WTTicketStateWithdrew){
		name = @"提现成功";
	}
	return name;
}

- (UIColor *)ticketColor
{
	UIColor *ticketColor = WeddingTimeBaseColor;
	if(_amount.doubleValue <= 1000){
		ticketColor = rgba(255, 185, 209, 1);
	}else if (_amount.doubleValue > 1000 && _amount.doubleValue < 3000){
		ticketColor = rgba(255, 147, 184, 1);
	}
	else if (_amount.doubleValue >= 3000){
		ticketColor = rgba(255, 100, 153, 1);
	}
	return ticketColor;
}

@end
