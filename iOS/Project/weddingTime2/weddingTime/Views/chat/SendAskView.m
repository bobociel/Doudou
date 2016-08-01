//
//  SendAskView.m
//  weddingTime
//
//  Created by jakf_17 on 15/12/9.
//  Copyright © 2015年 默默. All rights reserved.
//

#import "SendAskView.h"

@implementation SendAskView


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
	self.backgroundColor = WHITE;
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    self.avatar = [UIImageView new];
	_avatar.clipsToBounds = YES;
	_avatar.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_avatar];
	[_avatar mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.mas_equalTo(10.0);
		make.left.mas_equalTo(10.0);
		make.size.mas_equalTo(CGSizeMake(60, 60));
	}];

	self.sendButton = [UIButton new];
	[_sendButton setTitle:@"发送" forState:UIControlStateNormal];
	[_sendButton setTitleColor:WHITE forState:UIControlStateNormal];
	[_sendButton setBackgroundColor:WeddingTimeBaseColor];
	self.sendButton.layer.masksToBounds = YES;
	[self addSubview:_sendButton];

	[_sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.mas_equalTo(0);
		make.right.mas_equalTo(0);
		make.size.mas_equalTo(CGSizeMake(87,self.height));
	}];

    self.name = [UILabel new];
	_name.numberOfLines = 0;
	_name.font = DefaultFont14;
	_name.textColor = rgba(102, 102, 102, 1);
	_name.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_name];
	[_name mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.mas_equalTo(10.0);
		make.left.equalTo(_avatar.mas_right).offset(7.0);
		make.right.equalTo(_sendButton.mas_left).offset(-5.0);
		make.bottom.equalTo(self.mas_bottom).offset(-10.0);
		make.height.mas_greaterThanOrEqualTo(20.0);
	}];
}
@end
