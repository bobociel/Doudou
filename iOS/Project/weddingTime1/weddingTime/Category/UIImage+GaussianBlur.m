//
//  UIImage+GaussianBlur.m
//  图像模糊
//
//  Created by liuchang on 15/1/4.
//  Copyright (c) 2015年 liuchang. All rights reserved.
//

#import "UIImage+GaussianBlur.h"
#import <Accelerate/Accelerate.h>
@implementation UIImage (GaussianBlur)

+ (UIImage *)imageWithBlurImage:(const UIImage *)theImage intputRadius:(const CGFloat)radius
{
//  CIContext. 所有图像处理都是在一个CIContext 中完成的
    CIContext *context = [CIContext contextWithOptions:nil];

//  CIImage. 这个类保存图像数据。它可以从UIImage、图像文件、或者是像素数据中构造出来。
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];

//  CIFilter. 滤镜类包含一个字典结构，对各种滤镜定义了属于他们各自的属性。滤镜有很多种，比如鲜艳程度滤镜，色彩反转滤镜，剪裁滤镜等等。
    CIFilter *blurFilter1 = [CIFilter filterWithName:@"CIGaussianBlur"];
    
    // filter是按照名字来创建的CIGaussianBlur不能更改
    [blurFilter1 setValue:inputImage forKey:kCIInputImageKey];
    [blurFilter1 setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
    
    // 修改radius可以更改模糊程度
    CIImage *result = [blurFilter1 valueForKey:kCIOutputImageKey];
    
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    UIGraphicsEndImageContext();
    // 即使使用ARC也要加上这个release，因为ARC不管理CGImageRef，不释放会内存泄露
    return returnImage;
}

+(UIImage *)blurryImage:(const UIImage *)image withBlurLevel:(CGFloat)blur {
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 100);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = image.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) *
                         CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer,
                                       &outBuffer,
                                       NULL,
                                       0,
                                       0,
                                       boxSize,
                                       boxSize,
                                       NULL,
                                       kvImageEdgeExtend);
    
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
     UIGraphicsEndImageContext();
    return returnImage;
}

@end
