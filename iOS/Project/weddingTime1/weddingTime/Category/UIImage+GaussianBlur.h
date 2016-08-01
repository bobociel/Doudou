//
//  UIImage+GaussianBlur.h
//  图像模糊
//
//  Created by liuchang on 15/1/4.
//  Copyright (c) 2015年 liuchang. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIImage (GaussianBlur)

+ (UIImage *)imageWithBlurImage:(const UIImage *)theImage intputRadius:(const CGFloat)radius;
+ (UIImage *)blurryImage:(const UIImage *)image withBlurLevel:(CGFloat)blur;
@end
