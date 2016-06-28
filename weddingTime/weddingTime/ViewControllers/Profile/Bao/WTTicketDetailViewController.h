//
//  WTTicketDetailViewController.h
//  weddingTime
//
//  Created by wangxiaobo on 16/5/10.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "BaseViewController.h"
@interface WTTicketDetailViewController : BaseViewController
@property (nonatomic,copy) TicketUsedBlock    usedBlock;
@property (nonatomic,copy) TicketRefreshBlock refreshBlock;
+ (instancetype)instanceWithTicket:(WTTicket *)ticket;
+ (instancetype)instanceWithTicketID:(NSString *)ticketID;

- (void)setRefreshBlock:(TicketRefreshBlock)refreshBlock;
- (void)setUsedBlock:(TicketUsedBlock)usedBlock;
@end
