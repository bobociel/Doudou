//
//  CircleImage.m
//  EasyCar
//
//  Created by jakf_17 on 15/9/16.
//  Copyright (c) 2015年 jakf_17. All rights reserved.
//

#import "CircleImage.h"

@implementation CircleImage


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
    self.backgroundColor = [UIColor clearColor];
    self.centerImage = [[UIImageView alloc] init];
    [self addSubview:_centerImage];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.layer.cornerRadius = self.bounds.size.width / 2.0;
    self.centerImage.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height );
    self.centerImage.layer.cornerRadius = self.centerImage.bounds.size.width / 2.0;
    self.centerImage.layer.masksToBounds = YES;
    _centerImage.layer.borderColor = [UIColor whiteColor].CGColor;
    _centerImage.layer.borderWidth = 3;
    _centerImage.contentMode = UIViewContentModeScaleToFill;
}
@end
