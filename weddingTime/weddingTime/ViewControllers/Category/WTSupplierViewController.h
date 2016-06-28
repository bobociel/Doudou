//
//  SupplierViewController.h
//  weddingTime
//
//  Created by jakf_17 on 15/9/24.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "BaseViewController.h"
#import "WTSupplierBaseViewController.h"
#import "WTSupplier.h"
@interface WTSupplierViewController : WTSupplierBaseViewController
@property (nonatomic, copy) NSString *supplier_id;
@property (nonatomic, copy) WTLikeBlock likeBlock;
@end
