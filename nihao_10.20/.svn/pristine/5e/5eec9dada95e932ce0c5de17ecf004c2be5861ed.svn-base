//
//  ContactDao.h
//  nihao
//
//  Created by 刘志 on 15/7/7.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "BaseDao.h"
@class NihaoContact;

@interface ContactDao : BaseDao

/**
 *  插入联系人数据
 *
 *  @param contacts 联系人列表
 *
 *  @return 是否插入成功
 */
- (BOOL) insertContacts : (NSArray *) contacts;

/**
 *  批量更新联系人
 *
 *  @param contact 联系人
 *
 *  @return 是否更新成功
 */
- (BOOL) updateContact : (NihaoContact *) contact;

/**
 *  批量更新联系人
 *
 *  @param contacts 联系人列表
 *
 *  @return 是否更新成功
 */
- (BOOL) updateContacts : (NSArray *) contacts;

/**
 *  批量删除联系人
 *
 *  @param contacts 联系人列表
 *
 *  @return 是否删除成功
 */
- (BOOL) deleteContacts : (NSArray *) contacts;

/**
 *  根据用户名查询数据库里的用户信息
 *
 *  @param username 用户名
 *
 *  @param query 查询结果block 
 *
 *  @return 数据集
 */
- (void) queryContactByUsername : (NSString *) username query : (QueryBlock) block;

@end
