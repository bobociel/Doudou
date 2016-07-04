//
//  ChatFaceImageInputView.h
//  lovewith
//
//  Created by imqiuhang on 15/5/18.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChatFaceImageInputViewDelegate <NSObject>

- (void)chatFaceImageInputViewdidSendImage:(NSString *)imageName;

@end

@interface ChatFaceImageInputView : UIView <UIScrollViewDelegate>
@property(nonatomic,weak)id<ChatFaceImageInputViewDelegate>delegate;

-(void)show;
- (void)hide;

+ (float)getChatFaceImageInputViewHeight;
@property(nonatomic,strong) UIView *baseSuperView;
@end
