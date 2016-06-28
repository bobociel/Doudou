//
//  UIImageView+ModePlacehoder.h
//  weddingTime
//
//  Created by 默默 on 15/10/23.
//  Copyright © 2015年 默默. All rights reserved.
//

#import "UIImageView+WebCache.h"
@interface UIImageView (ModePlacehoder)
- (void)mp_setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder;

- (void)mp_setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock;

- (void)mp_setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder options:(UIViewContentMode)options backColor:(UIColor*)backColor completed:(SDWebImageCompletionBlock)completedBlock;
@end
