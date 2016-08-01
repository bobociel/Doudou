//
//  KissViewController.h
//  lovewith
//
//  Created by imqiuhang on 15/4/22.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ChatConversationManager.h"


@interface WTKissViewController : BaseViewController
@property BOOL isFromJoin;
+(void)pushViewControllerWithRootViewController:(UIViewController*)root isFromJoin:(BOOL)isFromJoin;
@end
