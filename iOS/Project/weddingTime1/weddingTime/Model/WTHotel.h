//
//  WTHotel.h
//  weddingTime
//
//  Created by wangxiaobo on 16/2/5.
//  Copyright © 2016年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTHotel : NSObject
@property (nonatomic, copy) NSString *ID;

@property (nonatomic,assign) BOOL enable;
@property (nonatomic,assign) BOOL is_like;
@property (nonatomic, assign) double price_start;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *main_pic;
@property (nonatomic, copy) NSString *star;
@property (nonatomic, copy) NSString *score;
@property (nonatomic, copy) NSString *tel;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *map_point;

@property (nonatomic, assign) double comment_num;
@property (nonatomic, assign) double comment_ave;
@property (nonatomic, assign) double desk_num;
@property (nonatomic, assign) double wed_num;

//Custom
@property (nonatomic, assign) double collect_num;
@property (nonatomic, assign) double menu_num;

//Like
@property (nonatomic, assign) double like_count;
@property (nonatomic, assign) double menu_count;

@property (nonatomic, assign) double likeCount;
@property (nonatomic, assign) double menuCount;
@end

@interface WTHotelDetail : NSObject
@property (nonatomic, copy) NSString *hotel_avatar;
@property (nonatomic, copy) NSString *hotel_name;
@property (nonatomic, copy) NSString *hotel_star;
@property (nonatomic, copy) NSString *hotel_city;
@property (nonatomic, copy) NSString *hotel_tel;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, assign) double hotel_price_start;
@property (nonatomic,assign) BOOL is_like;
@property (nonatomic, assign) double like_num;
@property (nonatomic, assign) double hotel_ballroom_num;
@property (nonatomic, assign) double hotel_menu_num;
@property (nonatomic, assign) double hotel_comment_num;
@property (nonatomic,strong) NSMutableArray *hotel_equipment;
@property (nonatomic,strong) NSMutableArray *hotel_ballroom;
@property (nonatomic,strong) NSMutableArray *hotel_menu;
@property (nonatomic,strong) NSMutableArray *hotel_comment;
@end

@interface WTHotelExt : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *value;
@end

@interface WTHotelBallRoom : NSObject
@property (nonatomic, copy) NSString *ballroom_id;
@property (nonatomic, copy) NSString *ballroom_name;
@property (nonatomic, copy) NSString *ballroom_pic;
@property (nonatomic, copy) NSString *ballroom_avatar;
@property (nonatomic, copy) NSString *hotel_name;
@property (nonatomic, copy) NSString *hotel_avatar;
@property (nonatomic, copy) NSString *hotel_star;
@property (nonatomic, strong) NSMutableArray *attach_path;
@property (nonatomic, strong) NSMutableArray *ballroom_info;
@property (nonatomic, strong) NSMutableArray *ballroom_description;
@end

@interface WTHotelMenu : NSObject
@property (nonatomic, copy) NSString *menu_id;
@property (nonatomic, copy) NSString *menu_name;
@property (nonatomic, copy) NSString *menu_description;
@property (nonatomic, assign) double menu_price;
@property (nonatomic, strong) NSMutableArray *menu_menu;
@end

@interface WTHotelComment : NSObject
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *comment_author_avatar;
@property (nonatomic, copy) NSString *comment_author_name;
@property (nonatomic, copy) NSString *comment_content;
@property (nonatomic, copy) NSString *comment_star;
@end

