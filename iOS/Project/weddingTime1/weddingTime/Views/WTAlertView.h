//
//  WTAlertView.h
//  weddingTime
//
//  Created by 默默 on 15/9/20.
//  Copyright (c) 2015年 默默. All rights reserved.
//
#import <UIKit/UIKit.h>

@protocol WTAlertViewDelegate
@optional
- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface WTAlertView : UIView<WTAlertViewDelegate>

@property (nonatomic, retain) UIView *parentView;    // The parent view this 'dialog' is attached to
@property (nonatomic, retain) UIView *dialogView;    // Dialog's container view
@property (nonatomic, retain) UIView *containerView; // Container within the dialog (place your ui elements here)

@property (nonatomic, assign) id<WTAlertViewDelegate> delegate;
@property (nonatomic, retain) NSArray *buttonTitles;
@property (nonatomic, assign) BOOL useMotionEffects;



@property (copy) void (^onButtonTouchUpInside)(WTAlertView  *alertView, int buttonIndex) ;

- (instancetype)init;

/*!
 DEPRECATED: Use the [CustomIOSAlertView init] method without passing a parent view.
 */
- (id)initWithParentView: (UIView *)_parentView __attribute__ ((deprecated));

- (void)show;
- (void)close;

- (IBAction)customIOS7dialogButtonTouchUpInside:(id)sender;
- (void)setOnButtonTouchUpInside:(void (^)(WTAlertView *alertView, int buttonIndex))onButtonTouchUpInside;

- (void)deviceOrientationDidChange: (NSNotification *)notification;
- (void)dealloc;

//image设置为nil则是纯文本
- (instancetype)initWithText:(NSString*)title centerImage:(UIImage*)image;
@end

