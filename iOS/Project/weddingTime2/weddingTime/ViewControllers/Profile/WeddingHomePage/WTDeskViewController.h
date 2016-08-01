//
//  WTDeskViewController.h
//  weddingTime
//
//  Created by wangxiaobo on 16/5/24.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "BaseViewController.h"

@interface WTDeskViewController : BaseViewController
+ (instancetype)instanceWithShow:(BOOL)showDesk;
@property (nonatomic,copy) WTRefreshBlock refreshBlock;
- (void)setRefreshBlock:(WTRefreshBlock)refreshBlock;
@end
