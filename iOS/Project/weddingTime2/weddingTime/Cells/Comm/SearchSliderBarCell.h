//
//  SearchSliderBarCell.h
//  lovewith
//
//  Created by imqiuhang on 15/4/29.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#define SearchSliderBarCellHeigh 120
typedef enum {
   SearchSliderBarCellStyleTable = 0,
   SearchSliderBarCellStylePrice = 1
}SearchSliderBarCellStyle;

@protocol SearchSliderBarCellDelegate <NSObject>

- (void)slideVauleDidChanged:(SearchSliderBarCellStyle)aStyle andleftValue:(int)lValue adnRightValue:(int)rValue;

@end

@interface SearchSliderBarCell : UITableViewCell

@property SearchSliderBarCellStyle searchStyle;

- (void)setLower:(float)lower Upper:(float)upper;
- (void)startWithStyle:(SearchSliderBarCellStyle)aStyle;
- (void)reset;
- (void)animad;
@property (nonatomic,weak)id<SearchSliderBarCellDelegate>slideDelegate;
@end



@interface UITableView (SearchSliderBarCell)

- (SearchSliderBarCell *)SearchSliderBarCell;

@end