//
//  WTProcessViewController.h
//  weddingTime
//
//  Created by wangxiaobo on 16/5/31.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "BaseViewController.h"

@interface WTProcessViewController : BaseViewController
@property (nonatomic,copy) WTRefreshBlock refreshBlock;
- (void)setRefreshBlock:(WTRefreshBlock)refreshBlock;
+ (instancetype)instanceWithShow:(BOOL)showProcess;
@end
