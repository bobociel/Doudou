//
//  YHYunHuoPageOrderViewController.h
//  YunHuo
//
//  Created by yuyunfeng on 15-1-12.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHYunHuoPageOrderViewController : UIViewController
{
    @public
    NSArray * _pagesArr;
    NSMutableArray * _viewArr1;
    NSMutableArray * _viewArr2;
}
@property (nonatomic) NSString *orderSourceFile;

@property (nonatomic) UILabel * titleLabel;
@property (nonatomic) UILabel * titleLabel2;
@property (nonatomic) NSArray * titleArr;
@property (nonatomic) NSArray * urlStringArr;

- (IBAction) finishOrder;
@end
