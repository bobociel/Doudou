//
//  AVIMTypedMessage+DataBase.h
//  ChatDemo
//
//  Created by wangxiaobo on 16/3/1.
//  Copyright © 2016年 com.lovewith.lovewith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AVIMTypedMessage (DataBase) <DatabaseProtocol>
- (NSString *)createTableSql;
- (NSString *)replaceDataSql;
- (NSString *)deleteDataSql;
- (NSString *)deleteAllDataSql;
@end
