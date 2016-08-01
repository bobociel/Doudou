//
//  SQLiteProtocol.h
//  weddingTime
//
//  Created by wangxiaobo on 1/5/16.
//  Copyright © 2016 默默. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SQLiteProtocol <NSObject>
@optional
@property (nonatomic,copy) NSString *ID;
- (NSString *)createTableSql;
- (NSString *)replaceDataSql;
- (NSString *)deleteDataSql;
@end
