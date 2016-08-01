//
//  BanquetTableViewCell.h
//  weddingTime
//
//  Created by jakf_17 on 15/9/28.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommTableViewCell.h"

@protocol BanquetCollectionDelegate <NSObject>

- (void)banquetCollectHasSelectedWithBan_id:(NSNumber *)banquet_id;

@end
@interface BanquetTableViewCell : UITableViewCell

@property (nonatomic, assign) id<BanquetCollectionDelegate> delegate;

- (void)setInfo:(id)info;
@end

@interface UITableView (BanquetListCell)

- (BanquetTableViewCell *)banquetCell;
@end