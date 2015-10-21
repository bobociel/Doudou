//
//  UserPost.h
//  nihao
//
//  Created by HelloWorld on 6/18/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Picture.h"

@interface UserPost : NSObject

@property (nonatomic, assign) int cd_id;// 动态ID
@property (nonatomic, copy) NSString *ci_nikename;// 动态发布人昵称
@property (nonatomic, copy) NSString *cd_date;// 动态发布时间
@property (nonatomic, assign) int cd_ci_id;// 动态发布人ID
@property (nonatomic, copy) NSString *ci_header_img;// 动态发布人头像
@property (nonatomic, copy) NSString *cd_info;// 动态内容
@property (nonatomic, assign) int ci_sex;// 动态发布人性别
@property (nonatomic, assign) int cd_sum_pii_count;// 表示点赞总数
@property (nonatomic, assign) int cd_sum_cmi_count;// 表示评论总数
@property (nonatomic, assign) int cd_sum_fwi_count;// 表示转发总数
@property (nonatomic, strong) NSMutableArray *pictures;// 动态的图片数组
@property (nonatomic, assign) NSInteger pii_is_praise; //是否已经点赞，0未赞，1已赞
@property (nonatomic, assign) NSInteger friend_type; //好友状态，1双方未互粉，2已粉对方，3对方已粉自己，4双方已互粉
@property (nonatomic,copy) NSString *cd_address; //动态发布地址
@property (nonatomic,assign) NSInteger cd_look_count; //浏览量
@end
