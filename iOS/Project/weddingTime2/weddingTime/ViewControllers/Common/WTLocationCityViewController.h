//
//  WTLocationCityViewController.h
//  weddingTime
//
//  Created by wangxiaobo on 16/5/27.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "BaseViewController.h"
@interface WTLocationCityViewController : BaseViewController
@property (nonatomic,copy) WTRefreshBlock refreshBlock;
- (void)setRefreshBlock:(WTRefreshBlock)refreshBlock;
@end
