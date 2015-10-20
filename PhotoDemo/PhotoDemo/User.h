//
//  User.h
//  PhotoDemo
//
//  Created by hangzhou on 15/9/29.
//  Copyright (c) 2015年 hangzhou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : JSONModel
@property (nonatomic,copy) NSString *user_id;
@property (nonatomic,copy) NSString *user_name;
@property (nonatomic,copy) NSString *user_logo;
@end
