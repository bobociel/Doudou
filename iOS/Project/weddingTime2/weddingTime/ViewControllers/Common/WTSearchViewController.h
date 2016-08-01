//
//  WTSearchViewController.h
//  weddingTime
//
//  Created by 默默 on 15/10/12.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "BaseViewController.h"
typedef NS_ENUM(NSInteger,SearchType) {
    SearchTypeSupplier    = 0,
    SearchTypeInspiretion = 1,
    SearchTypeHotel       = 2
};
@interface WTSearchViewController : BaseViewController
+ (instancetype)instanceSearchVCWithType:(SearchType)type;
+ (instancetype)instanceSearchVCWithType:(SearchType)type andSearchKey:(NSString *)searchKey;
@end
