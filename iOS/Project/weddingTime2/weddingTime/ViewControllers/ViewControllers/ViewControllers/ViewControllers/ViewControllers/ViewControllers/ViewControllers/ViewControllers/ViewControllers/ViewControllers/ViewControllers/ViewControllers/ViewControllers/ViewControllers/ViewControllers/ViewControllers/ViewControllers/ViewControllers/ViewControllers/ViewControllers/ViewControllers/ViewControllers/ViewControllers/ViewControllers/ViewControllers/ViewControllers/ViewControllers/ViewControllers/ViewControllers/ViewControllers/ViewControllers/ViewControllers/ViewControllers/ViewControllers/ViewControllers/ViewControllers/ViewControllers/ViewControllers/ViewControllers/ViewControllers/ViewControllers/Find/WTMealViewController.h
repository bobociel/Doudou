//
//  MealViewController.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/4.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "WTSupplierBaseViewController.h"
#import "BottomView.h"
#import "WTHotel.h"
@interface WTMealViewController : WTSupplierBaseViewController
@property (nonatomic, copy) NSString *meal_id;
@property (nonatomic, copy) NSString *hotel_id;
@property (nonatomic, assign) BOOL is_like;
@property (nonatomic, strong) WTHotelDetail *hotelDetail;
@property (nonatomic, copy) WTLikeBlock likeBlock;
@end
