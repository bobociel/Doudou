//
//  MessageCellTableViewCell.h
//  lovewith
//
//  Created by imqiuhang on 15/4/10.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageFrame.h"

@class MessageCell;

@protocol MessageCellDelegate <NSObject>

@optional

- (void)headImageDidClick:(MessageCell *)cell   userId:(NSString *)userId __deprecated_msg("headImageDidClick已经废弃 考虑到发送的消息频率很快，delegate可能会调起已经被复用的cell引起cash，虽然概率很小，现在统一在.m中监听点击事件做处理,KEY_WINDOWN作为跳转媒介");
- (void)cellContentDidClick:(MessageCell *)cell image:(UIImage *)contentImage __deprecated_msg("cellContentDidClick已经废弃 考虑到发送的消息频率很快，delegate可能会调起已经被复用的cell引起cash，虽然概率很小，现在统一在.m中监听点击事件做处理,KEY_WINDOWN作为跳转媒介");
- (void)cellDidPushTowSlide:(UITableViewCellEditingStyle)style :(BOOL)isEdite NS_AVAILABLE_IOS(8_0)//多个编辑模式8.0才支持
__deprecated_msg("cellDidPushTowSlide已经废弃 考虑到发送的消息频率很快，delegate可能会调起已经被复用的cell引起cash，虽然概率很小，现在统一在.m中监听点击事件做处理,KEY_WINDOWN作为跳转媒介");

-(void)clickShowListImageWithUrl:(NSString*)url imageView:(UIImageView*)imageview;
@end

@interface MessageCell : UITableViewCell

@property (nonatomic, strong) UILabel  *labelTime;
@property (nonatomic, strong) UILabel  *labelNum;
@property (nonatomic, strong) UIButton *btnHeadImage;
@property (nonatomic,strong)UIImageView *rightImageView;
@property (nonatomic, assign) BOOL isMyMsg;
@property (nonatomic, copy) NSString *orSupplierID;
@property (nonatomic, strong) MessageContentButton *btnContent;

@property (nonatomic, strong) MessageFrame         *messageFrame;

@property (nonatomic, weak) id<MessageCellDelegate > delegate;
@end
