//
//  AliPayManager.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/13.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AlipaySDK/AlipaySDK.h>
@interface AliPayManager : NSObject

+ (void)payOrderWithTrade_no:(NSString *)trade_no Blcok:(void (^)(NSDictionary *))block;
+ (NSString *)getUTF8String:(NSString *)str;
@end
