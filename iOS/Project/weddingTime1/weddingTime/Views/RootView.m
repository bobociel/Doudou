//
//  RootView.m
//  lovewith
//
//  Created by imqiuhang on 15/5/26.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "RootView.h"

@implementation RootView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)drawRect:(CGRect)rect
{
   [super drawRect:rect];
    if (_needGradient) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self DrawGradientColor:context rect:self.bounds
                          point:CGPointMake(self.bounds.size.width/2, 0) point:CGPointMake(self.bounds.size.width/2, self.bounds.size.height) options:kCGGradientDrawsAfterEndLocation startColor:[LWUtil colorWithHexString:@"FF891F"]  endColor:[LWUtil colorWithHexString:@"FF6499"]];
    }
}

-(void)setNeedGradient:(BOOL)needGradient
{
    _needGradient=needGradient;
    [self setNeedsDisplay];
}

- (void)DrawGradientColor:(CGContextRef)context
                     rect:(CGRect)clipRect
                    point:(CGPoint) startPoint
                    point:(CGPoint) endPoint
                  options:(CGGradientDrawingOptions) options
               startColor:(UIColor*)startColor
                 endColor:(UIColor*)endColor
{
    UIColor* colors [2] = {startColor,endColor};
    CGColorSpaceRef rgb =CGColorSpaceCreateDeviceRGB();
    CGFloat colorComponents[8];
    
    for (int i = 0; i < 2; i++) {
        UIColor *color = colors[i];
        CGColorRef temcolorRef = color.CGColor;
        
        const CGFloat *components = CGColorGetComponents(temcolorRef);
        for (int j = 0; j < 4; j++) {
            colorComponents[i *4 + j] = components[j];
        }
    }
    CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, colorComponents,NULL, 2);
    
    CGColorSpaceRelease(rgb);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, options);
    CGGradientRelease(gradient);
}
@end
