//
//  CopyLabel.m
//  nihao
//
//  Created by 刘志 on 15/9/21.
//  Copyright © 2015年 jiazhong. All rights reserved.
//

#import "CopyLabel.h"

@implementation CopyLabel

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//同上
-(void)awakeFromNib {
    [super awakeFromNib];
    [self attachTapHandler];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(copy:));
}

-(void)copy:(id)sender {
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.text;
    self.backgroundColor = [UIColor clearColor];
}

-(void)attachTapHandler {
    self.userInteractionEnabled = YES;  //用户交互的总开关
    UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGr.minimumPressDuration = 1.0;
    [self addGestureRecognizer:longPressGr];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if(gesture.state == UIGestureRecognizerStateBegan) {
        self.backgroundColor = ColorWithRGB(166, 215, 255);
        [self becomeFirstResponder];
        [[UIMenuController sharedMenuController] setTargetRect:self.frame inView:self.superview];
        [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
    }
}

- (void) menuDidHide : (NSNotification *) notification {
    self.backgroundColor = [UIColor clearColor];
}

@end
