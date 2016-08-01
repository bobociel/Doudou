//
//  WTDemandCell.m
//  weddingTime
//
//  Created by wangxiaobo on 16/3/21.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTDemandCell.h"

@implementation WTDemandCell

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
		self.logoImageView = [UIImageView new];
		self.logoImageView.contentMode = UIViewContentModeCenter;
		[self.contentView addSubview:_logoImageView];
		[self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
			make.centerY.equalTo(self.mas_centerY).offset(0);
			make.left.mas_equalTo(15.0);
			make.size.mas_equalTo(CGSizeMake(56.0, 56.0));
		}];

		self.mainTitleLabel = [UILabel new];
		self.mainTitleLabel.font = DefaultFont20;
		self.mainTitleLabel.textColor = [UIColor blackColor];
		[self.contentView addSubview:_mainTitleLabel];
		[self.mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
			make.top.mas_equalTo(28.0);
			make.left.equalTo(_logoImageView.mas_right).offset(28.0);
			make.right.mas_equalTo(-28.0);
			make.height.mas_equalTo(20.0);
		}];

		self.subTtleLabel = [UILabel new];
		self.subTtleLabel.font = DefaultFont14;
		self.subTtleLabel.textColor = rgba(170, 170, 170, 1);
		[self.contentView addSubview:_subTtleLabel];
		[self.subTtleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(self.mainTitleLabel.mas_bottom).offset(10.0);
			make.left.equalTo(_logoImageView.mas_right).offset(28.0);
			make.right.mas_equalTo(-20.0);
			make.height.mas_equalTo(17.0);
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

- (void)setSupplier:(WTSupplier *)supplier
{
	_supplier = supplier;
	_mainTitleLabel.text = supplier.supplier_name;
	_subTtleLabel.text = [NSString stringWithFormat:@"作品%.0f·喜欢%.0f",supplier.likeCount,supplier.workCount];
	[_logoImageView setImageWithURL:[NSURL URLWithString:supplier.avatar]
						placeholder:[UIImage imageNamed:@"supplier"]];
}

@end
