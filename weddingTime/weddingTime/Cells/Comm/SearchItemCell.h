//
//  SearchItemCell.h
//  lovewith
//
//  Created by imqiuhang on 15/4/30.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

typedef enum {
    SearchItemCellStyleType = 0,
    SearchItemCellStyleItem = 1
}SearchItemCellStyle;

@protocol SearchItemCellDelegate <NSObject>
- (void)SearchItemCellDidChangedIndexs:(NSArray *)indexs andFromStyle:(SearchItemCellStyle)cellStyle;
@end

@interface SearchItemCell : UITableViewCell
@property SearchItemCellStyle searchStyle;
@property (nonatomic,weak)id<SearchItemCellDelegate>itemDelegate;
- (void)startWithStyle:(SearchItemCellStyle)aStyle;
- (void)reset;

+ (CGFloat)getHeightWithStyle:(SearchItemCellStyle)style;

@end

@interface UITableView (SearchItemCell)
- (SearchItemCell *)SearchItemCell;
@end