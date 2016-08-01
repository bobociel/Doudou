//
//  BlessCell.m
//  weddingTime
//
//  Created by jakf_17 on 15/12/8.
//  Copyright © 2015年 默默. All rights reserved.
//

#import "BlessCell.h"
#import <UIImageView+WebCache.h>

@implementation UITableView (blessCell)

- (BlessCell *)blessCell
{
    static NSString *CellIdentifier = @"blessCell";
    
    BlessCell * cell = (BlessCell *)[self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell = [[BlessCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    return cell;
}
@end

@interface BlessCell()

@property (nonatomic, strong) UIImageView *avatarImage;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *personCountLabel;
@end

@implementation BlessCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initView];
    }
    return self;
}
- (void)initView
{
    self.avatarImage = [UIImageView new];
    self.avatarImage.layer.cornerRadius = 30;
    self.avatarImage.layer.masksToBounds = YES;
    [self.contentView addSubview:_avatarImage];
    [_avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(30);
        make.left.mas_equalTo(18);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    self.titleLabel = [UILabel new];
    [self.contentView addSubview:_titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(31 );
        make.left.mas_equalTo(90 );
//        make.right.mas_equalTo(-10 );
		make.width.mas_equalTo(55);
        make.height.mas_equalTo(19);
    }];
    _titleLabel.textColor = rgba(102, 102, 102, 1);
    _titleLabel.font = [WeddingTimeAppInfoManager fontWithSize:18];

	self.personCountLabel = [UILabel new];
	[self.contentView addSubview:_personCountLabel];

	[_personCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.mas_equalTo(31 );
		make.left.mas_equalTo(150);
		make.right.mas_equalTo(-8 );
		make.height.mas_equalTo(19);
	}];
	_personCountLabel.textColor = rgba(102, 102, 102, 1);
	_personCountLabel.font = [WeddingTimeAppInfoManager fontWithSize:18];

    self.detailLabel = [UILabel new];
    [self.contentView addSubview:_detailLabel];
    _detailLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];
    _detailLabel.textColor = rgba(153, 153, 153, 1);
    _detailLabel.numberOfLines = 0;
    [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(30 );
        make.left.mas_equalTo(89 );
        make.right.mas_equalTo(-10 );
        make.bottom.mas_equalTo(-21 );
    }];
    
    UIImageView *levelImage = [[UIImageView alloc] initWithFrame:CGRectMake(10 , 122.5 - 1, screenWidth - 20 , 1)];
    levelImage.image = [LWUtil imageWithColor:[UIColor grayColor] frame:CGRectMake(0, 0, screenWidth, 0.2)];
    [self.contentView addSubview:levelImage];
}

- (void)setBless:(WTBless *)bless
{
	_bless = bless;
	[_avatarImage sd_setImageWithURL:[NSURL URLWithString:bless.bless_avatar] placeholderImage:[UIImage imageNamed:@"defaultPic"]];
	_titleLabel.text = bless.bless_name;
	_detailLabel.text = bless.bless;
	_personCountLabel.text =  [_bless.part_num integerValue] == 0 ? @"不参加" : [NSString stringWithFormat:@"%@人参加",bless.part_num] ;
}

@end
