//
//  TouchView.h
//  TouchDemo
//
//  Created by Zer0 on 13-10-11.
//  Copyright (c) 2013年 Zer0. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YHYunHuoPageInfo;
@interface TouchView : UIImageView
{
    CGPoint _point;
    CGPoint _point2;
    NSInteger _sign;
    @public
    
    NSMutableArray * _array;
    NSMutableArray * _viewArr11;
    NSMutableArray * _viewArr22;
}
@property (nonatomic) UILabel * label;
@property (nonatomic) UILabel * moreChannelsLabel;
@property (nonatomic) YHYunHuoPageInfo *pageInfo;
@end
