//
//  WTWeddingCard.h
//  weddingTime
//
//  Created by wangxiaobo on 16/3/11.
//  Copyright © 2016年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTWeddingCard : NSObject
@property (nonatomic,copy) NSString *ID;
@property (nonatomic,copy) NSString *taobao_id;
@property (nonatomic,copy) NSString *goods_name;
@property (nonatomic,copy) NSString *goods_desc;
@property (nonatomic,copy) NSString *main_pic;
@property (nonatomic,copy) NSString *market_price;
@property (nonatomic,copy) NSString *goods_sn;
@property (nonatomic,strong) NSArray *goods_img;
@property (nonatomic,strong) NSArray *goods_package;
@property (nonatomic,strong) NSArray *goods_attr;
@property (nonatomic,assign) double goods_price;
@property (nonatomic,assign) double h;
@property (nonatomic,assign) double w;
@end

@interface WTWeddingCardImage : NSObject
@property (nonatomic,copy) NSString *goods_id;
@property (nonatomic,copy) NSString *host;
@property (nonatomic,copy) NSString *path;
@property (nonatomic,assign) double h;
@property (nonatomic,assign) double w;
@end

@interface WTWeddingCardExt : NSObject
@property (nonatomic,copy) NSString *goods_id;
@property (nonatomic,copy) NSString *label;
@property (nonatomic,copy) NSString *attr;
@property (nonatomic,assign) double price;
@end