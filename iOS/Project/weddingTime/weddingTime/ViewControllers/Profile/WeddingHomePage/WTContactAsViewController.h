//
//  WTContactAsViewController.h
//  weddingTime
//
//  Created by wangxiaobo on 16/5/17.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "BaseViewController.h"
typedef NS_ENUM(NSInteger,WTContactListType) {
	WTContactListTypeState,
	WTContactListTypePhone,
	WTContactListTypePPhone
};
@interface WTContactAsViewController : BaseViewController
@property (nonatomic,copy) WTRefreshBlock refreshBlock;
+ (instancetype)instanceWithContact:(BOOL)isContact;
- (void)setRefreshBlock:(WTRefreshBlock)refreshBlock;
@end
