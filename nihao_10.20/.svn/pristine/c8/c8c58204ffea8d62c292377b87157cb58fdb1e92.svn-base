//
//  FriendDao.h
//  nihao
//
//  Created by 刘志 on 15/7/14.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "BaseDao.h"
@class NihaoContact;

@interface FriendDao : BaseDao

/**
 *  将好友数据插入到本地数据库
 *
 *  @param contact 联系人数据
 *
 *  @return 是否插入成功
 */
- (BOOL) insertFriend : (NihaoContact *) contact;

/**
 *  将好友数组数据插入到本地数据库中
 *
 *  @param contacts 好友数组数据
 *
 *  @return 是否插入成功
 */
- (void) insertFriends : (NSArray *) contacts;

/**
 *  根据用户的id删除用户数据
 *
 *  @param uid 用户的ci_id
 *
 *  @return 是否删除成功
 */
- (BOOL) deleteFriendByUserid : (NSInteger) uid;

/**
 *  将数列中的好友数据删除
 *
 *  @param contacts 好友数据
 *
 *  @return 是否删除成功
 */
- (void) deleteFriends : (NSArray *) contacts;

/**
 *  更新好友本地数据
 *
 *  @param contact 好友数据
 *
 *  @return 是否更新成功
 */
- (BOOL) updateFriendData : (NihaoContact *) contact;

/**
 *  更新好友本地数据
 *
 *  @param contacts 需要更新数据的好友列表
 */
- (void) updateFriends : (NSArray *) contacts;

/**
 *  查询所有的好友
 *
 *  @return nihaocontact数列
 */
- (NSArray *) queryAllFriends;

@end
