//
//  WorksDetailViewController.h
//  weddingTime
//
//  Created by jakf_17 on 15/9/29.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "BottomView.h"
#import "WTSupplierBaseViewController.h"
@interface WTWorksDetailViewController : WTSupplierBaseViewController
@property (nonatomic, strong) NSNumber *works_id;
@property (nonatomic, assign) BOOL is_like;
@property (nonatomic, strong) BottomView *bottom;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *cate;
@property (nonatomic, strong) NSNumber *supplier_id;
@end
