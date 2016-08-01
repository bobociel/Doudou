//
//  WTWithdrawView.m
//  weddingTime
//
//  Created by wangxiaobo on 16/5/10.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTWithdrawView.h"
#define kLeftGap 60
#define kHeight 17
#define kLineViewWidth ((screenWidth - kLeftGap*2 - kHeight*3) / 2)
@implementation WTWithdrawView

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self)
	{
		[self initView];
	}
	return self;
}

- (void)initView
{
	self.backgroundColor = WeddingTimeBaseColor;

	self.lImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kLeftGap, 0, kHeight, kHeight)];
	self.lImageView.image = [UIImage imageNamed:@"icon_bao_dot"];
	self.lImageView.highlightedImage = [UIImage imageNamed:@"icon_bao_dot_h"];
	[self addSubview:self.lImageView];

	self.lStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _lImageView.bottom+10, 60, kHeight)];
	self.lStateLabel.centerX = self.lImageView.centerX;
	self.lStateLabel.font = DefaultFont14;
	self.lStateLabel.textColor = [UIColor colorWithWhite:1 alpha:0.5];
	[self addSubview:self.lStateLabel];

	self.cImageView = [[UIImageView alloc] initWithFrame:CGRectMake((screenWidth-kHeight)/2, 0, kHeight, kHeight)];
	self.cImageView.image = [UIImage imageNamed:@"icon_bao_dot"];
	self.cImageView.highlightedImage = [UIImage imageNamed:@"icon_bao_dot_h"];
	[self addSubview:self.cImageView];

	self.cStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _cImageView.bottom+10, 100, kHeight)];
	self.cStateLabel.centerX = self.cImageView.centerX;
	self.cStateLabel.font = DefaultFont14;
	self.cStateLabel.textColor = [UIColor colorWithWhite:1 alpha:0.5];
	[self addSubview:self.cStateLabel];

	self.rImageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-kLeftGap-kHeight, 0, kHeight, kHeight)];
	self.rImageView.image = [UIImage imageNamed:@"icon_bao_dot"];
	self.rImageView.highlightedImage = [UIImage imageNamed:@"icon_bao_dot_h"];
	[self addSubview:self.rImageView];

	self.rStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _rImageView.bottom+10, 60, kHeight)];
	self.rStateLabel.centerX = self.rImageView.centerX;
	self.rStateLabel.font = DefaultFont14;
	self.rStateLabel.textColor = [UIColor colorWithWhite:1 alpha:0.5];
	[self addSubview:self.rStateLabel];

	self.leftLine = [[UIImageView alloc] initWithFrame:CGRectMake(_lImageView.right, _lImageView.centerY, kLineViewWidth, 1)];
	self.leftLine.image = [UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:0.5]];
	self.leftLine.highlightedImage = [UIImage imageWithColor:WHITE];
	[self addSubview:self.leftLine];

	self.rightLine = [[UIImageView alloc] initWithFrame:CGRectMake(_cImageView.right, _lImageView.centerY, kLineViewWidth, 1)];
	self.rightLine.image = [UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:0.5]];
	self.rightLine.highlightedImage = [UIImage imageWithColor:WHITE];
	[self addSubview:self.rightLine];

	self.lStateLabel.text = @"申请提现";
	self.cStateLabel.text = @"商家服务完成";
	self.rStateLabel.text = @"提现成功";
}

- (void)setState:(WTTicketState)state
{
	_state = state;

	if(_state == WTTicketStateWithdraw || _state == WTTicketStateWithdrawing)
	{
		_lImageView.highlighted = YES;
		_lStateLabel.textColor = WHITE;
	}
	else if(_state == WTTicketStateWaitServer)
	{
		_lImageView.highlighted = YES;
		_lStateLabel.textColor = WHITE;
		_cImageView.highlighted = YES;
		_cStateLabel.textColor = WHITE;
		_leftLine.highlighted = YES;
	}
	else if(_state == WTTicketStateWithdrew)
	{
		_lImageView.highlighted = YES;
		_lStateLabel.textColor = WHITE;
		_cImageView.highlighted = YES;
		_cStateLabel.textColor = WHITE;
		_rImageView.highlighted = YES;
		_rStateLabel.textColor = WHITE;
		_leftLine.highlighted = YES;
		_rightLine.highlighted = YES;
	}
}

@end
