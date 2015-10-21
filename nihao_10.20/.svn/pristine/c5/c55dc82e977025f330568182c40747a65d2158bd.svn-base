//
//  FriendDao.m
//  nihao
//
//  Created by 刘志 on 15/7/14.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "FriendDao.h"
#import "NihaoContact.h"
#import <MJExtension.h>

@implementation FriendDao

- (BOOL) insertFriend:(NihaoContact *)contact {
    NSString *sql = @"INSERT INTO FRIENDS (USERID,USER_NAME,NICK_NAME,SEX,LOGO,COUNTRY,CITY) VALUES (:ci_id,:ci_username,:ci_nikename,:ci_sex,:ci_header_img,:country_name_en,:city_name_en)";
    contact = [self fullFillContact:contact];
    NSDictionary *dic = contact.keyValues;
    return [self executeSql:sql arguments:dic];
}

- (void) insertFriends : (NSArray *) contacts {
    for(NihaoContact *contact in contacts) {
        [self insertFriend:contact];
    }
}

- (BOOL) deleteFriendByUserid : (NSInteger) uid {
    NSString *sql = @"DELETE FROM FRIENDS WHERE USERID = :ci_id";
    return [self executeSql:sql arguments:@{@"ci_id":[NSString stringWithFormat:@"%ld",uid]}];
}

- (void) deleteFriends : (NSArray *) contacts {
    for(NihaoContact *contact in contacts) {
        [self deleteFriendByUserid:contact.ci_id];
    }
}

- (BOOL) updateFriendData : (NihaoContact *) contact {
    NSString *sql = @"UPDATE FRIENDS SET USER_NAME = :ci_username, NICK_NAME = :ci_nikename ,SEX = :ci_sex ,LOGO =:ci_header_img ,COUNTRY = :country_name_en ,CITY = :city_name_en WHERE USERID = :ci_id";
    contact = [self fullFillContact:contact];
    NSDictionary *dic = contact.keyValues;
    return [self executeSql:sql arguments:dic];
}

- (void) updateFriends : (NSArray *) contacts {
    for(NihaoContact *contact in contacts) {
        [self updateFriendData:contact];
    }
}

- (NSArray *) queryAllFriends {
    NSString *sql = @"SELECT * FROM FRIENDS";
    NSMutableArray *friends = [NSMutableArray array];
    [self executeQuery:sql arguments:nil queryBlock:^(FMResultSet *set) {
        if(set && set.columnCount > 0) {
            while ([set next]) {
                NihaoContact *contact = [[NihaoContact alloc] init];
                contact.ci_id = [set intForColumn:@"USERID"];
                contact.ci_username = [set stringForColumn:@"USER_NAME"];
                contact.ci_nikename = [set stringForColumn:@"NICK_NAME"];
                contact.ci_sex = [set intForColumn:@"SEX"];
                contact.ci_header_img = [set stringForColumn:@"LOGO"];
                contact.country_name_en = [set stringForColumn:@"COUNTRY"];
                contact.city_name_en = [set stringForColumn:@"CITY"];
                [friends addObject:contact];
            }
        }
    }];
    return friends;
}

/**
 *  字段为nil时，会导致插入数据库失败
 *
 *  @param contact
 *
 *  @return
 */
- (NihaoContact *) fullFillContact : (NihaoContact *) contact {
    if(!contact.country_name_en) {
        contact.country_name_en = @"";
    }
    if(!contact.city_name_en) {
        contact.city_name_en = @"";
    }
    return contact;
}

@end
