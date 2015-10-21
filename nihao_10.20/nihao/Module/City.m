//
//  City.m
//  nihao
//
//  Created by 刘志 on 15/6/1.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "City.h"
#import "AppConfigure.h"

@implementation City

+ (void) saveCityToUserDefault : (City *) city key:(NSString *)key {
     NSData * dataobject = [NSKeyedArchiver archivedDataWithRootObject:city];
    [AppConfigure setObject:dataobject ForKey:key];
}

+ (City *) getCityFromUserDefault : (NSString *) key{
    NSData *data = [AppConfigure objectForKey:key];
    City *city = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return city;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.city_id = [aDecoder decodeIntForKey:@"city_id"];
        self.city_name = [aDecoder decodeObjectForKey:@"city_name"];
        self.city_name_en = [aDecoder decodeObjectForKey:@"city_name_en"];
    }
    return  self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt:self.city_id forKey:@"city_id"];
    [aCoder encodeObject:self.city_name forKey:@"city_name"];
    [aCoder encodeObject:self.city_name_en forKey:@"city_name_en"];
}

+ (NSArray *) getCityListFromUserDefault {
    NSData *data = [AppConfigure objectForKey:CITY_LIST];
    NSArray *cityList = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return cityList;
}

+ (void) saveCityListToUserDefault:(NSArray *)cityList {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cityList];
    [AppConfigure setObject:data ForKey:CITY_LIST];
}

@end
