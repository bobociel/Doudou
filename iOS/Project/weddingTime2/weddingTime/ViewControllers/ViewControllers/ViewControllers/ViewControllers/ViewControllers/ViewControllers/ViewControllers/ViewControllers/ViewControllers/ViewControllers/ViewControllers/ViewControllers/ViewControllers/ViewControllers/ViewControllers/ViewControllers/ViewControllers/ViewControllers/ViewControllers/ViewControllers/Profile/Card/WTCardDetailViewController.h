//
//  WTCardDetailViewController.h
//  weddingTime
//
//  Created by wangxiaobo on 16/3/11.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "BaseViewController.h"
typedef NS_ENUM(NSInteger,WTCardCellType) {
	WTCardCellTypeIntro = 0,
	WTCardCellTypeSKU = 1,
	WTCardCellTypeMenu = 2,
	WTCardCellTypeImage = 3
};
@interface WTCardDetailViewController : BaseViewController
+ (instancetype)instanceWithCardId:(NSString *)cardID;
@end
