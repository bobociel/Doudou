//
//  CommonTableViewCell.h
//  weddingTime
//
//  Created by jakf_17 on 15/9/19.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SliderListVCManager.h"
@protocol CancelLikeDelegate <NSObject>
@optional
- (void)cancelLikeNum:(NSInteger)num;
- (void)refreshArrayWithRow:(NSInteger)row isLike:(NSNumber *)is_like;
@end
@interface CommonTableViewCell : UITableViewCell

@property (nonatomic, assign) BOOL shadowSign;

@property (nonatomic, assign) WiddingListVCSign supplier_type;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) BOOL isLike;
@property (nonatomic, assign) BOOL ifSH;
@property (nonatomic, strong) NSNumber *service_id;
@property (nonatomic, weak) id<CancelLikeDelegate> delegate;
@property (nonatomic, strong) id info;

- (void)setUIWithInfo:(id)info;
@end


@interface UITableView(CommWeddingListCell)

- (CommonTableViewCell *) commonCell;
@end