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
    [self.contentView addSubview:_imageView];
    _imageView.layer.cornerRadius = 7;
    _imageView.layer.masksToBounds = YES;
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, self.size.height - 30, self.size.width, 30)];
    _titleLabel.textColor = WHITE;
    
    _titleLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];
    [self.contentView addSubview:_titleLabel];

	UIImage *dockImage = [[UIImage imageWithColor:rgba(0, 0, 0, 0.1)] imageByBlurDark];

	UIImageView *dockImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.size.height - 30, self.size.width, 30)];
	dockImageView.image = dockImage;
	[self.imageView addSubview:dockImageView];
}

- (void)setInfo:(id)info
{
    self.titleLabel.text = [LWUtil getString:info[@"ballroom_name"] andDefaultStr:@""];
    [self.imageView mp_setImageWithURL:[LWUtil getString:info[@"ballroom_pic"] andDefaultStr:@""]  placeholderImage:[UIImage imageNamed:@"defaultPic"]];
}
@end
