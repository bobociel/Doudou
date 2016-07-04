//
//  SquareButton.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/17.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "SquareButton.h"
#define kIconWidth  29.0
#define kCenterViewH 52.0
#define kFrameWidth   self.frame.size.width
#define kFrameHeight   self.frame.size.height
#define kCenterViewX ((kFrameWidth  - kIconWidth) / 2.0)
#define kCenterViewY ((kFrameHeight - kCenterViewH) / 2.0)
@implementation SquareButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
    }
    return self;
}


- (void)setUI
{
	_iconButton = [UIButton buttonWithType:UIButtonTypeSystem];
	_iconButton.frame = CGRectMake(kCenterViewX, kCenterViewY, kIconWidth, kIconWidth);
	_iconButton.tintColor = [UIColor whiteColor];
	_iconButton.userInteractionEnabled = NO;
	[self addSubview:_iconButton];

	self.badgeView = [_iconButton smallBadgeViewWithViewWidth:kIconWidth+5];
	_badgeView.frontView.hidden = YES;
	[_iconButton addSubview:_badgeView];

    self.nameLabel = [[UILabel alloc] init];
	_nameLabel.textColor = WHITE;
	_nameLabel.font = [UIFont systemFontOfSize:12];
	_nameLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_nameLabel];
    _nameLabel.frame = CGRectMake(0, kCenterViewY + kIconWidth + 8 , kFrameWidth , 14);

	_headLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kFrameWidth, 0.5)];
	_headLine.image = [UIImage imageWithColor:rgba(255, 255, 255, 0.4)];
	[self addSubview:_headLine];

	_leftLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0.5, kFrameHeight)];
	_leftLine.image = [UIImage imageWithColor:rgba(255, 255, 255, 0.4)];
	[self addSubview:_leftLine];

	_rightLine = [[UIImageView alloc] initWithFrame:CGRectMake(kFrameWidth - 0.5, 0, 0.5,kFrameHeight)];
	_rightLine.image = [UIImage imageWithColor:rgba(255, 255, 255, 0.4)];
	[self addSubview:_rightLine];

}
@end
