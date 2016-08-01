//
//  WTDemandListCell.m
//  weddingTime
//
//  Created by wangxiaobo on 16/3/21.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTDemandListCell.h"

@implementation WTDemandListCell

- (void)awakeFromNib {
	// Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];

	// Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if(self)
	{
		self.mainTitleLabel = [UILabel new];
		self.mainTitleLabel.font = DefaultFont20;
		self.mainTitleLabel.textColor = [UIColor blackColor];
		[self.contentView addSubview:_mainTitleLabel];
		[self.mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
			make.top.mas_equalTo(30.0);
			make.left.mas_equalTo(15.0);
			make.width.mas_equalTo(100.0);
			make.height.mas_equalTo(21.0);
		}];

		self.statusLabel = [UILabel new];
		self.statusLabel.font = DefaultFont16;
		self.statusLabel.textColor = rgba(185, 185, 185, 1);
		self.statusLabel.textAlignment = NSTextAlignmentRight;
		[self.contentView addSubview:_statusLabel];
		[self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
			make.top.mas_equalTo(28.0);
			make.left.equalTo(self.mainTitleLabel.mas_right).offset(10.0);
			make.right.mas_equalTo(-15.0);
		}];

		self.subTtleLabel = [UILabel new];
		self.subTtleLabel.numberOfLines = 0;
		self.subTtleLabel.font = DefaultFont14;
		self.subTtleLabel.textColor = rgba(170, 170, 170, 1);
		[self.contentView addSubview:_subTtleLabel];
		[self.subTtleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(self.mainTitleLabel.mas_bottom).offset(17.0);
			make.left.mas_equalTo(15.0);
			make.right.mas_equalTo(-15.0);
			make.height.mas_equalTo(20.0);
		}];

		UIImageView *lineView = [UIImageView new];
		lineView.image = [UIImage imageWithColor:rgba(220, 220, 220, 1)];
		[self.contentView addSubview:lineView];
		[lineView mas_makeConstraints:^(MASConstraintMaker *make) {
			make.left.mas_equalTo(15.0);
			make.bottom.equalTo(self.mas_bottom).offset(0.0);
			make.size.mas_equalTo(CGSizeMake(screenWidth - 15.0, 0.5));
		}];
	}
	return self;
}

- (void)setDemand:(WTDemand *)demand
{
	_demand = demand;
	_mainTitleLabel.text = demand.service_name;
	_subTtleLabel.attributedText = [LWUtil attributeStringWithPriceRange:demand.price_range_content];
	_statusLabel.text = demand.bid_num == 0 ? @"等待商家" : [NSString stringWithFormat:@"%.0f个商家沟通中",demand.bid_num];
}

@end
