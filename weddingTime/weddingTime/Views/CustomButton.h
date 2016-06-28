//
//  CustomButton.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/9.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomButton : UIButton

@property (nonatomic, strong) UIImageView *promptImage;
@property (nonatomic, strong) UILabel *prompLabel;


- (void)setImage:(UIImage *)image text:(NSString *)text;
@end
