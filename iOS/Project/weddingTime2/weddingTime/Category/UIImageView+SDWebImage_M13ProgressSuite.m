//
//  UIImageView+SDWebImage_M13ProgressSuite.m
//  lovewith
//
//  Created by imqiuhang on 15/4/1.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "UIImageView+SDWebImage_M13ProgressSuite.h"
#import "LWUtil.h"
#define TAG_PROGRESS_VIEW_RING 258369
#define kRingWidth 3.0f
#define kBGRingWidth 3.0f

@implementation UIImageView (SDWebImage_M13ProgressSuite)
#pragma mark- Private Methods
- (void)addProgressViewRingWithPrimaryColor:(UIColor *)pColor SecondaryColor:(UIColor *)sColor Diameter:(float)diameter {
    self.autoresizesSubviews=YES;
   [self removeProgressViewRing];
   M13ProgressViewRing * progressView = [[M13ProgressViewRing alloc] initWithFrame:CGRectMake(0,0, diameter, diameter)];
	progressView.progressRingWidth = kRingWidth;
	progressView.backgroundRingWidth = kBGRingWidth;
    progressView.autoresizingMask=UIViewAutoresizingNone;
    progressView.primaryColor = pColor;
    progressView.secondaryColor = sColor;
    progressView.showPercentage=NO;
    progressView.center=CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    progressView.tag = TAG_PROGRESS_VIEW_RING;
    [self insertSubview:progressView atIndex:0];
}

- (void)updateProgressViewRing:(CGFloat)progress {
    M13ProgressViewRing *progressView = (M13ProgressViewRing *)[self viewWithTag:TAG_PROGRESS_VIEW_RING];
    if (progressView) {
        progressView.center=CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        [progressView setProgress:progress animated:YES];
    }
}

- (void)removeProgressViewRing {
    M13ProgressViewRing *progressView = (M13ProgressViewRing *)[self viewWithTag:TAG_PROGRESS_VIEW_RING];
    if (progressView) {
        [progressView removeFromSuperview];
    }
}

#pragma mark- Public Methods
- (void)setImageUsingProgressViewRingWithURL:(NSURL *)url {
    [self setImageUsingProgressViewRingWithURL:url andPlaceholder:nil];
}


- (void)setImsgeUsingProgressViewRingWithURL:(NSURL *)url andBackColor:(UIColor *)color {
    [self setImageUsingProgressViewRingWithURL:url placeholderImage:nil options:SDWebImageRetryFailed progress:nil completed:nil ProgressPrimaryColor:[[WeddingTimeAppInfoManager instance] baseColor] ProgressSecondaryColor:color Diameter:50];
}

- (void)setImageUsingProgressViewRingWithURL:(NSURL *)url andPlaceholder:(UIImage *)placeholder {
    [self setImageUsingProgressViewRingWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed progress:nil completed:nil ProgressPrimaryColor:[[WeddingTimeAppInfoManager instance] baseColor] ProgressSecondaryColor:[UIColor clearColor] Diameter:50];
}

- (void)setImageUsingProgressViewRingWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock ProgressPrimaryColor:(UIColor *)pColor ProgressSecondaryColor:(UIColor *)sColor Diameter:(float)diameter {
    
    [self addProgressViewRingWithPrimaryColor:pColor SecondaryColor:sColor Diameter:diameter];
    
    __strong typeof(self) weakSelf = self;
    [self sd_setImageWithURL:url
            placeholderImage:placeholder
                     options:options
                    progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        CGFloat progress = ((CGFloat)receivedSize / (CGFloat)expectedSize);
        [weakSelf updateProgressViewRing:progress];
        if (progressBlock) {
            
            progressBlock(receivedSize, expectedSize);
        }
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [weakSelf removeProgressViewRing];
        if (completedBlock) {
            completedBlock(image, error, cacheType, imageURL);
        }
    }];
}

@end
