//
//  BanquetCollectionViewCell.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/28.
//  Copyright (c) 2015年 默默. All rights reserved.
//
#import <UIImageView+WebCache.h>
#import "BanquetCollectionViewCell.h"
#import "LWUtil.h"
#import "UIImage+YYAdd.h"
@interface BanquetCollectionViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation BanquetCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView
{
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, self.size.height)];
	_imageView.layer.cornerRadius = 7;
	_imageView.layer.masksToBounds = YES;
    [self.contentView addSubview:_imageView];

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, self.size.height - 30, self.size.width, 30)];
    _titleLabel.textColor = WHITE;
    _titleLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];
    [self.contentView addSubview:_titleLabel];

	UIImageView *dockImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.size.height - 30, self.size.width, 30)];
	dockImageView.image = [[UIImage imageWithColor:rgba(0, 0, 0, 0.1)] imageByBlurDark];
	[self.imageView addSubview:dockImageView];
}

- (void)setBallRoom:(WTHotelBallRoom *)ballRoom
{
	_ballRoom = ballRoom;
	self.titleLabel.text = _ballRoom.ballroom_name;
	[self.imageView mp_setImageWithURL:[NSString stringWithFormat:@"%@%@",_ballRoom.ballroom_pic,kSmall600]
					  placeholderImage:[UIImage imageNamed:@"defaultPic"]];
}

@end
