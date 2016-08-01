//
//  FilterHotelViewController.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/8.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "BaseViewController.h"
typedef enum {
    SearchCellKeySynNormal   = 0,
    SearchCellKeySynLike = 1,
    SearchCellKeySynComment = 2,
    SearchCellKeyTable = 3,
    SearchCellKeyPrice = 4,
    SearchCellKeyType  = 5,
    SearchCellKeyItem  = 6
}SearchCellKey;

@interface WTHotelFilters : NSObject
@property (nonatomic,strong) NSNumber  *hotel_type;
@property (nonatomic,strong) NSNumber  *price_start;
@property (nonatomic,strong) NSNumber  *price_end;
@property (nonatomic,strong) NSNumber  *desk_start;
@property (nonatomic,strong) NSNumber  *desk_end;
@property (nonatomic,copy)   NSString  *key_word;
@property (nonatomic,copy)   NSString  *order;
@property (nonatomic,copy)   NSString  *order_field;
@end

@protocol SearchScreeningContentViewDelegate <NSObject>
- (void)didChooseScreening:(WTHotelFilters *)filters;
@end

@interface WTFilterHotelViewController : BaseViewController
@property (nonatomic,weak)id<SearchScreeningContentViewDelegate>delegate;
+ (instancetype)instanceVCWithFilters:(WTHotelFilters *)filters;
@end