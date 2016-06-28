//
//  WTWithdrawView.h
//  weddingTime
//
//  Created by wangxiaobo on 16/5/10.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTTicket.h"

@interface WTWithdrawView : UIView
@property (nonatomic,assign) WTTicketState state;
@property (nonatomic,strong) UIImageView *lImageView;
@property (nonatomic,strong) UILabel *lStateLabel;
@property (nonatomic,strong) UIImageView *cImageView;
@property (nonatomic,strong) UILabel *cStateLabel;
@property (nonatomic,strong) UIImageView *rImageView;
@property (nonatomic,strong) UILabel *rStateLabel;
@property (nonatomic,strong) UIImageView *leftLine;
@property (nonatomic,strong) UIImageView *rightLine;
@end
