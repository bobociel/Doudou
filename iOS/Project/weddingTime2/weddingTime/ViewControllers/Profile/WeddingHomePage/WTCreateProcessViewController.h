//
//  WTCreateProcessViewController.h
//  weddingTime
//
//  Created by wangxiaobo on 16/5/31.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "BaseViewController.h"
#import "WTWeddingBless.h"
typedef NS_ENUM(NSInteger,WTProInputType) {
	WTProInputTypeDate,
	WTProInputTypeTime
};

@interface WTCreateProcessViewController : BaseViewController
@property (nonatomic,copy) WTRefreshBlock refreshBlock;
- (void)setRefreshBlock:(WTRefreshBlock)refreshBlock;
+ (instancetype)instanceWithWeddingProcess:(WTWeddingProcess *)process;
@end
