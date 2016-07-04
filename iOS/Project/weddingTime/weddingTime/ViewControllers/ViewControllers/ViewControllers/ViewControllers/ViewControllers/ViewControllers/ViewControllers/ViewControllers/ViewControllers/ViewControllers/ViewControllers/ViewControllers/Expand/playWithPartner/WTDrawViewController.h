//
//  DrawViewController.h
//  lovewith
//
//  Created by imqiuhang on 15/4/22.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "DrawPaletteView.h"

@interface WTDrawViewController : BaseViewController
+(void)pushViewControllerWithRootViewController:(UIViewController*)root isFromJoin:(BOOL)isFromJoin isFromChat:(BOOL)isFromChat;
@property (weak, nonatomic) IBOutlet DrawPaletteView *drawPaletteView;
@property (weak, nonatomic) IBOutlet UIView    *bottomView;
@property (weak, nonatomic) IBOutlet UIButton  *rubberBtn;
@property (weak, nonatomic) IBOutlet UIButton  *cleanBtn;
@property (weak, nonatomic) IBOutlet UIButton  *chooseWidthBtn;
@property (weak, nonatomic) IBOutlet UIButton  *changeColorBtn;

@property BOOL isFromJoin;
@property BOOL isFromChat;
@end
