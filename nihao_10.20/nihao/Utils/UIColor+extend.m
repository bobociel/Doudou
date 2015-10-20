//
//  UIColor+extend.m
//  ETravel
//
//  Created by XiongCaixing on 10-12-30.
//  Copyright 2010 华易科技. All rights reserved.
//

#import "UIColor+extend.h"

@implementation UIColor(extend)

+ (UIColor *)hexChangeFloat:(NSString *) hexColor {
    
    hexColor = [hexColor stringByReplacingOccurrencesOfString:@"#" withString:@""];

    if ([hexColor length] != 6) {
        return [UIColor whiteColor];
    }
    
	unsigned int redInt_, greenInt_, blueInt_;
	NSRange rangeNSRange_;
	rangeNSRange_.length = 2;  // 范围长度为2
	
	// 取红色的值
	rangeNSRange_.location = 0; 
	[[NSScanner scannerWithString:[hexColor substringWithRange:rangeNSRange_]] 
	 scanHexInt:&redInt_];
	
	// 取绿色的值
	rangeNSRange_.location = 2; 
	[[NSScanner scannerWithString:[hexColor substringWithRange:rangeNSRange_]] 
	 scanHexInt:&greenInt_];
	
	// 取蓝色的值
	rangeNSRange_.location = 4; 
	[[NSScanner scannerWithString:[hexColor substringWithRange:rangeNSRange_]] 
	 scanHexInt:&blueInt_];	
	
	return [UIColor colorWithRed:(float)(redInt_/255.0f) 
						   green:(float)(greenInt_/255.0f) 
							blue:(float)(blueInt_/255.0f) 
						   alpha:1.0f];
}

+ (UIColor *)hexChangeFloat:(NSString *)hexColor alpha:(CGFloat)alpha {
    hexColor = [hexColor stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if ([hexColor length] != 6) {
        return [UIColor whiteColor];
    }
    
    unsigned int redInt_, greenInt_, blueInt_;
    NSRange rangeNSRange_;
    rangeNSRange_.length = 2;  // 范围长度为2
    
    // 取红色的值
    rangeNSRange_.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:rangeNSRange_]]
     scanHexInt:&redInt_];
    
    // 取绿色的值
    rangeNSRange_.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:rangeNSRange_]]
     scanHexInt:&greenInt_];
    
    // 取蓝色的值
    rangeNSRange_.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:rangeNSRange_]]
     scanHexInt:&blueInt_];
    
    if (alpha > 1.0f) {
        alpha = 1.0f;
    }
    if (alpha < 0.0f) {
        alpha = 0.0f;
    }
    
    return [UIColor colorWithRed:(float)(redInt_/255.0f)
                           green:(float)(greenInt_/255.0f)
                            blue:(float)(blueInt_/255.0f) 
                           alpha:alpha];
}

@end