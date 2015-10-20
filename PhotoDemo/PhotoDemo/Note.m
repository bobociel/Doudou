//
//  Note.m
//  PhotoDemo
//
//  Created by hangzhou on 15/9/29.
//  Copyright (c) 2015年 hangzhou. All rights reserved.
//

#import "Note.h"

@implementation Note

+(JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"note_id":@"noteid",
                                                       @"create_user":@"createUser",
                                                       @"create_time":@"createTime",
                                                       @"update_time":@"updateTime",
                                                       @"contents":@"contents",
                                                       @"picture":@"picture",
                                                       @"voice":@"voice"
                                                       }];
}
@end
