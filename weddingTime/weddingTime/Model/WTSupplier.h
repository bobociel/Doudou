//
//  WTSupplier.h
//  weddingTime
//
//  Created by wangxiaobo on 16/2/5.
//  Copyright © 2016年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTPostImage : NSObject
@property (nonatomic, copy) NSString *pic;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *size;
@property (nonatomic, assign) BOOL is_video;
@property (nonatomic, assign) double height;
@property (nonatomic, assign) double width;
@end

@interface WTSupplier : NSObject
@property (nonatomic,assign) BOOL is_admin;
@property (nonatomic,assign) BOOL has_auth;
@property (nonatomic,assign) BOOL is_like;
@property (nonatomic, assign) WTWeddingType service_id;
@property (nonatomic, assign) WTSupplierLevel level;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *service_name;
@property (nonatomic, copy) NSString *service_type;
@property (nonatomic, copy) NSString *supplier_user_id;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *supplierUserId;
@property (nonatomic, copy) NSString *city_id;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *business_tel;
@property (nonatomic, copy) NSString *phone;

@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *lowest_price;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *logo_path;
@property (nonatomic, copy) NSString *score;

@property (nonatomic, copy) NSString *supplier_name;
@property (nonatomic, copy) NSString *supplier_company; //SupplierPost
@property (nonatomic, copy) NSString *supplier_avatar;
@property (nonatomic, copy) NSString *supplier_banner;
@property (nonatomic, copy) NSString *supplier_description;
@property (nonatomic, strong) NSMutableArray *supplier_post;

@property (nonatomic, copy)   NSString *min_coupon;
@property (nonatomic, copy)   NSString *max_coupon;
//SHVC
@property (nonatomic, assign) double like_num;
@property (nonatomic, assign) double post_num;
@property (nonatomic, assign) double comment_num;
@property (nonatomic, assign) double supplier_post_num;
//LikeVC
@property (nonatomic, assign) double like_count;
@property (nonatomic, assign) double works_count;
//custom
@property (nonatomic, assign) double likeCount;
@property (nonatomic, assign) double workCount;

@end

@interface WTSupplierPost : NSObject
//服务商作品列表
@property (nonatomic, copy)   NSString *post_pic;
@property (nonatomic, assign) double width;
@property (nonatomic, assign) double heigth;
//@property (nonatomic, copy)   NSString *post_name;

//作品列表，新娘商店列表
@property (nonatomic, copy)   NSString *ID;
@property (nonatomic, copy)   NSString *supplier_user_id;
@property (nonatomic, assign) WTSupplierLevel level;
@property (nonatomic, copy)   NSString *company;
@property (nonatomic, copy)   NSString *avatar;
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, copy)   NSString *cover;
@property (nonatomic, copy)   NSString *price;
@property (nonatomic, copy)   NSString *coupon;
//@property (nonatomic, assign) BOOL is_like; //作品列表
@property (nonatomic, assign) WTWeddingType service_id;
@property (nonatomic, copy)   NSString *service_name;
@property (nonatomic, copy)   NSString *post_name;
@property (nonatomic, copy)   NSString *city;
//@property (nonatomic, copy)   NSString *min_coupon;
//@property (nonatomic, copy)   NSString *max_coupon;
//@property (nonatomic, assign) BOOL is_like;
//作品详情,新娘商店详情
@property (nonatomic, assign) BOOL is_like;
@property (nonatomic, copy)   NSString *post_id;
@property (nonatomic, copy)   NSString *post_title;
@property (nonatomic, copy)   NSString *post_description;
@property (nonatomic, copy)   NSString *post_cover;
@property (nonatomic, copy)   NSString *price_range;
@property (nonatomic, copy)   NSString *min_coupon;
@property (nonatomic, copy)   NSString *max_coupon;
@property (nonatomic, copy)   NSString *hotel_name;
@property (nonatomic, copy)   NSString *video;
@property (nonatomic, strong) WTSupplier *supplier_info;
@property (nonatomic, strong) NSMutableArray *post_image;
@property (nonatomic, strong) NSMutableArray *origin_data;
@end
