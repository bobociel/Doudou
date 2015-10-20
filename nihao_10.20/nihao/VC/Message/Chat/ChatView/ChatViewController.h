//
//  ChatViewController.h
//  nihao
//
//  Created by HelloWorld on 7/8/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChatViewControllerDelegate <NSObject>

- (NSString *)avatarWithChatter:(NSString *)chatter;
- (NSString *)nickNameWithChatter:(NSString *)chatter;

@end

@interface ChatViewController : UIViewController

@property (strong, nonatomic, readonly) NSString *chatter;
@property (nonatomic) BOOL isInvisible;
@property (nonatomic, assign) NSInteger chatterUserID;
@property (nonatomic ,copy) NSString *chatterUserName;

@property (nonatomic, assign) id <ChatViewControllerDelegate> delelgate;

- (instancetype)initWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup;
- (instancetype)initWithChatter:(NSString *)chatter conversationType:(EMConversationType)type;

- (void)reloadData;

- (void)hideImagePicker;

@end
