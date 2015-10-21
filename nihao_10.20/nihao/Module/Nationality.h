//
//  Nationality.h
//  nihao 国籍
//
//  Created by 刘志 on 15/6/10.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Nationality : NSObject<NSCopying>

@property (nonatomic,assign) NSInteger country_id;

@property (nonatomic,copy) NSString *country_name_en;

@end
