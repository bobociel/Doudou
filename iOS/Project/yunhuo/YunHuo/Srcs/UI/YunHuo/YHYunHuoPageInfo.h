//
//  TouchViewModel.h
//  ifengNewsOrderDemo
//
//  Created by zer0 on 14-2-27.
//  Copyright (c) 2014年 zer0. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHYunHuoPageInfo : NSObject<NSCoding>

@property (nonatomic,copy) NSString			*name;
@property (nonatomic,copy) NSString			*icon;
@property (nonatomic) int					index;
@property (nonatomic) BOOL					enabled;
@property (nonatomic,copy) NSString			*pageControllerClass;

- (instancetype) initWithDictionary:(NSDictionary*)dict;
- (NSDictionary*) toDictionary;

@end
