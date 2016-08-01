//
//  UIImageView+ModePlacehoder.m
//  weddingTime
//
//  Created by 默默 on 15/10/23.
//  Copyright © 2015年 默默. All rights reserved.
//

#import "UIImageView+ModePlacehoder.h"
#define rgba(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

@implementation UIImageView (ModePlacehoder)

- (void)mp_setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder
{
    [self mp_setImageWithURL:url placeholderImage:placeholder options:UIViewContentModeCenter backColor:rgba(241, 242, 244, 1) completed:nil];
}

- (void)mp_setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock
{
    [self mp_setImageWithURL:url placeholderImage:placeholder options:UIViewContentModeCenter backColor:rgba(241, 242, 244, 1) completed:completedBlock];
}

- (void)mp_setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder options:(UIViewContentMode)options backColor:(UIColor*)backColor completed:(SDWebImageCompletionBlock)completedBlock {
    UIViewContentMode realContentMode=self.contentMode;
    UIColor *realBackColor= self.backgroundColor;
    
    self.contentMode=options;
    self.backgroundColor=backColor;
    [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholder options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
			self.image = image;
            self.contentMode=realContentMode;
            self.backgroundColor=realBackColor;
        }
        if (completedBlock) {
            completedBlock(image,error,cacheType,imageURL);
        }
    }];
}
@end
