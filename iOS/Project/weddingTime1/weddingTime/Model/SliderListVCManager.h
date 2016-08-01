//
//  SliderListVCManager.h
//  lovewith
//
//  Created by imqiuhang on 15/4/9.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <Foundation/Foundation.h>


#define order_field_comment_num  @"comment_num"
#define order_field_price_start  @"price_start"
#define order_field_like_num     @"like_num"
#define order_field_score        @"score"


typedef enum {
    WiddingListVCStyleComm        = 0, //酒店,婚礼等普通列表
    WiddingListVCStyleInspiration = 1  //灵感列表
}WiddingListVCStyle;

typedef enum {
    WiddingListVCSignWeddingveil    = 0,//婚纱摄影
    WiddingListVCSignPlan           = 1,//婚礼策划
    WiddingListVCSignFlower         = 2,//花艺设计
    WiddingListVCSignVideo          = 3,//婚礼摄像
    WiddingListVCSignMakeUp         = 4,//化妆
    WiddingListVCSignHost           = 5,//主持人
    WiddingListVCSignWeddingPhotos  = 6,//婚纱照
    WiddingListVCSignWeddingAddress = 7,//婚纱礼服
    WiddingListVCSignHotel          = 8,//酒店
    WiddingListVCSignInspiration    = 9//灵感
    
}WiddingListVCSign;

typedef enum {
    SliderTypeSupplier    = 0,
    SliderTypeInspiretion = 1,
    SliderTypeHotel       = 2
}SliderType;

@interface SliderListVCInfo : NSObject

@property (nonatomic,strong) NSString           *navTitle;
@property (nonatomic,assign) WiddingListVCStyle widdingListVCStyle;
@property (nonatomic,assign) WiddingListVCSign  widdingListVCSign;
@property (nonatomic,strong) NSString           *apiInfo;
@property (nonatomic,assign) id                 remark;

+ (instancetype)SliderListVCInfoMakeWithTitle:(NSString *)aNavTitle
                                   andVCStyle:(WiddingListVCStyle)style
                                    andVCSign:(WiddingListVCSign)sign
                                    andRemark:(id)remark;

@end


@interface HotelOrSupplierListFilters : NSObject

@property BOOL isFromFilters;

@property int  city_id;
@property int  service;
@property NSIndexPath *index;
@property int  hotel_type;
@property int  price_start;
@property int  price_end;
@property int  desk_start;
@property int  desk_end;
@property WiddingListVCSign sign;
@property (nonatomic,strong) NSString *key_word;
@property (nonatomic,strong) NSString *order_field;
@property (nonatomic, strong) NSMutableArray *hotel_types;
@property (nonatomic, strong) NSMutableArray *key_words;
+ (HotelOrSupplierListFilters *)defaultFilters;

@end




@interface SliderListVCManager : NSObject

+ (NSArray *)getSliderListArr;
+ (NSArray *)getListTitles:(NSArray *)listArr;
+ (NSArray *)getImageswithlistArr:(NSArray *)listArr;
+ (int)getSupplierTypeWithSign:(WiddingListVCSign)sign;


@end
