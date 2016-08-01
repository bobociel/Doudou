//
//  CreateDemandViewController.h
//  weddingTime
//
//  Created by _Cuixin on 15/9/21.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

typedef NS_ENUM(NSInteger,WTChooseType) {
	WTChooseTypeService,
	WTChooseTypePrice,
	WTChooseTypeCity
};

#import "BaseViewController.h"
@interface WTCreateDemandViewController : BaseViewController
@property (nonatomic, copy) WTRefreshBlock refreshBlock;
- (void)setRefreshBlock:(WTRefreshBlock)refreshBlock;
@end
