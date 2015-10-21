//
//  City.h
//  nihao
//
//  Created by 刘志 on 15/6/1.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface City : NSObject

@property (nonatomic,assign) int city_id;

@property (nonatomic,copy) NSString *city_name_en;

@property (nonatomic,copy) NSString *city_name;

/**
 * @desc :将city对象保存到userdefault里
 * @param : city city对象
 * @param : key 键值
 *
 */
+ (void) saveCityToUserDefault : (City *) city key : (NSString *)key;

/**
 * @desc :从userdefault里读取city对象
 * @param : key 键值
 *
 */
+ (City *) getCityFromUserDefault : (NSString *) key;

/**
 *  从userdefault里读取city对象
 *
 *  @return
 */
+ (NSArray *) getCityListFromUserDefault;

/**
 *  将支持的城市列表存放到userdefault
 *
 *  @param cityList 城市列表
 */
+ (void) saveCityListToUserDefault : (NSArray *) cityList;
@end
