//
//  MerchantComment.h
//  nihao
//
//  Created by HelloWorld on 8/18/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Picture.h"
#import "MerchantsScore.h"

@interface MerchantComment : NSObject

@property (nonatomic, copy) NSString *ci_header_img;
@property (nonatomic, copy) NSString *ci_nikename;
@property (nonatomic, copy) NSString *cmi_date;
@property (nonatomic, copy) NSString *cmi_info;
@property (nonatomic, assign) NSInteger ci_id;
@property (nonatomic, assign) NSInteger ci_sex;
@property (nonatomic, assign) NSInteger cmi_ci_id;
@property (nonatomic, assign) NSInteger cmi_id;
@property (nonatomic, assign) NSInteger cmi_source_id;
@property (nonatomic, assign) NSInteger cmi_source_type;
@property (nonatomic, strong) NSMutableArray *pictures;// 图片数组
@property (nonatomic, strong) MerchantsScore *merchantsScore;// 评分

@end
