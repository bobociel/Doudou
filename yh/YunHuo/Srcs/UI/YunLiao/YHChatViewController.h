//
//  YHChatViewController.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/12.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMGroup.h"

@interface YHChatViewController : UIViewController
@property (nonatomic) id chatTarget;

- (instancetype) initWithChatter:(NSString *)chatter;
- (instancetype) initWithGroup:(EMGroup *)chatGroup;
- (IBAction) onShare:(id)sender;

@end
