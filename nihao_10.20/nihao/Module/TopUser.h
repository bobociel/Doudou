//
//  TopUser.h
//  nihao
//
//  Created by HelloWorld on 6/17/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopUser : NSObject

@property (nonatomic, assign) int ca_ci_id;
@property (nonatomic, assign) int friend_type;
@property (nonatomic, copy) NSString *ca_date;
@property (nonatomic, copy) NSString *ci_nikename;
@property (nonatomic, copy) NSString *ci_header_img;
@property (nonatomic, copy) NSString *country_name_en;
@property (nonatomic, assign) int sum_cr_count;
@property (nonatomic, assign) int ca_score;
@property (nonatomic, assign) int ci_sex;

@end
