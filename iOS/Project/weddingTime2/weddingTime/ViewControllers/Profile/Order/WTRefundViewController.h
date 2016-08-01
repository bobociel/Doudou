//
//  RefundViewController.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/12.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol RefundDelegate <NSObject>

- (void)refundWithStr:(NSString *)str;

@end
@interface WTRefundViewController : BaseViewController
@property (nonatomic, assign) id<RefundDelegate> delegate;
@end
