//
//  CommPickView.h
//  lovewith
//
//  Created by imqiuhang on 15/5/19.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTTicketCell.h"
#define kOneDay  (3600 * 24 )
#define kOneWeek (3600 * 24 * 7)
typedef NS_ENUM(NSUInteger,PickViewType) {
	PickViewTypeCurrentDay,
	PickViewTypeBeforeOneDay,
	PickViewTypeBeforeOneWeek
};
typedef NS_ENUM(NSUInteger,PickViewStyle) {
    PickViewStylePicker,
    PickViewStyleTable
};

@protocol CommPickViewDelegate <NSObject>
- (void)didPickObjectWithIndex:(int)index andTag:(NSInteger)tag;
@end

@interface CommPickView : UIView
@property (nonatomic,strong) NSMutableArray   *dataArray;
@property (nonatomic,weak)id<CommPickViewDelegate>delagate;
+ (instancetype)instanceWithStyle:(PickViewStyle)style andTag:(NSInteger)tag andArray:(NSArray *)dataArray;
- (void)show ;
@end
