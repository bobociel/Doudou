//
//  QHNavigationController.h
//  QHNavigationController
//
//
//  Created by momo on 15/6/25.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QHNavigationController : UINavigationController<UIGestureRecognizerDelegate,UINavigationControllerDelegate>
@property(nonatomic,unsafe_unretained) UIViewController* currentShowVC;

@end
