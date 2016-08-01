//
//  WTSupplier.h
//  weddingTime
//
//  Created by wangxiaobo on 16/2/5.
//  Copyright © 2016年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTSupplier : NSObject
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *service_id;
@property (nonatomic, copy) NSString *supplier_user_id;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *supplierUserId;

@property (nonatomic,assign) BOOL is_admin;
@property (nonatomic,assign) BOOL has_auth;
@property (nonatomic,assign) BOOL is_like;
@property (nonatomic,assign) double  price;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *logo_path;
@property (nonatomic, copy) NSString *score;

@property (nonatomic, assign) double start_price;
@property (nonatomic, copy) NSString *service_type;
@property (nonatomic, copy) NSString *supplier_name;
@property (nonatomic, copy) NSString *supplier_avatar;
@property (nonatomic, copy) NSString *supplier_banner;
@property (nonatomic, copy) NSString *supplier_description;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, strong) NSMutableArray *supplier_post;
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
@property (nonatomic, copy) NSString *post_id;
@property (nonatomic, copy) NSString *post_name;
@property (nonatomic, copy) NSString *post_pic;
@property (nonatomic, assign) double post_price;

@property (nonatomic, assign) BOOL is_admin;
@property (nonatomic, assign) BOOL is_like;
@property (nonatomic, assign) double price;
@property (nonatomic, copy) NSString *post_title;
@property (nonatomic, copy) NSString *post_avatar;
@property (nonatomic, copy) NSString *video;
@property (nonatomic, copy) NSString *tel;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *cate;
@property (nonatomic, copy) NSString *post_description;
@property (nonatomic, copy) NSString *supplier_user_id;
@property (nonatomic, copy) NSString *supplier_company;
@property (nonatomic, copy) NSString *supplier_avatar;
@property (nonatomic, copy) NSString *service_cate;
@property (nonatomic, strong) NSMutableArray *post_image;
@property (nonatomic, strong) NSMutableArray *sku;

@property (nonatomic, assign) double heigth;
@property (nonatomic, assign) double width;
@end

//@interface WTPostImage : NSObject
//@property (nonatomic, assign) BOOL is_video;
//@property (nonatomic, copy) NSString *pic;
//@property (nonatomic, copy) NSString *desc;
//@property (nonatomic, copy) NSString *size;
//@property (nonatomic, assign) double heigth;
//@property (nonatomic, assign) double width;
//@end

