//
//  NSString+QHNSStringCtg.h
//  QHCategorys
//
//  Created by imqiuhang on 15/2/10.
//  Copyright (c) 2015年 imqiuhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (QHNSStringCtg)
//返回非空字符串对象
//- (NSString *)stringWithNoEmpty;

///去除空格判断是否为空
- (BOOL)isNotEmptyCtg;
///不去除空格判断是否为空
- (BOOL)isNotEmptyWithSpace;

///符号成套删除 可用于去除带有xml标记 如<color>
- (NSString*)stringByDeleteSignForm:(NSString *)aLeftSign
                       andRightSign:(NSString *)aRightSign;


- (NSString*)stringByReplacingSignForm:(NSString *)aLeftSign
                          andRightSign:(NSString *)aRightSign
                       andReplacingStr:(NSString*)aReplacingStr;

@end

@interface NSNumber (QHNSStringCtg)
- (BOOL)isNotEmptyCtg;
@end
