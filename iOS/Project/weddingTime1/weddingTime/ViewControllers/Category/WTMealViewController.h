//
//  MealViewController.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/4.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "BottomView.h"
#import "WTSupplierBaseViewController.h"
@interface WTMealViewController : WTSupplierBaseViewController

@property (nonatomic, strong) NSNumber *meal_id;
@property (nonatomic, strong) NSNumber *hotel_id;
@property (nonatomic, strong) NSString *hotel_name;
@property (nonatomic, strong) NSDictionary *hotel_result;
@property (nonatomic, assign) BOOL is_like;
@property (nonatomic, strong) BottomView *bottom;
@end
