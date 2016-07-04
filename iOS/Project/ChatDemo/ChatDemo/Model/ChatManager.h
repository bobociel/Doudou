//
//  ChatManager.h
//  ChatDemo
//
//  Created by wangxiaobo on 16/3/1.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^AVIMRecentConversationBlock)(NSArray *convs,NSUInteger unreadCount,NSError *error);

@interface ChatManager : NSObject <AVIMClientDelegate>
@property (nonatomic, copy) NSString *selfID;
@property (nonatomic, assign) BOOL connect;
/**
 *
 */
- (void)fetchConversatioionWithMemberId:(NSString *)ID callback:(AVIMConversationResultBlock)callbcak;
/**
 *
 */
- (void)fetchConversatioionWithMemberIds:(NSArray *)IDs callback:(AVIMConversationResultBlock)callbcak;
/**
 *
 */
- (void)createConversationWithMembserIds:(NSArray *)IDs callback:(AVIMConversationResultBlock)callback;
@end
