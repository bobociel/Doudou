//
//  News.h
//  nihao
//
//  Created by HelloWorld on 6/17/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <Foundation/Foundation.h>

//@interface Picture : NSObject
//@property (nonatomic, assign) int picture_pertain_id;
//@property (nonatomic, copy) NSString *picture_network_url;// 新闻图片的地址
//@end

@interface News : NSObject

@property (nonatomic, assign) int ni_id;// 新闻ID
@property (nonatomic, copy) NSString *ni_title;// 新闻标题
@property (nonatomic, copy) NSString *ni_introduction;// 新闻描述
@property (nonatomic, copy) NSString *ni_date;// 新闻发布时间
@property (nonatomic, assign) int ni_sum_pii_count;// 新闻点赞数量
@property (nonatomic, assign) int ni_sum_cmi_count;// 新闻评论数量
@property (nonatomic, assign) int ni_sum_fwi_count;// 新闻转发数量
@property (nonatomic, strong) NSArray *pictures;// 新闻的图片数组
//pii_is_praise ：是否已经点赞    0：未点赞   1：已点赞
@property (nonatomic, assign) NSInteger pii_is_praise;

@end
