//
//  CustomButton.m
//  weddingTime
//
//  Created by jakf_17 on 15/10/9.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import "CustomButton.h"

@implementation CustomButton
{
    CGRect rect;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        rect = frame;
    }
    return self;
}

- (void)initView
{
    self.layer.cornerRadius = 43 * Height_ato / 2.0;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth  = 0.5;
    self.promptImage = [[UIImageView alloc] initWithFrame:CGRectMake(16.57 * Width_ato, 11.76 * Height_ato, 19.5 * Width_ato, 19.5 * Width_ato)];
    [self addSubview:_promptImage];
}

- (void)setImage:(UIImage *)image text:(NSString *)text
{
    self.titleLabel.frame = CGRectMake(45 * Width_ato, 12 * Height_ato, 72 * Width_ato, 18 * Height_ato);
    [self setTitle:text forState:UIControlStateNormal];
    [self setTitleColor:LightGragyColor forState:UIControlStateNormal];
    [self setTitleColor:WeddingTimeBaseColor forState:UIControlStateHighlighted];
    self.titleLabel.font = [WeddingTimeAppInfoManager fontWithSize:15];
    [self setBackgroundImage:[LWUtil imageWithColor:WeddingTimeBaseColor frame:rect] forState:UIControlStateHighlighted];
    
    _promptImage.image = image;
//    _prompLabel.text = text;
    [self setImage:[LWUtil imageWithColor:WHITE frame:CGRectMake(16, 11, 20, 20)] forState:UIControlStateNormal];
    [self setImage:[LWUtil imageWithColor:WHITE frame:CGRectMake(16, 11, 20, 20)] forState:UIControlStateHighlighted];
}

@end
