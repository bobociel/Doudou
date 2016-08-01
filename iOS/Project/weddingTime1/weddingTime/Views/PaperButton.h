//
//  PaperButton.h
//  lovewith
//
//  Created by imqiuhang on 15/4/2.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PaperButtonDelegate <NSObject>
@optional
-(void)toMenuAction;
-(void)toCloseAction;
@end
@interface PaperButton : UIControl
@property (nonatomic,weak)id<PaperButtonDelegate>delegate;
+ (instancetype)button;
+ (instancetype)buttonWithOrigin:(CGPoint)origin;

- (void)animateToMenu;
- (void)animateToClose;
@end
