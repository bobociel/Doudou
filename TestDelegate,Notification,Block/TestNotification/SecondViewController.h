//
//  SecondViewController.h
//  TestNotification
//
//  Created by wangxiaobo on 16/1/11.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^Block)(void);

@class SecondViewController;
@protocol SecondViewControllerDelegate <NSObject>
- (void)secondViewControllerGetInfo:(NSString *)info;
@end

@interface SecondViewController : UITableViewController
@property (nonatomic, assign) id <SecondViewControllerDelegate> delegate;
@property (nonatomic, copy) Block block;
- (void)setBlock:(Block)block;
@end
