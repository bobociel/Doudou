//
//  WTTicketCell.h
//  weddingTime
//
//  Created by wangxiaobo on 16/4/11.
//  Copyright © 2016年 默默. All rights reserved.
//
#import "WTTicket.h"
#define kCellHeight 90.5
@interface WTTicketCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@property (weak, nonatomic) IBOutlet UIView *sBgView;
@property (weak, nonatomic) IBOutlet UILabel *sPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *sDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *sStateLabel;
@property (strong, nonatomic) WTTicket *ticket;
@property (strong, nonatomic) WTTicket *supplierTicket;
@end

@interface UITableView (WTTicketCell)
- (WTTicketCell *)WTTicketCell;
@end