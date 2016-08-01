//
//  ChatListViewController.h
//  weddingTime
//
//  Created by 默默 on 15/9/25.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "BaseViewController.h"

@interface ListErrorBtn : UIButton
-(void)setBtnWithTitle:(NSString*)title tapBlock:(void(^)())tap;
-(void)hide;
-(void)showInView:(UIView*)view center:(CGPoint)point;
@end
@class UserInfo;
@interface WTChatListViewController : BaseViewController
@end
