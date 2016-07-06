//
//  UIImage+Edit.h
//  HPCamera
//
//  Created by jiang zhuoyi on 13-10-25.
//  Copyright (c) 2014 iHyperSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Crop)

- (UIImage *) crop:(CGRect)rect;

@end

@interface UIImage (Orientation)

- (UIImage *) fixOrientation;

@end

@interface UIImage (Scale)

- (UIImage *) scaleToSize:(CGSize)size;
- (UIImage *) scaleToSize:(CGSize)size withOrientation:(UIImageOrientation)imageOrientation;

@end

@interface UIImage (Flip)

+ (UIImage*)flipImageHorizontal:(UIImage*)sourceImg;

+ (UIImage*)flipImageVertical:(UIImage*)sourceImg;

@end