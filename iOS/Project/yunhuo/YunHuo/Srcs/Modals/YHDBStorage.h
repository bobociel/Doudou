//
//  YHDBStorage.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/28.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@protocol YHDBStorage <NSObject>
@property (nonatomic) long long index;	//主键

+ (NSString*) createTableSql;
- (id) initWithResult:(FMResultSet*)result;
- (void) saveToDB;
@end