//
//  ComboListTableViewCell.h
//  weddingTime
//
//  Created by jakf_17 on 15/9/28.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTHotel.h"
@protocol ComboCellDelegate <NSObject>
- (void)comboCellHasSelectedWithMenu_id:(NSString *)menu_id;
@end

@interface ComboListTableViewCell : UITableViewCell
@property (nonatomic, assign) id<ComboCellDelegate> delegate;
- (void)setInfo:(id)info;
@end

@interface UITableView (ComboListCell)
- (ComboListTableViewCell *)comboCell;
@end