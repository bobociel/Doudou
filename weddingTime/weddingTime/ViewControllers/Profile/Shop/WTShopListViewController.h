//
//  WTShopViewListViewController.h
//  weddingTime
//
//  Created by wangxiaobo on 16/5/11.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "BaseViewController.h"

@interface WTShopListViewController : BaseViewController
- (void)loadDataWithType:(WTWeddingType)type andCity:(NSString *)cityID;
@end
