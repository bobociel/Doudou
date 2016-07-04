//
//  SQLiteProtocol.h
//  weddingTime
//
//  Created by wangxiaobo on 1/5/16.
//  Copyright © 2016 默默. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DatabaseProtocol <NSObject>
@property (nonatomic,copy,readonly) NSString *ID;
@required
- (NSString *)createTableSql;
- (NSString *)replaceDataSql;
@optional
- (NSString *)deleteDataSql;
- (NSString *)deleteAllDataSql;
@end
