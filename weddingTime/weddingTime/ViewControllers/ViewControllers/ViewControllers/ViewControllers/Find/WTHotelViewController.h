//
//  HotelViewController.h
//  weddingTime
//
//  Created by jakf_17 on 15/9/28.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "WTSupplierBaseViewController.h"
@interface WTHotelViewController : WTSupplierBaseViewController
@property (nonatomic, copy) NSString *hotel_id;
@property (nonatomic, copy) WTLikeBlock likeBlock;
@end
