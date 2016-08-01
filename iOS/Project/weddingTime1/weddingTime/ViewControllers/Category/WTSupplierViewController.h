//
//  SupplierViewController.h
//  weddingTime
//
//  Created by jakf_17 on 15/9/24.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "BaseViewController.h"
#import "WTSupplierBaseViewController.h"
@interface WTSupplierViewController : WTSupplierBaseViewController

@property (nonatomic, assign) BOOL is_like;        
@property (nonatomic, strong) NSNumber *supplier_id;
@property (nonatomic, strong) NSNumber *user_id;

@end
