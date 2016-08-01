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
@property (nonatomic, strong) NSString *works_id;
@property (nonatomic, copy) WTLikeBlock likeBlock;
@end
