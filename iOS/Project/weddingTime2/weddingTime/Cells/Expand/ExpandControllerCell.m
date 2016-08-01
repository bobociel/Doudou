//
//  ExpandControllerCell.m
//  weddingTime
//
//  Created by 默默 on 15/9/19.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "ExpandControllerCell.h"
@implementation UITableView(ExpandControllerCell)
-(ExpandControllerCell*)ExpandControllerCell{
	static NSString *CellIdentifier = @"ExpandControllerCell";
	ExpandControllerCell *cell = (ExpandControllerCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
	if (nil == cell) {
		cell = [(ExpandControllerCell *)[ExpandControllerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.backgroundColor = [UIColor clearColor];
		cell.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-1)];
		cell.selectedBackgroundView.backgroundColor = [WeddingTimeAppInfoManager instance].baseColor;
	}

	return cell;
}

@end
@implementation ExpandControllerCell

- (void)awakeFromNib {
	// Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if(self)
	{
		self.logoImageView = [UIImageView new];
		self.logoImageView.contentMode = UIViewContentModeCenter;
		[self.contentView addSubview:_logoImageView];
		[self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
			make.centerY.equalTo(self.mas_centerY).offset(0);
			make.left.mas_equalTo(38.0);
			make.size.mas_equalTo(CGSizeMake(32.0, 32.0));
		}];

		self.mainTitleLabel = [UILabel new];
		self.mainTitleLabel.font = DefaultFont20;
		self.mainTitleLabel.textColor = WHITE;
		[self.contentView addSubview:_mainTitleLabel];
		[self.mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
			make.top.mas_equalTo(30.0);
			make.left.mas_equalTo(110.0);
			make.right.mas_equalTo(-30.0);
			make.height.mas_equalTo(24.0);
		}];

		self.subTtleLabel = [UILabel new];
		self.subTtleLabel.numberOfLines = 0;
		self.subTtleLabel.font = DefaultFont12;
		self.subTtleLabel.textColor = WHITE;
		[self.contentView addSubview:_subTtleLabel];
		[self.subTtleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
			make.top.mas_equalTo(_mainTitleLabel.mas_bottom).offset(12.0);
			make.left.mas_equalTo(110.0);
			make.right.mas_equalTo(-38.0);
			make.height.mas_greaterThanOrEqualTo(16.0);
		}];

		UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CellHeight-0.5, screenWidth, 0.5)];
		lineView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
		[self addSubview:lineView];
	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];

	// Configure the view for the selected state
}

-(CGFloat)getHeightWithInfo:(id)info
{
	return CellHeight;
}

-(void)setInfo:(id)info
{
	NSDictionary*infoDic=info;
	self.mainTitleLabel.text=[LWUtil getString: infoDic[@"title"]  andDefaultStr:@""];
	self.subTtleLabel.text=[LWUtil getString:infoDic[@"subTitle"] andDefaultStr:@""];
	self.logoImageView.image=[UIImage imageNamed:[LWUtil getString:infoDic[@"image"] andDefaultStr:@""]];
}

@end

