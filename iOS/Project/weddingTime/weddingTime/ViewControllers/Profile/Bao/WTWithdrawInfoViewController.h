//
//  WTWithdrawInfoViewController.h
//  weddingTime
//
//  Created by wangxiaobo on 16/5/10.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "BaseViewController.h"
@interface WTWithdrawInfoViewController : BaseViewController
@property(nonatomic,copy)TicketRefreshBlock block;
+ (instancetype)instanceWithTicket:(WTTicket *)ticket;
- (void)setBlock:(TicketRefreshBlock)block;
@end
