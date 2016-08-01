//
//  LikeListViewController.h
//  weddingTime
//
//  Created by jakf_17 on 15/9/19.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger,LikeType){
    LikeTypeSupplier    = 1,
    LikeTypeHotel       = 2,
    LikeTypeInspiretion = 3,
    LikeTypePost = 4
};

@interface WTLikeListViewController : BaseViewController

@end
