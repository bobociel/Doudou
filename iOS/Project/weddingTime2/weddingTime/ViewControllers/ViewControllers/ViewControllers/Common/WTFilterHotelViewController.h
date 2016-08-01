//
//  FilterHotelViewController.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/8.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "SliderListVCManager.h"
typedef enum {
    SearchCellKeySynNormal   = 0,
    SearchCellKeySynLike = 1,
    SearchCellKeySynComment = 2,
    SearchCellKeyTable = 3,
    SearchCellKeyPrice = 4,
    SearchCellKeyType  = 5,
    SearchCellKeyItem  = 6
}SearchCellKey;
@protocol SearchScreeningContentViewDelegate <NSObject>

- (void)didChooseScreening:(HotelOrSupplierListFilters *)filters;

@end

@interface WTFilterHotelViewController : BaseViewController

@property (nonatomic,strong) HotelOrSupplierListFilters *filters;
@property (nonatomic,weak)id<SearchScreeningContentViewDelegate>delegate;
@end
