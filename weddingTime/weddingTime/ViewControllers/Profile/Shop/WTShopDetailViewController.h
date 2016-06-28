//
//  WorksDetailViewController.h
//  weddingTime
//
//  Created by jakf_17 on 15/9/29.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "BaseViewController.h"
#import "WTSupplierBaseViewController.h"
@interface WTShopDetailViewController : WTSupplierBaseViewController
+ (instancetype)instanceVCWithWrokID:(NSString *)workID;
@end
