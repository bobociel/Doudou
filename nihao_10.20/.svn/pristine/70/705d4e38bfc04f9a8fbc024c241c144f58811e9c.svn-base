//
//  ContactDao.m
//  nihao
//
//  Created by 刘志 on 15/7/7.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "ContactDao.h"
#import "NihaoContact.h"
#import <MJExtension.h>

@implementation ContactDao

- (BOOL) insertContacts:(NSArray *)contacts {
    NSString *insertSql = @"INSERT INTO CONTACTS (USERID,USER_NAME,NICK_NAME,SEX,LOGO) VALUES (:ci_id,:ci_username,:ci_nikename,:ci_sex,:ci_header_img)";
    for(NihaoContact *contact in contacts) {
        NSDictionary *contactDict = contact.keyValues;
        [self executeSql:insertSql arguments:contactDict];
    }
    return YES;
}

- (BOOL) updateContacts:(NSArray *)contacts {
    NSString *updateSql = @"UPDATE CONTACTS SET USER_NAME = :ci_username, NICK_NAME = :ci_nikename ,SEX = :ci_sex ,LOGO =:ci_header_img WHERE USERID = :ci_id";
    for(NihaoContact *contact in contacts) {
        NSDictionary *contactDict = contact.keyValues;
        [self executeSql:updateSql arguments:contactDict];
    }
    return YES;
}

- (BOOL) updateContact:(NihaoContact *)contact {
    NSString *updateSql = @"UPDATE CONTACTS SET USER_NAME = :ci_username, NICK_NAME = :ci_nikename ,SEX = :ci_sex ,LOGO =:ci_header_img WHERE USERID = :ci_id";
    return [self executeSql:updateSql arguments:contact.keyValues];
}

- (BOOL) deleteContacts:(NSArray *)contacts {
    NSString *deleteSql = @"DELETE FROM CONTACTS WHERE USERID = :ci_id";
    for(NihaoContact *contact in contacts) {
        NSDictionary *contactDict = contact.keyValues;
        [self executeSql:deleteSql arguments:contactDict];
    }
    return NO;
}

- (void) queryContactByUsername:(NSString *)username query:(QueryBlock)block {
    NSString *querySql = @"SELECT * FROM CONTACTS WHERE USER_NAME = :username";
    [self executeQuery:querySql arguments:@{@"username":username} queryBlock:block];
}

@end
