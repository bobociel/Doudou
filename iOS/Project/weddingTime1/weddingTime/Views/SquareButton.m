//
//  SquareButton.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/17.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "SquareButton.h"

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
    
    self.numLabel = [[UILabel alloc] init];
    [self addSubview:_numLabel];
    _numLabel.textAlignment = NSTextAlignmentCenter;
    _numLabel.textColor = WHITE;
    _numLabel.font = [UIFont systemFontOfSize:37];
    _numLabel.size = CGSizeMake(screenWidth / 3.0, 51);
    _numLabel.centerX = self.bounds.size.width / 2.0;
    _numLabel.centerY = self.bounds.size.height / 2.0 + 5;
    _numLabel.text = @"0";
    
    self.nameLabel = [[UILabel alloc] init];
    [self addSubview:_nameLabel];
    _nameLabel.textColor = WHITE;
    _nameLabel.font = [UIFont systemFontOfSize:12];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.frame = CGRectMake(_numLabel.frame.origin.x - 2, _numLabel.frame.origin.y - 15, screenWidth / 3.0, 14);
    _nameLabel.textAlignment = NSTextAlignmentCenter;
}
@end
