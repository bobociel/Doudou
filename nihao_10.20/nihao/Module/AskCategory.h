//
//  AskCategory.h
//  nihao
//
//  Created by HelloWorld on 7/9/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AskCategory : NSObject

//"akc_aki_count" = 1;
//"akc_id" = 1;
//"akc_img" = "uploadFiles\\2015\\6\\18\\20150618172631_501286bf65e-d24d-492f-ab7a-fb7949b1d4f6.jpg";
//"akc_name" = "ask\U5217\U8868\U6d4b\U8bd52";

@property (nonatomic, assign) NSInteger akc_aki_count;
@property (nonatomic, assign) NSInteger akc_id;
@property (nonatomic, copy) NSString *akc_img;
@property (nonatomic, copy) NSString *akc_name;

@end
