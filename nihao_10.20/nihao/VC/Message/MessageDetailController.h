//
//  MessageDetailController.h
//  nihoo
//
//  Created by 刘志 on 15/4/21.
//  Copyright (c) 2015年 nihoo. All rights reserved.
//

#import "JSMessagesViewController.h"
@class EMConversation;

@interface MessageDetailController : JSMessagesViewController

//聊天标题
@property (nonatomic, copy) NSString *chatTitle;
@property (nonatomic, copy) EMConversation *conversation;

@end
