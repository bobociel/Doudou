//
//  ChatHistoryCell.h
//  nihao
//
//  Created by 吴梦婷 on 15/10/13.
//  Copyright (c) 2015年 boru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatHistoryModel.h"
@interface ChatHistoryCell : UITableViewCell

-(void)loadData:(ChatHistoryModel *)chatHistory;

@end
