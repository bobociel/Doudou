//
//  ImproveMyInformationViewController.h
//  weddingTime
//
//  Created by _Cuixin on 15/9/17.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface ImproveMyInformationViewController :BaseViewController
+ (instancetype)instanceVCWithPhone:(NSString *)phone pwd:(NSString *)pwd token:(NSString *)token;
@end
