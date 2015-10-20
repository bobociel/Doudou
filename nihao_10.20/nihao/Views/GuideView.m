//
//  GuideView.m
//  nihao
//
//  Created by 刘志 on 15/8/26.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "GuideView.h"
#import <sys/utsname.h>

@implementation GuideView

- (instancetype) initWithBackgroundImageName:(NSString *)imagePrefix {
    self = [super init];
    if(self) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.backgroundColor = [UIColor clearColor];
        NSString *imageName;
        NSString *deviceName = [self deviceName];
        if([self isIPhone5:deviceName]) {
            imageName = [imagePrefix stringByAppendingString:@"_640x1136"];
        } else if([self isIPhone6:deviceName]) {
            imageName = [imagePrefix stringByAppendingString:@"_750x1334"];
        } else if([self isIPhone4S:deviceName]) {
            imageName = [imagePrefix stringByAppendingString:@"_320x480"];
        } else {
            imageName = [imagePrefix stringByAppendingString:@"_1242x2208"];
        }
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:ImageNamed(imageName)];
        bgImageView.frame = self.bounds;
        [self addSubview:bgImageView];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:ImageNamed(@"icon_get_it") forState:UIControlStateNormal];
        [button setImage:ImageNamed(@"icon_get_it") forState:UIControlStateNormal];
        button.frame = CGRectMake((CGRectGetWidth(self.frame) - 93) / 2, CGRectGetHeight(self.frame) - 91 - 30, 93, 49);
        [button addTarget:self action:@selector(getIt) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    return self;
}

- (void) getIt {
    if(self.getItButtonClick) {
        self.getItButtonClick();
    } else {
        [self removeFromSuperview];
    }
}

- (BOOL) isIPhone5 : (NSString *) deviceName {
    if([deviceName hasPrefix:@"iPhone5"] || [deviceName hasPrefix:@"iPhone6"]) {
        return YES;
    }
    return NO;
}

- (BOOL) isIPhone4S : (NSString *) deviceName{
    if([deviceName hasPrefix:@"iPhone3"] || [deviceName hasPrefix:@"iPhone4"]) {
        return YES;
    }
    return NO;
}

- (BOOL) isIPhone6 : (NSString *) deviceName {
    if([deviceName hasPrefix:@"iPhone7,2"]) {
        return YES;
    }
    return NO;
}

- (BOOL) isIphone6s : (NSString *) deviceName {
    if([deviceName hasPrefix:@"iPhone7,1"]) {
        return YES;
    }
    return NO;
}

/**
 @"i386"      on 32-bit Simulator
 @"x86_64"    on 64-bit Simulator
 @"iPod1,1"   on iPod Touch
 @"iPod2,1"   on iPod Touch Second Generation
 @"iPod3,1"   on iPod Touch Third Generation
 @"iPod4,1"   on iPod Touch Fourth Generation
 @"iPhone1,1" on iPhone
 @"iPhone1,2" on iPhone 3G
 @"iPhone2,1" on iPhone 3GS
 @"iPad1,1"   on iPad
 @"iPad2,1"   on iPad 2
 @"iPad3,1"   on 3rd Generation iPad
 @"iPhone3,1" on iPhone 4 (GSM)
 @"iPhone3,3" on iPhone 4 (CDMA/Verizon/Sprint)
 @"iPhone4,1" on iPhone 4S
 @"iPhone5,1" on iPhone 5 (model A1428, AT&T/Canada)
 @"iPhone5,2" on iPhone 5 (model A1429, everything else)
 @"iPad3,4" on 4th Generation iPad
 @"iPad2,5" on iPad Mini
 @"iPhone5,3" on iPhone 5c (model A1456, A1532 | GSM)
 @"iPhone5,4" on iPhone 5c (model A1507, A1516, A1526 (China), A1529 | Global)
 @"iPhone6,1" on iPhone 5s (model A1433, A1533 | GSM)
 @"iPhone6,2" on iPhone 5s (model A1457, A1518, A1528 (China), A1530 | Global)
 @"iPad4,1" on 5th Generation iPad (iPad Air) - Wifi
 @"iPad4,2" on 5th Generation iPad (iPad Air) - Cellular
 @"iPad4,4" on 2nd Generation iPad Mini - Wifi
 @"iPad4,5" on 2nd Generation iPad Mini - Cellular
 @"iPhone7,1" on iPhone 6 Plus
 @"iPhone7,2" on iPhone 6
 @return
 */
- (NSString*) deviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

@end
