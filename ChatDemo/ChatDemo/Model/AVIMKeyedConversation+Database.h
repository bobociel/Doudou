//
//  AVIMKeyedConversation+Database.h
//  ChatDemo
//
//  Created by wangxiaobo on 16/3/1.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,AVIMConversationType) {
	AVIMConversationTypeSigle,
	AVIMConversationTypeGroup
};

@interface AVIMKeyedConversation (Database)  <DatabaseProtocol>
- (NSString *)createTableSql;
- (NSString *)replaceDataSql;
- (NSString *)deleteDataSql;
- (NSString *)deleteAllDataSql;
@end

@interface AVIMConversation (Database) <DatabaseProtocol>
- (NSString *)createTableSql;
- (NSString *)replaceDataSql;
- (NSString *)deleteDataSql;
- (NSString *)deleteAllDataSql;
@end
