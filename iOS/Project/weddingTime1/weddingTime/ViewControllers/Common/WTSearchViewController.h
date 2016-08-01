//
//  WTSearchViewController.h
//  weddingTime
//
//  Created by 默默 on 15/10/12.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "BaseViewController.h"
typedef enum {
    SearchTypeSupplier    = 0,
    SearchTypeInspiretion = 1,
    SearchTypeHotel       = 2,
    SearchTypeDiscover      = 3 //发现没有提供关键字搜索的增量接口，鉴于本地search比较麻烦，暂且不做
}SearchType;
@interface WTSearchViewController : BaseViewController
@property (nonatomic,assign)SearchType curSearchType;
@end
