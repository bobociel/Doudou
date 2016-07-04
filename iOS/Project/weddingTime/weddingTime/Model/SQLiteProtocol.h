//
//  SQLiteProtocol.h
//  weddingTime
//
//  Created by wangxiaobo on 1/5/16.
//  Copyright © 2016 默默. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SQLiteProtocol <NSObject>
@property (nonatomic,copy) NSString *ID;
@required
- (NSString *)createTableSql;
- (NSString *)replaceDataSql;
@optional
- (NSString *)deleteDataSql;
- (NSString *)deleteAllDataSql;
@end
