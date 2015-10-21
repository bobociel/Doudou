//
//  blackListView.h
//  demo
//
//  Created by Apple on 15/9/24.
//  Copyright (c) 2015年 LP. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol BlackListBtnDelegate <NSObject>

-(void)BlackListBtnDelegateBtnClick:(UIButton*)sender;


@end
@interface BlackListView : UIView

@property (nonatomic,assign)id <BlackListBtnDelegate>delegate;

@end
