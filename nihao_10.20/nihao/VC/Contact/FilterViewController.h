//
//  FilterViewController.h
//  nihao
//
//  Created by 刘志 on 15/9/18.
//  Copyright © 2015年 jiazhong. All rights reserved.
//

#import "BaseViewController.h"
@class Nationality;

@protocol SetFilterDelegate <NSObject>

- (void) setFilter :(BOOL) all gender : (NSInteger) gender city : (NSString *) city nationality : (Nationality *) nationality;

@end

@interface FilterViewController : BaseViewController

@property (assign,nonatomic) BOOL all;

//当gender为－1时，用户未对性别进行筛选
@property (assign,nonatomic) NSInteger gender;

@property (copy,nonatomic) NSString *city;

@property (copy,nonatomic) Nationality *nationality;

@property (weak,nonatomic) id<SetFilterDelegate> delegate;

@end
