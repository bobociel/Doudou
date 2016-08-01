//
//  MessageFrame.h
//  lovewith
//
//  Created by imqiuhang on 15/4/10.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//
#import "MessageContentButton.h"
#import <CoreGraphics/CGGeometry.h>
#import "Message.h"
#import "MaskCreator.h"

@interface MessageFrame : NSObject

@property (nonatomic, assign, readonly) CGRect nameF;
@property (nonatomic, assign, readonly) CGRect iconF;
@property (nonatomic, assign, readonly) CGRect timeF;
@property (nonatomic, assign, readonly) CGRect contentF;

@property (nonatomic, assign, readonly) CGFloat cellHeight;
@property (nonatomic, strong          ) Message *message;
@property (nonatomic, assign          ) BOOL    showTime;
@property (nonatomic, assign) BOOL isMyMsg;

- (void)setMessage:(Message *)message;

@end
