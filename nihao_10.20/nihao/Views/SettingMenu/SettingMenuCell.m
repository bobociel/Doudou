//
//  SettingMenuCell.m
//  nihao
//
//  Created by 刘志 on 15/7/3.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "SettingMenuCell.h"

@implementation SettingMenuCell

- (void)awakeFromNib {
    // Initialization code
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(9, CGRectGetHeight(self.contentView.frame) - 0.5, 98, 0.5)];
    seperator.backgroundColor = ColorWithRGB(230, 230, 230);
    [self.contentView addSubview:seperator];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
