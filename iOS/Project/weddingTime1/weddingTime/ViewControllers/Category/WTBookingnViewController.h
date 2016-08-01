//
//  WTBookingnViewController.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/16.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "BottomView.h"
@interface WTBookingnViewController : BaseViewController

@property (nonatomic, strong) NSString *image_url;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *cate;
@property (nonatomic, strong) NSNumber *supplier_id;
@property (nonatomic, strong) NSNumber *work_id;
@property (nonatomic, assign) isFromType isfrom_type;
@end
