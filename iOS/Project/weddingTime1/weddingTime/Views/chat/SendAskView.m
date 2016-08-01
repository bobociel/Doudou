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
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    self.backgroundColor = WHITE;
    self.avatar = [UIImageView new];
    [self addSubview:_avatar];
    _avatar.left = 10;
    _avatar.top = 10;
    _avatar.height = 60;
    _avatar.width = 60;
    
    self.name = [UILabel new];
    [self addSubview:_name];
    _name.left = 77;
    _name.top = 30;
    _name.width = self.width - 77 - 97 ;
    _name.height = 20;
    _name.textColor = rgba(102, 102, 102, 1);
    _name.textAlignment = NSTextAlignmentCenter;
    
    self.sendButton = [UIButton new];
    [self addSubview:_sendButton];
    [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [_sendButton setTitleColor:WHITE forState:UIControlStateNormal];
    [_sendButton setBackgroundColor:WeddingTimeBaseColor];
    self.sendButton.layer.masksToBounds = YES;
    _sendButton.left = self.width - 87;
    _sendButton.top = 0;
    _sendButton.width = 87;
    _sendButton.height = self.height;
    
}
@end
