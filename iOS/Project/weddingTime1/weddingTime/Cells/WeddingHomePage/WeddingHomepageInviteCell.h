//
//  WeddingHomepageInviteCell.h
//  lovewith
//
//  Created by imqiuhang on 15/5/15.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "CommTableViewCell.h"

@interface WeddingHomepageInviteCell : CommTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLable;
@property (weak, nonatomic) IBOutlet UIImageView *lineView;

@end



@interface UITableView(WeddingHomepageInviteCell)

- (WeddingHomepageInviteCell *) WeddingHomepageInviteCell;

@end