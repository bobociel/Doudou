//
//  SliderListVCManager.m
//  lovewith
//
//  Created by imqiuhang on 15/4/9.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "SliderListVCManager.h"

@implementation SliderListVCInfo

+ (instancetype)SliderListVCInfoMakeWithTitle:(NSString *)aNavTitle
                                   andVCStyle:(WiddingListVCStyle)style
                                    andVCSign:(WiddingListVCSign)sign
                                    andRemark:(id)remark {
    SliderListVCInfo *info = [[SliderListVCInfo alloc] init];
    info.navTitle = aNavTitle;
    info.widdingListVCStyle = style;
    info.widdingListVCSign = sign;
    info.remark = remark;
    return info;
}

@end

@implementation HotelOrSupplierListFilters

+ (HotelOrSupplierListFilters *)defaultFilters {
    HotelOrSupplierListFilters *dHotelListFilters = [[HotelOrSupplierListFilters alloc] init];
    dHotelListFilters.isFromFilters = NO;
    dHotelListFilters.city_id       = -1;
    dHotelListFilters.service       = -1;
    dHotelListFilters.order_field   = @"";

    dHotelListFilters.hotel_type    = -1;

    dHotelListFilters.price_start   = -1;
    dHotelListFilters.price_end     = -1;
    dHotelListFilters.desk_start    = -1;
    dHotelListFilters.desk_end      = -1;

    dHotelListFilters.key_word      = @"";
    dHotelListFilters.key_words = [NSMutableArray array];
    dHotelListFilters.hotel_types = [NSMutableArray array];
    return dHotelListFilters;
}

@end

@implementation SliderListVCManager

+ (NSArray *)getSliderListArr {
    NSArray *sliderListArr;
    sliderListArr =
    @[
      
      [SliderListVCInfo SliderListVCInfoMakeWithTitle:@"婚礼策划"
                                           andVCStyle:WiddingListVCStyleComm
                                            andVCSign:WiddingListVCSignPlan
                                            andRemark:nil],
      
      [SliderListVCInfo SliderListVCInfoMakeWithTitle:@"婚纱影楼"
                                           andVCStyle:WiddingListVCStyleComm
                                            andVCSign:WiddingListVCSignWeddingPhotos
                                            andRemark:nil],
      
      [SliderListVCInfo SliderListVCInfoMakeWithTitle:@"婚礼跟拍"
                                           andVCStyle:WiddingListVCStyleComm
                                            andVCSign:WiddingListVCSignWeddingveil
                                            andRemark:nil],
      
      [SliderListVCInfo SliderListVCInfoMakeWithTitle:@"婚礼摄像"
                                           andVCStyle:WiddingListVCStyleComm
                                            andVCSign:WiddingListVCSignVideo
                                            andRemark:nil],
      [SliderListVCInfo SliderListVCInfoMakeWithTitle:@"婚纱礼服"
                                           andVCStyle:WiddingListVCStyleComm
                                            andVCSign:WiddingListVCSignWeddingAddress
                                            andRemark:nil],
      
      [SliderListVCInfo SliderListVCInfoMakeWithTitle:@"化妆造型"
                                           andVCStyle:WiddingListVCStyleComm
                                            andVCSign:WiddingListVCSignMakeUp
                                            andRemark:nil],
      
      [SliderListVCInfo SliderListVCInfoMakeWithTitle:@"主持人"
                                           andVCStyle:WiddingListVCStyleComm
                                            andVCSign:WiddingListVCSignHost
                                            andRemark:nil],

      
      [SliderListVCInfo SliderListVCInfoMakeWithTitle:@"婚宴酒店"
                                           andVCStyle:WiddingListVCStyleComm
                                            andVCSign:WiddingListVCSignHotel
                                            andRemark:nil],
      
      [SliderListVCInfo SliderListVCInfoMakeWithTitle:@"婚礼灵感"
                                           andVCStyle:WiddingListVCStyleInspiration
                                            andVCSign:WiddingListVCSignInspiration
                                            andRemark:nil],

      ];
    
    return sliderListArr;
}


+ (NSArray *)getImageswithlistArr:(NSArray *)listArr {
    NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:15];
    for (SliderListVCInfo *info in listArr) {
        NSDictionary *dic = @{@"pink":[self getPinkImageNameWithWiddingListVCSign:info.widdingListVCSign],
                              @"gray":[self getGaryImageNameWithWiddingListVCSign:info.widdingListVCSign]};
        [images addObject:dic];
    }
    
    return [images copy];
}


+ (NSString *)getGaryImageNameWithWiddingListVCSign:(WiddingListVCSign)widdingListVCSign {
    switch (widdingListVCSign) {
        case WiddingListVCSignWeddingveil:
            return @"ws_gengpai_gray";
        case WiddingListVCSignPlan:
            return @"ws_leimu_gray";
        case WiddingListVCSignWeddingPhotos:
            return @"ws_yinglou_gray";
        case WiddingListVCSignVideo:
            return @"ws_shexiang_gray";
        case WiddingListVCSignMakeUp:
            return @"ws_zaoxin_gray";
        case WiddingListVCSignHost:
            return @"ws_zhuchi_gray";
        case WiddingListVCSignInspiration:
            return @"ws_lingan_gray";
        case WiddingListVCSignHotel:
            return @"ws_jiudian_gray";
        case WiddingListVCSignWeddingAddress:
            return @"ws_hunsha_gray";
        default:
            return @"";
            break;
    }
 
}

+ (NSString *)getPinkImageNameWithWiddingListVCSign:(WiddingListVCSign)widdingListVCSign {
    switch (widdingListVCSign) {
        case WiddingListVCSignWeddingveil:
            return @"ws_gengpai_pink";
        case WiddingListVCSignPlan:
            return @"ws_leimu_pink";
        case WiddingListVCSignWeddingPhotos:
            return @"ws_yinglou_pink";
        case WiddingListVCSignVideo:
            return @"ws_shexiang_pink";
        case WiddingListVCSignMakeUp:
            return @"ws_zaoxin_pink";
        case WiddingListVCSignHost:
            return @"ws_zhuchi_pink";
        case WiddingListVCSignInspiration:
            return @"ws_lingan_pink";
        case WiddingListVCSignHotel:
            return @"ws_jiudian_pink";
        case WiddingListVCSignWeddingAddress:
            return @"ws_hunsha_pink";
        default:
            return @"";
            break;
    }
    
}


+ (int)getSupplierTypeWithSign:(WiddingListVCSign)sign {
    switch (sign) {
        case WiddingListVCSignWeddingveil:
            return 7;
        case WiddingListVCSignPlan:
            return 6;
        case WiddingListVCSignVideo:
            return 12;
        case WiddingListVCSignMakeUp:
            return 8;
        case WiddingListVCSignHost:
            return 14;
        case WiddingListVCSignWeddingAddress:
            return 9;
        case WiddingListVCSignWeddingPhotos:
            return 11;
        default:
            return 0;
            break;
    }
    //    6	    婚礼策划
    //    7	    婚礼摄影
    //    8	    化妆造型
    //    9	    婚纱礼服
    //    10	花艺设计
    //    11	婚纱写真
    //    12	婚礼摄像
    //    13	婚戒珠宝
    //    14	婚礼主持
    //    15	婚礼场地
    //    16	蛋糕甜品
    //    17	定制商品
    //    19	蜜月旅行
    //    20	婚房家居
    //    21	其他
}

+ (NSArray *)getListTitles:(NSArray *)listArr {
    NSMutableArray *titles = [[NSMutableArray alloc] initWithCapacity:15];
    for (SliderListVCInfo *info in listArr) {
        [titles addObject:info.navTitle];
    }
    
    return [titles copy];
}

@end
