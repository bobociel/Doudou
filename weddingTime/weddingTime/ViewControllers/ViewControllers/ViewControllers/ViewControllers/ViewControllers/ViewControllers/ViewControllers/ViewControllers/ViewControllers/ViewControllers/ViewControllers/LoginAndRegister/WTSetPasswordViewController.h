//
//  WTSetPasswordViewController.h
//  weddingTime
//
//  Created by _Cuixin on 15/9/17.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTFindBackPasswordViewController.h"
#import "BaseViewController.h"
@interface WTSetPasswordViewController : BaseViewController
@property (nonatomic,strong) NSString *account_info;
@property (nonatomic,strong) NSString *confirm_key;
@end
