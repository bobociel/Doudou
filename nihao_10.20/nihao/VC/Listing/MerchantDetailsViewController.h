//
//  MerchantDetailsViewController.h
//  nihao
//
//  Created by HelloWorld on 8/14/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class Merchant;

@interface MerchantDetailsViewController : BaseViewController

/* 商户详情数据 */
@property (nonatomic) Merchant *merchantInfo;

@end
