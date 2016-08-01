//
//  WTHotel.m
//  weddingTime
//
//  Created by wangxiaobo on 16/2/5.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTHotel.h"

@implementation WTHotel
- (instancetype)init
{
    self = [super init];
    if(self){
        self.ID = @"";
        
        self.enable = NO;
        self.is_like = NO;
        self.name = @"";
        self.main_pic = @"";
        self.address = @"";
        self.price_start = 0;
        self.star = @"";
        self.score = @"";
        self.tel = @"";
        self.address = @"";
        self.map_point = @"";
    
        self.comment_num = 0;
        self.comment_ave = 0;
        self.desk_num = 0;
        self.wed_num = 0;
        
        self.collect_num = 0;
        self.menu_num = 0;

        self.like_count = 0;
        self.menu_count = 0;
    }
    return self;
}

- (double)likeCount
{
	return _likeCount ? : (_collect_num ? : _like_count);
}

- (double)menuCount
{
    return _menu_num > 0  ? _menu_num : _menu_count;
}

+ (NSDictionary *)modelCustomPropertyMapper{
    return @{@"ID":@"id"};
}

+ (NSArray *)modelPropertyBlacklist
{
    return @[@"hash",@"description",@"debugDescription",@"superclass"];
}
@end

@implementation WTHotelDetail
- (instancetype)init
{
	self = [super init];
	if(self)
	{
		self.hotel_avatar = @"";
		self.hotel_name = @"";
		self.hotel_star = @"";
		self.hotel_city = @"";
		self.hotel_tel = @"";
		self.phone = @"";
		self.is_like = NO;
		self.hotel_price_start = 0;
		self.like_num = 0;
		self.hotel_ballroom_num = 0;
		self.hotel_menu_num = 0;
		self.hotel_comment_num = 0;
		self.hotel_equipment = [NSMutableArray array];
		self.hotel_ballroom = [NSMutableArray array];
		self.hotel_menu = [NSMutableArray array];
		self.hotel_comment = [NSMutableArray array];
	}
	return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
	return @{@"hotel_ballroom" : [WTHotelBallRoom class],
			 @"hotel_menu" : [WTHotelMenu class],
			 @"hotel_comment" : [WTHotelComment class] };
}

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

@end

@implementation WTHotelBallRoom
- (instancetype)init
{
	self = [super init];
	if(self)
	{
		self.ballroom_id = @"";
		self.ballroom_name = @"";
		self.ballroom_pic = @"";
		self.ballroom_avatar = @"";
		self.hotel_name = @"";
		self.hotel_avatar = @"";
		self.hotel_star = @"";
		self.attach_path = [NSMutableArray array];
		self.ballroom_info = [NSMutableArray array];
		self.ballroom_description = [NSMutableArray array];
	}
	return self;
}

+ (NSDictionary *)modelCustomPropertyMapper {
	return @{@"ballroom_description" : @"ballroom_description.ext"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
	return @{@"ballroom_info" : [WTHotelExt class],@"ballroom_description":[WTHotelExt class]};
}

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

@end

@implementation WTHotelExt
- (instancetype)init
{
	self = [super init];
	if(self)
	{
		self.name = @"";
		self.value = @"";
	}
	return self;
}

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}

@end

@implementation WTHotelMenu
- (instancetype)init
{
	self = [super init];
	if(self)
	{
		self.menu_id = @"";
		self.menu_name = @"";
		self.menu_price = 0;
		self.menu_description = @"";
		self.menu_menu = [NSMutableArray array];
	}
	return self;
}

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}
@end

@implementation WTHotelComment
- (instancetype)init
{
	self = [super init];
	if(self)
	{
		self.ID = @"";
		self.comment_author_avatar = @"";
		self.comment_author_name = @"";
		self.comment_content = @"";
		self.comment_star = @"";
	}
	return self;
}

+ (NSDictionary *)modelCustomPropertyMapper{
	return @{@"ID":@"id"};
}

+ (NSArray *)modelPropertyBlacklist
{
	return @[@"hash",@"description",@"debugDescription",@"superclass"];
}
@end

