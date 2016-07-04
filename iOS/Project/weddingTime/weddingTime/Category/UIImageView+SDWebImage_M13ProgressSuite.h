//
//  UIImageView+SDWebImage_M13ProgressSuite.h
//  lovewith
//
//  Created by imqiuhang on 15/4/1.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "M13ProgressViewRing.h"

/********************************************************
 ****************** ------------*************************
 ******************|**在下载图片的时候显示进度条**|***********
 ****************** ------------*************************
 ********************************************************/


@interface UIImageView (SDWebImage_M13ProgressSuite)



//使用最简单的方式下载图片 没有默认图片 显示环形进度条
- (void)setImageUsingProgressViewRingWithURL:(NSURL *)url;
- (void)setImsgeUsingProgressViewRingWithURL:(NSURL *)url andBackColor:(UIColor *)color;
//使用默认图片下载,在下载结束前会显示默认图片 显示环形进度条
- (void)setImageUsingProgressViewRingWithURL:(NSURL *)url andPlaceholder:(UIImage *)placeholder;

- (void)setImageUsingProgressViewRingWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock ProgressPrimaryColor:(UIColor *)pColor ProgressSecondaryColor:(UIColor *)sColor Diameter:(float)diameter;
;
@end
