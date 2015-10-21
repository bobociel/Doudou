//
//  AskReplyTableViewCell.h
//  nihao
//
//  Created by 刘志 on 15/8/16.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AskCommentNotification.h"

@interface AskReplyTableViewCell : UITableViewCell

- (void) configureAskReplyCell : (AskCommentNotification *) notification;

@end
