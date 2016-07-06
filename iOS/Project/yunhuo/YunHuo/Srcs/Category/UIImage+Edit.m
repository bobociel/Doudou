//
//  UIImage+Edit.m
//  HPCamera
//
//  Created by jiang zhuoyi on 13-10-25.
//  Copyright (c) 2014 iHyperSoft. All rights reserved.
//

#import "UIImage+Edit.h"

@implementation UIImage (Crop)

- (UIImage *)crop:(CGRect)rect
{
    rect = CGRectMake(rect.origin.x * self.scale, rect.origin.y * self.scale,
                      rect.size.width * self.scale, rect.size.height * self.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef
                                          scale:self.scale
                                    orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    
    return result;
}

@end



@implementation UIImage (fixOrientation)

- (UIImage *)fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        case UIImageOrientationRight:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
			transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformScale(transform, 1, -1);
			break;
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
//        case UIImageOrientationLeftMirrored:
//        case UIImageOrientationRightMirrored:
//            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
//            transform = CGAffineTransformScale(transform, -1, 1);
//            break;
            
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
//        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
//        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end

@implementation UIImage (Scale)

- (UIImage *) scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (UIImage *) scaleToSize:(CGSize)size withOrientation:(UIImageOrientation)imageOrientation
{
	UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
//	CGContextRef context = UIGraphicsGetCurrentContext();
//	switch (imageOrientation)
//	{
//		case UIImageOrientationUp:
//			[self drawInRect:CGRectMake(0, 0, size.width, size.height)];
//			break;
//		case UIImageOrientationDown:
//			CGContextRotateCTM(context, M_PI);
//			[self drawInRect:CGRectMake(0, 0, size.width, size.height)];
//		case UIImageOrientationRight:
//			CGContextRotateCTM(context, M_PI_2);
//			[self drawInRect:CGRectMake(0, -size.height, size.width, size.height)];
//		default:
//			break;
//	}
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [UIImage imageWithCGImage:scaledImage.CGImage scale:1.0 orientation:imageOrientation];
}

@end



@implementation UIImage (Flip)

+ (UIImage*)flipImageHorizontal:(UIImage *)sourceImg
{
    UIImage *resultImg = nil;
    switch (sourceImg.imageOrientation) {
        case UIImageOrientationUp:
        {
            resultImg = [[UIImage alloc] initWithCGImage:sourceImg.CGImage scale:1 orientation:UIImageOrientationUpMirrored];
            break;
        }
        case UIImageOrientationDown:
        {
            resultImg = [[UIImage alloc] initWithCGImage:sourceImg.CGImage scale:1 orientation:UIImageOrientationDownMirrored];
            break;
        }
        case UIImageOrientationLeft:
        {
            resultImg = [[UIImage alloc] initWithCGImage:sourceImg.CGImage scale:1 orientation:UIImageOrientationRightMirrored];
            break;
        }
        case UIImageOrientationRight:
        {
            resultImg = [[UIImage alloc] initWithCGImage:sourceImg.CGImage scale:1 orientation:UIImageOrientationLeftMirrored];
            break;
        }
        case UIImageOrientationUpMirrored:
        {
            resultImg = [[UIImage alloc] initWithCGImage:sourceImg.CGImage scale:1 orientation:UIImageOrientationUp];
            break;
        }
        case UIImageOrientationDownMirrored:
        {
            resultImg = [[UIImage alloc] initWithCGImage:sourceImg.CGImage scale:1 orientation:UIImageOrientationDown];
            break;
        }
        case UIImageOrientationLeftMirrored:
        {
            resultImg = [[UIImage alloc] initWithCGImage:sourceImg.CGImage scale:1 orientation:UIImageOrientationRight];
            break;
        }
        case UIImageOrientationRightMirrored:
        {
            resultImg = [[UIImage alloc] initWithCGImage:sourceImg.CGImage scale:1 orientation:UIImageOrientationLeft];
            break;
        }
        default:
            NSLog(@"orientation error!!!");
            break;
    }
    if (resultImg) {
        
        CGSize sourceSize = CGSizeMake(resultImg.size.width * resultImg.scale, resultImg.size.height * resultImg.scale);
        
        UIGraphicsBeginImageContext(sourceSize);
        
        [resultImg drawInRect:CGRectMake(0, 0, sourceSize.width, sourceSize.height)];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    return resultImg;
}

+ (UIImage*)flipImageVertical:(UIImage*)sourceImg
{
    UIImage *resultImg = nil;
    switch (sourceImg.imageOrientation) {
        case UIImageOrientationUp:
        {
            resultImg = [[UIImage alloc] initWithCGImage:sourceImg.CGImage scale:1 orientation:UIImageOrientationDownMirrored];
            break;
        }
        case UIImageOrientationDown:
        {
            resultImg = [[UIImage alloc] initWithCGImage:sourceImg.CGImage scale:1 orientation:UIImageOrientationUpMirrored];
            break;
        }
        case UIImageOrientationLeft:
        {
            resultImg = [[UIImage alloc] initWithCGImage:sourceImg.CGImage scale:1 orientation:UIImageOrientationLeftMirrored];
            break;
        }
        case UIImageOrientationRight:
        {
            resultImg = [[UIImage alloc] initWithCGImage:sourceImg.CGImage scale:1 orientation:UIImageOrientationRightMirrored];
            break;
        }
        case UIImageOrientationUpMirrored:
        {
            resultImg = [[UIImage alloc] initWithCGImage:sourceImg.CGImage scale:1 orientation:UIImageOrientationDown];
            break;
        }
        case UIImageOrientationDownMirrored:
        {
            resultImg = [[UIImage alloc] initWithCGImage:sourceImg.CGImage scale:1 orientation:UIImageOrientationUp];
            break;
        }
        case UIImageOrientationLeftMirrored:
        {
            resultImg = [[UIImage alloc] initWithCGImage:sourceImg.CGImage scale:1 orientation:UIImageOrientationLeft];
            break;
        }
        case UIImageOrientationRightMirrored:
        {
            resultImg = [[UIImage alloc] initWithCGImage:sourceImg.CGImage scale:1 orientation:UIImageOrientationRight];
            break;
        }
        default:
            break;
    }
    if (resultImg) {
        
        CGSize sourceSize = CGSizeMake(resultImg.size.width * resultImg.scale, resultImg.size.height * resultImg.scale);
        
        UIGraphicsBeginImageContext(sourceSize);
        
        [resultImg drawInRect:CGRectMake(0, 0, sourceSize.width, sourceSize.height)];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    return resultImg;
}

@end