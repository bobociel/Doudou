//
//  LikeNotification.h
//  nihao
//
//  Created by 刘志 on 15/8/18.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LikeNotification : NSObject

@property (nonatomic,assign) NSUInteger cd_id;
@property (nonatomic,copy) NSString *cd_info;
@property (nonatomic,copy) NSString *ci_header_img;
@property (nonatomic,assign) NSUInteger ci_id;
@property (nonatomic,copy) NSString *ci_nikename;
@property (nonatomic,copy) NSString *ci_username;
@property (nonatomic,copy) NSString *picture_small_network_url;
@property (nonatomic,copy) NSString *pii_date;
@property (nonatomic,assign) NSUInteger pii_id;

@end
