//
//  BanquetViewController.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/3.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "BottomView.h"
#import "WTSupplierBaseViewController.h"
@interface WTBanquetViewController : WTSupplierBaseViewController

@property (nonatomic, strong) NSNumber *ballroom_id;
@property (nonatomic, assign) BOOL is_like;
@property (nonatomic, strong) NSNumber *hotel_id;
@property (nonatomic, strong) NSString *hotel_name;
@property (nonatomic, strong) BottomView *bottom;
@property (nonatomic, strong) NSDictionary *hotel_result;
@end
