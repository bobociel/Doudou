//
//  RemarksView.h
//  demo
//
//  Created by Apple on 15/9/24.
//  Copyright (c) 2015年 LP. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RemarksBtnDelegate <NSObject>

-(void)RemarksDelegateBtnClick:(UIButton*)sender;


@end


@interface RemarksView : UIView<RemarksBtnDelegate>

@property (nonatomic,assign)id <RemarksBtnDelegate>delegate;

@property (nonatomic, strong) UITextField *textField;

@end
