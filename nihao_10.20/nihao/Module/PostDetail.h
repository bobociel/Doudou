//
//  PostDetail.h
//  nihao
//
//  Created by HelloWorld on 6/23/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Picture.h"
#import "Comment.h"

@interface PostDetail : NSObject

// cd_id：动态ID
@property (assign, nonatomic) int cd_id;
// cd_info：动态详情
@property (copy, nonatomic) NSString *cd_info;
// cd_gpslat：发布动态时的纬度
@property (assign, nonatomic) double cd_gpslat;
// cd_gpslong：发布动态时的经度
@property (assign, nonatomic) double cd_gpslong;
// cd_ci_id：发布动态的客户ID
@property (assign, nonatomic) int cd_ci_id;
// ci_nikename：发布动态的客户昵称
@property (copy, nonatomic) NSString *ci_nikename;
// ci_header_img：发布动态的客户的头像
@property (copy, nonatomic) NSString *ci_header_img;
// ci_sex：发布动态的客户的性别
@property (assign, nonatomic) int ci_sex;
// ci_date：发布动态的日期时间
@property (copy, nonatomic) NSString *cd_date;

// pictures：动态的图片
@property (nonatomic, strong) NSMutableArray *pictures;
// comments：动态的评论
@property (nonatomic, strong) NSMutableArray *comments;

// sum_pii_count ：表示点赞总数
@property (assign, nonatomic) int cd_sum_pii_count;
// sum_cmi_count ：表示评论总数
@property (assign, nonatomic) int cd_sum_cmi_count;
// sum_fwi_count ：表示转发总数
@property (assign, nonatomic) int cd_sum_fwi_count;

@end
