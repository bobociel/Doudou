//
//  webViewCellTableViewCell.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/16.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface webViewCellTableViewCell : UITableViewCell
- (void)setInfo:(id)info;
@end

@interface UITableView (webViewCell)
- (webViewCellTableViewCell *)webViewCell;
@end