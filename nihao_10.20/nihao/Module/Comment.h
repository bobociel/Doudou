//
//  Comment.h
//  nihao
//
//  Created by HelloWorld on 6/23/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject

//comments：动态的评论
//cmi_id：评论ID
@property (assign, nonatomic) int cmi_id;
//cmi_info：评论内容
@property (copy, nonatomic) NSString *cmi_info;
//cmi_ci_id：评论人ID
@property (assign, nonatomic) int cmi_ci_id;
//ci_nikename：评论人的昵称
@property (copy, nonatomic) NSString *ci_nikename;
//ci_header_img：评论人的头像
@property (copy, nonatomic) NSString *ci_header_img;
//ci_sex：评论人的性别
@property (assign, nonatomic) int ci_sex;
//cmi_source_id：如果cmi_source_type=1则此字段为动态ID，如果cmi_source_type=2则此字段为回复评论的评论ID
@property (assign, nonatomic) int cmi_source_id;
//cmi_source_type：评论状态：1  动态      2  回复评论
@property (assign, nonatomic) int cmi_source_type;
//cmi_source_nikename：被评论人的 id
@property (copy, nonatomic) NSString *cmi_source_ci_id;
//cmi_source_nikename：被评论人的昵称
@property (copy, nonatomic) NSString *cmi_source_nikename;
//cmi_source_header_img：被评论人的头像
@property (copy, nonatomic) NSString *cmi_source_header_img;
//cmi_source_sex：被评论人的性别
@property (assign, nonatomic) int cmi_source_sex;
//cmi_date：评论时间
@property (copy, nonatomic) NSString *cmi_date;
//comments：对评论的回复列表
@property (strong, nonatomic) NSMutableArray *comments;

//showComments：显示的回复列表，只用在 Ask 的详情界面
@property (strong, nonatomic) NSMutableArray *showComments;


@end
