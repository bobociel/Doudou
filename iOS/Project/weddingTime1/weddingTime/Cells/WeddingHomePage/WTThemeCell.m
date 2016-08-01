//
//  WTThemeCell.m
//  weddingTime
//
//  Created by wangxiaobo on 12/19/15.
//  Copyright © 2015 默默. All rights reserved.
//

#import "WTThemeCell.h"

@implementation WTThemeCell

- (void)awakeFromNib {
    // Initialization code
	self.imageView.backgroundColor = rgba(221, 221, 221, 1);
	self.imageView.layer.masksToBounds = YES;
	self.imageView.layer.cornerRadius = 5.0;
//	self.imageView.layer.shadowRadius = 5.0;
//	self.imageView.layer.shadowOffset = CGSizeMake(1, 1);
//	self.imageView.layer.shadowColor = [UIColor blackColor].CGColor;
}

@end
