//
//  CreateDemandViewController.h
//  weddingTime
//
//  Created by _Cuixin on 15/9/21.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//
typedef void(^BoolBlock)(BOOL refresh);
#import "BaseViewController.h"
@interface WTCreateDemandViewController : BaseViewController
@property (nonatomic, copy) BoolBlock refreshBlock;
- (void)setRefreshBlock:(BoolBlock)refreshBlock;
@end
