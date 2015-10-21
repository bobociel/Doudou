//
//  MessageCell.m
//  nihoo
//
//  Created by 刘志 on 15/4/21.
//  Copyright (c) 2015年 nihoo. All rights reserved.
//

#import "MessageCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BaseFunction.h"
#import "Constants.h"
#import "ContactDao.h"
#import <FMResultSet.h>
#import "HttpManager.h"
#import "NihaoContact.h"
#import <MJExtension.h>
#import "CustomBadge.h"

@implementation MessageCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) loadData:(EMConversation *)conversation {
    EMMessage *msg = conversation.latestMessage;
    EMTextMessageBody *msgBody = msg.messageBodies[0];
    //目前只支持文本聊天，故现在先不判断消息类型
    NSString *content;
    if(msgBody.messageBodyType == eMessageBodyType_Text) {
        content = msgBody.text;
    } else if(msgBody.messageBodyType == eMessageBodyType_Image) {
        content = @"[picture]";
    }
    
    //最近聊天内容的时间
    NSTimeInterval timeStamp = msg.timestamp / 1000;
    NSDate *date=[NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *msgDateStr = [dateformatter stringFromDate:date];
    NSString *msgTime = [BaseFunction dynamicDateFormat:msgDateStr];
    _date.text = msgTime;
    
    //未读消息数
    NSInteger unreadMsgNum = conversation.unreadMessagesCount;
    if(unreadMsgNum == 0) {
        _badge.hidden = YES;
    } else {
        _badge.hidden = NO;
        NSString *badgeNum = (unreadMsgNum > 99) ? @"99+" : [NSString stringWithFormat:@"%ld",unreadMsgNum];
        CGFloat scale = 1.0;
        if(unreadMsgNum >= 10) {
            scale = 0.7;
        }
        CustomBadge *badge = [CustomBadge customBadgeWithString:badgeNum withScale:scale];
        NSArray *subViews = [_badge subviews];
        if(subViews.count > 0) {
            for(UIView *view in subViews) {
                [view removeFromSuperview];
            }
        }
        [_badge addSubview:badge];
    }
    //用户名
    NSString *uname = conversation.chatter;
    _content.text = content;
    //根据uname查询用户数据
    [_dao queryContactByUsername:uname query:^(FMResultSet *set) {
        //数据库中有用户数据，直接设置，否则需要去网络获取
        if(set && set.columnCount > 0 && [set next]) {
            NSString *userNickName = [set stringForColumn:@"NICK_NAME"];
            NSInteger userSex = [set intForColumn:@"SEX"];
            NSString *logo = [set stringForColumn:@"LOGO"];
            UIImage *placeHolder = (userSex == 0) ? [UIImage imageNamed:@"default_icon_female"] : [UIImage imageNamed:@"default_icon_male"];
            [_logo sd_setImageWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:logo]] placeholderImage:placeHolder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if(!error) {
                    _logo.image = image;
                } else {
                    _logo.image = placeHolder;
                }
            }];
            _name.text = userNickName;
            
        } else {
            [HttpManager requestUserInfosByUserNames:uname success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if(responseObject && [responseObject[@"code"] integerValue] == 0) {
                    NSDictionary *result = responseObject[@"result"];
                    NSInteger totalRecords = [result[@"totalrecords"] integerValue];
                    if(totalRecords > 0) {
                        NSDictionary *userInfoDic = result[@"items"][0];
                        NihaoContact *contact = [NihaoContact objectWithKeyValues:userInfoDic];
                        contact.ci_username = conversation.chatter;
                        UIImage *placeHolder = (contact.ci_sex == 0) ? [UIImage imageNamed:@"default_icon_female"] : [UIImage imageNamed:@"default_icon_male"];
                        if(IsStringEmpty(contact.ci_header_img)) {
                            _logo.image = placeHolder;
                            //如果不赋值，会导致数据库插入失败
                            contact.ci_header_img = @"";
                        } else {
                            [_logo sd_setImageWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:contact.ci_header_img]] placeholderImage:placeHolder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                if(!error) {
                                    _logo.image = image;
                                } else {
                                    _logo.image = placeHolder;
                                }
                            }];
                        }
                        _name.text = contact.ci_nikename;
                        //将联系人数据保存到数据库
                        [_dao insertContacts:@[contact]];
                    }
                }
            } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
        }
    }];

}

@end
