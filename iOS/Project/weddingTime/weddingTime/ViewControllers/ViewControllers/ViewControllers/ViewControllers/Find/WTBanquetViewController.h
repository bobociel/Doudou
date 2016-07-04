//
//  BanquetViewController.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/3.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "WTSupplierBaseViewController.h"
#import "WorksDetailCell.h"
#import "WTHotel.h"
@interface WTBanquetViewController : WTSupplierBaseViewController
@property (nonatomic, assign) BOOL is_like;
@property (nonatomic, copy) NSString *ballroom_id;
@property (nonatomic, copy) NSString *hotel_id;
@property (nonatomic, strong) WTHotelDetail *hotelDetail;
@end
