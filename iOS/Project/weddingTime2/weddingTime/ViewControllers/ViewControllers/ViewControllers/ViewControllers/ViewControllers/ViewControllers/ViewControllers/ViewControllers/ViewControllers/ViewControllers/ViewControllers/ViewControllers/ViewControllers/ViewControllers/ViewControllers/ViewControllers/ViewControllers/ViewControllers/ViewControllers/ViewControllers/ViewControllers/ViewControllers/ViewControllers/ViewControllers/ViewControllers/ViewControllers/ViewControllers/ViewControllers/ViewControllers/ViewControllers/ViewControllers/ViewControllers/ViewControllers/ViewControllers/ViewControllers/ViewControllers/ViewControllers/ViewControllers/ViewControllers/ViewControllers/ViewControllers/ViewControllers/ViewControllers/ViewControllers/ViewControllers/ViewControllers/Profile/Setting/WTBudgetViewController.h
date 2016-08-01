//
//  WTBudgetViewController.h
//  weddingTime
//
//  Created by wangxiaobo on 16/4/11.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "BaseViewController.h"

@interface WTBudgetViewController : BaseViewController
@property (nonatomic,copy) WTRefreshBlock refreshBlock;
- (void)setRefreshBlock:(WTRefreshBlock)refreshBlock;
@end
