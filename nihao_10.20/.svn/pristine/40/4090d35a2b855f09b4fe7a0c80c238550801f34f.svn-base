//
//  MessageCell.h
//  nihoo
//
//  Created by 刘志 on 15/4/21.
//  Copyright (c) 2015年 nihoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"
@class EMConversation;
@class ContactDao;

@interface MessageCell : MGSwipeTableCell

@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UIView *badge;

@property (nonatomic, strong) ContactDao *dao;

- (void) loadData : (EMConversation *) conversation;

@end
