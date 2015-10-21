//
//  AskContent.h
//  nihao
//
//  Created by HelloWorld on 7/10/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comment.h"

@interface AskContent : NSObject

//"aki_id": 1,
//"aki_title": "ask信",
//"aki_info": "2ask",
//"aki_source_id": 2,
//"aki_source_nikename": "杨驰",
//"aki_source_header_img": "",
//"aki_source_sex": 1,
//"aki_source_type": 1,
//"aki_best": 458,
//"aki_sum_cmi_count": 2,
//"aki_sum_pii_count": 0,
//"aki_sum_fwi_count": 0,
//"aki_date": "2015-06-19 11:28:05",
//"pictures":
//"bestComment": {
//	"cmi_id": 458,
//	"cmi_info": "我是最佳答案",
//	"cmi_ci_id": 2,
//	"cmi_source_id": 1,
//	"cmi_source_type": 4,
//	"ci_nikename": "nihao_26736982",
//	"ci_header_img": "uploadFiles/2015/6/25/20150625094635_253f2f2a08-d059-4dea-bbf0-e7ee4f24ac6a.jpg",
//	"ci_sex": 1,
//	"cmi_date": "2015-07-10 11:30:50",
//	"comments"

@property (nonatomic, assign) NSInteger aki_id;
@property (nonatomic, assign) NSInteger aki_source_id;
@property (nonatomic, copy) NSString *aki_info;
@property (nonatomic, copy) NSString *aki_source_nikename;
@property (nonatomic, assign) NSInteger aki_sum_fwi_count;
@property (nonatomic, copy) NSString *aki_title;
@property (nonatomic, assign) NSInteger aki_sum_pii_count;
@property (nonatomic, assign) NSInteger aki_sum_cmi_count;
@property (nonatomic, copy) NSString *aki_date;
@property (nonatomic, assign) NSInteger aki_best;
@property (nonatomic, copy) NSString *aki_source_header_img;
@property (nonatomic, assign) NSInteger aki_source_sex;
@property (nonatomic, assign) NSInteger aki_source_type;
@property (nonatomic, strong) NSDictionary *bestComment;

@end
