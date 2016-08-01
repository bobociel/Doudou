//
//  NESDBSync.m
//  NESDataSyncDemo
//
//  Created by Nestor on 14/12/8.
//  Copyright (c) 2014年 NesTalk. All rights reserved.
//

#import "NESDBSync.h"
#import "FMDatabase.h"

static bool tableIsSet = NO;

/** 检查Class是否为NESBaseMode的子类
 @param 待检查的Class
 @return 如果是则返回传入的modelClass,否则返回nil
 */
Class checkModel(Class modelClass)
{
    if (![modelClass isSubclassOfClass:[NESBaseModel class]]) {
        NESWarning(@"The class: %@ is not support,use subclass of NESBaseModel",NSStringFromClass(modelClass));
        
        return nil;
    }
    
    return modelClass;
}

/**当前数据库的状态*/

typedef NS_ENUM(NSInteger, DBStatus) {
    DBStatusClosed,
    DBStatusOpen
};

/** 事务状态 */
typedef NS_ENUM(NSInteger, TransactionStatus)
{
    TransactionStatusDefault,
    TransactionStatusBegin
};


#define VALIDFIELDS @"validFields"
#define ALWAYSNOW @"alwaysNow"
#define DEFAULTVALUES @"defaultValues"
#define DEFAULTIDNAME @"defaultIdName"
#define CACHEFIELDS @"cacheFields"
#define CACHEPATH @"cachePath"

@interface NESDBSync()

@property (nonatomic,retain) FMDatabase *db;
@property (nonatomic,assign) BOOL isTransactionBegin;
@property (nonatomic,assign) DBStatus dbStatus;
@property (nonatomic,assign) TransactionStatus transactionStatus;

@end

static NSMutableArray *registTables = nil;

@implementation NESDBSync

#pragma mark -
#pragma mark getters

-(NSString *)path
{
    if (!_path) {
        _path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:@"default.db"];
    }
    return _path;
}

-(FMDatabase *)db
{
    if (!_db) {
        _db = [FMDatabase databaseWithPath:self.path];
        NESMessage(@"DB PATH:%@",self.path);
    }
    return _db;
}

#pragma mark -
#pragma mark api

+(void)registTables:(NSArray *)tables
{
    [tables enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self registTableWithModelClass:[obj class]];
    }];
}

+(void)registTableWithModelClass:(Class)modelClass
{
    if (!checkModel(modelClass)) {
        return;
    }
    
    if (registTables == nil) {
        registTables = [NSMutableArray array];
    }
    
    if ([registTables indexOfObject:modelClass] != NSNotFound) {
        NESWarning(@"The class: %@ is already registed",NSStringFromClass(modelClass));
        return;
    }
    
    [registTables addObject:modelClass];
    tableIsSet = NO;
}

-(BOOL)isTableExists:(Class)modelClass
{
    NESBaseModel *model = [[checkModel(modelClass) alloc] init];
    
    if (!model) {
        return NO;
    }
    
    NSString *sql = @"select count(*) as 'count' from sqlite_master where type ='table' and name = ?";
    FMResultSet *rs = [self.db executeQuery:sql,model.tableName];
    
    BOOL flag = [rs next] ? [rs intForColumn:@"count"] != 0 : NO;
    
    if (flag) {
        NESWarning(@"表格 [%@] 已经存在!", model.tableName);
    }
    
    return flag;
}

+(NSArray *)registTables
{
    return registTables;
}

-(BOOL)goodConnection
{
    return [self.db goodConnection];
}

#pragma mark -
#pragma mark create

-(int)insertByModel:(NESBaseModel *)model
{
    NSString *sql = [NSString stringWithFormat:@" replace into %@ (#FIELDS#) values (#VALUES#)",model.tableName];//waring已修改为replace
    
    NSArray *alwaysNow = [model valueForKey:ALWAYSNOW];
    
    [alwaysNow enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [model setValue:[NSDate date] forKey:obj];
    }];
    
    NSDictionary *fields = [model valueForKey:VALIDFIELDS];
    NSDictionary *defaults = [model valueForKey:DEFAULTVALUES];
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:defaults];
    [param setValuesForKeysWithDictionary:fields];

    NSArray *keys = [param allKeys];
    NSArray *values = [param allValues];
    
    NSString *temp = @"";
    
    for (int i=0; i<keys.count; i++) {
        temp = [NSString stringWithFormat:@"%@,'%@'",temp,[keys objectAtIndex:i]];
    }
    temp = [temp substringFromIndex:1];
    
    sql = [sql stringByReplacingOccurrencesOfString:@"#FIELDS#" withString:temp];
    
    temp = @"";
    
    for (int i=0; i<values.count; i++) {
        temp = [NSString stringWithFormat:@"%@,?",temp];
    }
    temp = [temp substringFromIndex:1];
    sql = [sql stringByReplacingOccurrencesOfString:@"#VALUES#" withString:temp];
    
    NESMessage(@"SQL:%@",sql);
    
    BOOL result = [self.db executeUpdate:sql withArgumentsInArray:values];
    
    return result ? 1 : 0;
}

-(int)insertByModels:(NSArray *)models
{
    __block int count = 0;
    __block BOOL flag = NO;
    
    if (![self beginTransaction]) return 0;
    
    [models enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        if (![obj isKindOfClass:[NESBaseModel class]])
        {
            flag = YES;
            *stop = YES;
            return ;
        }
        
        NESBaseModel *model = obj;
        count += [self insertByModel:model];
    }];
    
    if (count != models.count) {
        [self rollback];
        return 0;
    }
    
    [self commit];
    
    return count;
}

#pragma mark -
#pragma mark retrieve

-(NSArray *)selectModelAfterDate:(NESBaseModel *)model
{
    return [self selectModelAfterDate:model asc:NO];
}

-(NSArray *)selectModelAfterDate:(NESBaseModel *)model asc:(BOOL)asc
{
    return [self selectModelAfterDate:model asc:asc limit:10];
}

-(NSArray *)selectModelAfterDate:(NESBaseModel *)model asc:(BOOL)asc limit:(NSUInteger)limit
{
    return [self selectModel:model gt:YES asc:asc limit:limit];
}

-(NSArray *)selectModelBeforeDate:(NESBaseModel *)model
{
    return [self selectModelBeforeDate:model asc:NO];
}

-(NSArray *)selectModelBeforeDate:(NESBaseModel *)model asc:(BOOL)asc
{
    return [self selectModelBeforeDate:model asc:asc limit:10];
}

-(NSArray *)selectModelBeforeDate:(NESBaseModel *)model asc:(BOOL)asc limit:(NSUInteger)limit
{
    return [self selectModel:model gt:NO asc:asc limit:limit];
}

-(NSArray *)selectModel:(NESBaseModel *)model gt:(BOOL)gt asc:(BOOL)asc limit:(NSUInteger)limit
{
    NSString *sql = [NSString stringWithFormat:@" select * from %@ where #REPLACE# order by #FIELD# %@",model.tableName,asc ? @"" : @"desc"];
    
    NSDictionary *validFields = [model valueForKey:VALIDFIELDS];
    NSArray *keys = validFields.allKeys;

    sql = [sql stringByReplacingOccurrencesOfString:@"#FIELD#" withString:keys.firstObject];
    
    NESAssert(keys.count == 1,
              @"查询时间数量为:%ld个,不应超过1个!将按照字段%@查询",
              (unsigned long)keys.count,
              keys.firstObject);
    
    NSString *where = [NSString stringWithFormat:@" %@%@? ",
                       validFields.allKeys.firstObject,
                       gt ? @" > " : @" < "];
    
    sql = [sql stringByReplacingOccurrencesOfString:@"#REPLACE#" withString:where];
    
    if (limit) {
        sql = [sql stringByAppendingString:[NSString stringWithFormat:@" limit %lu",(unsigned long)limit]];
    }
    
    NESMessage(@"SQL:%@",sql);
    
    FMResultSet *rs = [self.db executeQuery:sql withArgumentsInArray:@[validFields.allValues.firstObject]];
    
    NSMutableArray *dataset = [NSMutableArray array];
    Class clz = model.class;
    
    while ([rs next]) {
        NESBaseModel *row = [[clz alloc] init];
        [row mapping:rs];
        [dataset addObject:row];
    }
    
    return dataset;
}

-(NSUInteger)selectCount:(Class)modelClass
{
    NESBaseModel *model = [[checkModel(modelClass) alloc] init];
    
    if (!model) return 0;
    
    NSString *sql = [NSString stringWithFormat:@"select count(*) from %@",model.tableName];
    
    FMResultSet *rs = [self.db executeQuery:sql];
    
    return [rs next] ? [rs intForColumnIndex:0] : 0;
}

-(NSArray *)selectAllByModel:(Class)modelClass
{
    NESBaseModel *model = [[checkModel(modelClass) alloc] init];

    if (!model) return nil;
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@",model.tableName];
    
    CGFloat start = [[NSDate date] timeIntervalSince1970];
    
    FMResultSet *rs = [self.db executeQuery:sql];
    
    CGFloat end = [[NSDate date] timeIntervalSince1970];
    
    NESInfo(@"查询耗时:%f",end - start);
    
    NSMutableArray *data = [NSMutableArray array];
    
    while ([rs next]) {
        NESBaseModel *model = [[modelClass alloc] init];
        [model mapping:rs];
        [data addObject:model];
    }
    
    CGFloat mapping = [[NSDate date] timeIntervalSince1970];
    
    NESInfo(@"ORM耗时:%f",mapping - end);
    
    return data;
}

-(NSArray *)selectByModel:(NESBaseModel *)model
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where ",model.tableName];
    
    NSDictionary * params = [model valueForKey:VALIDFIELDS];
    
    if (!params || params.count == 0) return nil;
    
    NSArray *keys = params.allKeys;
    
    __block NSString * where = @"";
    
    [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *key = obj;
        where = [NSString stringWithFormat:@"%@ %@ = ? and ",where,key];
    }];
    
    where = [[where substringToIndex:where.length - 5] substringFromIndex:1];
    sql = [sql stringByAppendingString:where];
    
    NESMessage(@"SQL:%@",sql);
    
    FMResultSet *rs = [self.db executeQuery:sql withArgumentsInArray:params.allValues];
    
    NSMutableArray *dataset = [NSMutableArray array];
    
    while ([rs next]) {
        NESBaseModel *result = [[[model class] alloc] init];
        [result mapping:rs];
        [dataset addObject:result];
    }
    
    return dataset;

}

-(id)selectModel:(Class)modelClass byId:(NSInteger)modelId
{
    NESBaseModel *model = [[checkModel(modelClass) alloc] init];
    
    if (!model) return nil;
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ = %@",model.tableName,[model valueForKey:DEFAULTIDNAME],@(modelId)];

    NESInfo(@"SQL:%@",sql);
    
    FMResultSet *rs = [self.db executeQuery:sql];
    
    NESBaseModel *result = nil;
    
    while ([rs next]) {
        result = [[modelClass alloc] init];
        [result mapping:rs];
    }
    
    return result;
}

-(NSArray *)select:(Class)modelClass sql:(NSString *)sql
{
    NESBaseModel *model = [[checkModel(modelClass) alloc] init];
    if (!model) return nil;
    
    FMResultSet *rs = [self.db executeQuery:sql];
    
    NSMutableArray *dataset = [NSMutableArray array];

    while ([rs next]) {
        NESBaseModel *result = [[[model class] alloc] init];
        [result mapping:rs];
        [dataset addObject:result];
    }
    
    return dataset;
}

#pragma mark -
#pragma mark update

-(int)update:(NESBaseModel *)newModel where:(NESBaseModel *)model
{
//    [self removeCacheFileWithModel:newModel where:model];
    
    NSString *sql = [NSString stringWithFormat:
                     @" UPDATE %@ SET #FIELDS# WHERE ",model.tableName];
    
    NSArray *alwaysNow = [model valueForKey:ALWAYSNOW];
    
    [alwaysNow enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [newModel setValue:[NSDate date] forKey:obj];
    }];
    
    NSDictionary *fields = [newModel valueForKey:VALIDFIELDS];
    NSArray *keys = [fields allKeys];
    NSArray *values = [fields allValues];
    
    __block NSString * data = @"";
    
    [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        data = [NSString stringWithFormat:@"%@,%@=?",data,obj];
    }];

    data = [data substringFromIndex:1];
    sql = [sql stringByReplacingOccurrencesOfString:@"#FIELDS#" withString:data];
    
    __block NSString *where = @"";
    
    fields = [model valueForKey:VALIDFIELDS];
    keys = [fields allKeys];
    
    [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        where = [NSString stringWithFormat:@"%@ %@=? and ",where,obj];
    }];
    where = [[where substringToIndex:where.length - 5] substringFromIndex:1];
    sql = [sql stringByAppendingString:where];
    
    NESInfo(@"SQL:%@",sql);
    
    values = [values arrayByAddingObjectsFromArray:[fields allValues]];
    
    NESInfo(@"PARAM:%@",values);
    
    NESAssertReturn([self.db executeUpdate:sql withArgumentsInArray:values],
                    @"数据更新错误,ERROR:%@",
                    NO,
                    self.db.lastErrorMessage);
    
    return YES;
}

-(int)updateByModel:(NESBaseModel *)model
{
    
    NSString *sql = [NSString stringWithFormat:@" UPDATE %@ SET #FIELDS# WHERE ",model.tableName];
    
    NSArray *alwaysNow = [model valueForKey:ALWAYSNOW];
    
    [alwaysNow enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [model setValue:[NSDate date] forKey:obj];
    }];
    
    NSDictionary *fields = [model valueForKey:VALIDFIELDS];
    NSArray *keys = [fields allKeys];
    
    __block NSString * data = @"";
    
    [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        data = [NSString stringWithFormat:@"%@,%@ = ? ",data,obj];
    }];
    
    data = [data substringFromIndex:1];
    sql = [sql stringByReplacingOccurrencesOfString:@"#FIELDS#" withString:data];

    sql = [sql stringByAppendingString:[NSString stringWithFormat:@"%@=?",[model valueForKey:DEFAULTIDNAME]]];
    
    NESInfo(@"SQL:%@",sql);
    
    NSArray *values = [fields allValues];
    values = [values arrayByAddingObject:@([model getId])];
    
    NESAssertReturn([self.db executeUpdate:sql withArgumentsInArray:values],
                    @"数据更新错误,ERROR:%@",
                    NO,
                    self.db.lastErrorMessage);
    
    [self removeCacheFileForModelWithId:model];
    
    return YES;
}

-(int)updateByModels:(NSArray *)models
{
    [self beginTransaction];
    
    __block int count = 0;
    __block BOOL succ;
    [models enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        NESAssertFlag([self updateByModel:obj],
                      @"更新失败!ERROR:%@",
                      succ,
                      self.db.lastErrorMessage);
        *stop = !succ;
        count++;
    }];

    if (!succ) {
        [self rollback];
        return 0;
    }
    
    [self commit];
    return count;
}

#pragma mark -
#pragma mark delete

-(BOOL)deleteModel:(Class)modelClass ById:(NSInteger)modelId
{
    NESBaseModel *model = [[checkModel(modelClass) alloc] init];
    if (!model) return NO;
    
    [self removeCacheFileForModel:modelClass ById:modelId];
    
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@=%@",
                     model.tableName,
                     [model valueForKey:DEFAULTIDNAME],
                     @(modelId)];
    
    NESMessage(@"SQL:%@",sql);

    NESAssertReturn([self.db executeUpdate:sql], @"数据删除失败,ERROR:%@", NO,self.db.lastErrorMessage);
    
    return YES;
}

-(BOOL)deleteByModel:(NESBaseModel *)model
{
    [self removeCacheFileForModel:model];
    
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where ",model.tableName];
    
    NSDictionary *fields = [model valueForKey:VALIDFIELDS];
    NSArray *keys = [fields allKeys];
    
    __block NSString *where = @"";
    
    [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        where = [NSString stringWithFormat:@"%@ %@=? and ",where,obj];
    }];
    
    where = [where substringToIndex:where.length - 5];
    sql = [sql stringByAppendingString:where];
    
    NESMessage(@"SQL:%@",sql);
    
    NESAssertReturn([self.db executeUpdate:sql withArgumentsInArray:[fields allValues]], @"删除数据失败,ERROR:%@", NO,self.db.lastErrorMessage);
    
    return YES;
}

-(BOOL)deleteModelByDateAfter:(NESBaseModel *)model
{
    NSArray *arr = [self selectModelAfterDate:model];
    
    __block BOOL succ;

    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NESBaseModel *data = obj;
        NESAssertFlag([self deleteModel:[model class] ById:[data getId]],
                      @"删除数据失败,ERROR:%@",
                      succ,
                      self.db.lastErrorMessage);
        *stop = !succ;
    }];
    
    return succ;
}

-(BOOL)deleteModelByDateBefore:(NESBaseModel *)model
{
    NSArray *arr = [self selectModelBeforeDate:model];
    
    __block BOOL succ;
    
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NESBaseModel *data = obj;
        NESAssertFlag([self deleteModel:[model class] ById:[data getId]],
                      @"删除数据失败,ERROR:%@",
                      succ,
                      self.db.lastErrorMessage);
        *stop = !succ;
    }];
    
    return YES;
}

#pragma mark -
#pragma mark util

//-(void)removeCacheFileWithModel:(NESBaseModel *)new where:(NESBaseModel *)old;
//{
//    NSDictionary *cacheFields = [new valueForKey:CACHEFIELDS];
//    NSArray *cacheNames = [cacheFields allKeys];
//    NSMutableArray *changedFields = [NSMutableArray array];
//    [cacheNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        id value = [new valueForKey:obj];
//        BOOL changed;
//        NESAssertFlag(value != nil, @"字段:%@ 未被更改", changed,obj);
//        if (changed) [changedFields addObject:obj];
//    }];
//    
//    if (changedFields.count == 0) return;
//    
//    NSArray *models = [self selectByModel:old];
//    
//    NSString *path = [old valueForKey:CACHEPATH];
//    
//    dispatch_apply(models.count, dispatch_get_global_queue(0, 0), ^(size_t i) {
//        dispatch_apply(changedFields.count, dispatch_get_global_queue(0, 0), ^(size_t j) {
//            NESBaseModel *model = [models objectAtIndex:i];
//            NSString *key = [changedFields objectAtIndex:j];
//            
//            NSDictionary *cachedFields = [model valueForKey:CACHEFIELDS];
//            
//            NSString *fileName = [cachedFields valueForKey:key];
//            if (fileName != nil && fileName.length > 0) {
//                NSString *cachePath = [path stringByAppendingPathComponent:fileName];
//                
//                NESMessage(@"cache file to remove:%@",cachePath);
//                
//                if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
//                    [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
//                }
//            }
//            
//        });
//    });
//    
//}

-(void)removeCacheFileForModel:(Class)modelClass ById:(NSInteger)modelId
{
    NESBaseModel *model = [self selectModel:modelClass byId:modelId];
    
    NESMessage(@"MODEL:%@",model);
    
    NSString *path = [model valueForKey:CACHEPATH];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *cacheFields = [model valueForKey:CACHEFIELDS];
        
        NESMessage(@"cached fields:%@",cacheFields);
        
        NSArray *keys = [cacheFields allKeys];
        
        [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *fileName = [cacheFields objectForKey:obj];
            if (fileName != nil && fileName.length > 0) {
                NSString *cachePath = [path stringByAppendingPathComponent:fileName];
                
                NESMessage(@"cache file to remove:%@",cachePath);
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
                    [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
                }
            }
        }];
    });
    
}


-(void)removeCacheFileForModel:(NESBaseModel *)model
{
    NSArray *models = [self selectByModel:model];
    
    NSString *path = [model valueForKey:CACHEPATH];
    
    [models enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NESBaseModel *temp = obj;
            NSDictionary *cacheFields = [temp valueForKey:CACHEFIELDS];
            NSArray *keys = [cacheFields allKeys];
            
            [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString *fileName = [cacheFields objectForKey:obj];
                if (fileName != nil && fileName.length > 0) {
                    NSString *cachePath = [path stringByAppendingPathComponent:fileName];
                    
                    NESMessage(@"cache file to remove:%@",cachePath);
                    
                    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
                        [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
                    }
                }
            }];
        });
    }];
}

-(void)removeCacheFileForModelWithId:(NESBaseModel *)model
{
    NSDictionary *cacheFields = [model valueForKey:CACHEFIELDS];
    NSArray *cacheNames = [cacheFields allKeys];
    NSMutableArray *changedFields = [NSMutableArray array];
    [cacheNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id value = [model valueForKey:obj];
        BOOL changed;
        NESAssertFlag(value != nil, @"字段:%@ 未被更改", changed,obj);
        if (changed) [changedFields addObject:obj];
    }];
    
    NESMessage(@"更改字段:%@",changedFields);
    
    NESBaseModel *oldModel = [self selectModel:[model class] byId:[model getId]];
    
    cacheFields = [oldModel valueForKey:CACHEFIELDS];
    
    [changedFields enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *cacheName = [cacheFields objectForKey:obj];
            NESMessage(@"字段:%@ 缓存文件:%@",obj,cacheName);
            
            NSString *path = [[model valueForKey:CACHEPATH] stringByAppendingPathComponent:cacheName];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            }

        });
    }];
    
}



#pragma mark -
#pragma mark table opreation

static bool FORCECREATE = NO;

-(BOOL)createAllTables
{
    __block BOOL flag = NO;
    
    if (![self beginTransaction]) return NO;
    
    [registTables enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Class clz = obj;
        
        if (!checkModel(clz)) return;
        
        flag = [self createTable:clz force:FORCECREATE];
        *stop = !flag;
    }];
    
    [self commit];
    FORCECREATE = NO;
    
    return flag;
}

-(BOOL)forceCreateAllTables
{
    FORCECREATE = YES;
    return [self createAllTables];
}

-(BOOL)createTableWithModel:(Class)modelClass
{
    return [self createTable:modelClass force:NO];
}


-(BOOL)createTable:(Class)modelClass force:(BOOL)force
{
    /** 如果非强制创建,同时表已存在返回NO */
    if (!force && [self isTableExists:modelClass]) return YES;
    
    if (self.transactionStatus == TransactionStatusDefault) [self openDB];
    NESBaseModel *model = [[modelClass alloc] init];
    
    if (force) {
        NSString *path = [model valueForKey:@"cachePath"];
        
        NESInfo(@"delete cache path:%@ for %@",path,model.tableName);
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            BOOL succ;
            NESAssertFlag([[NSFileManager defaultManager] removeItemAtPath:path error:nil], @"删除缓存文件夹失败",succ);
            if (!succ) {
                NESTodo(@"添加删除文件失败处理代码");
            }
        }
        NSString *sql = [NSString stringWithFormat:@"drop table if exists %@;",model.tableName];
        
        NESAssert([self.db executeUpdate:sql],
                  @"删除表 `%@` 失败,SQL:%@ ERROR:%@",
                  sql,
                  model.tableName,
                  [self.db lastErrorMessage]);
    }

    NESAssertReturn([self.db executeUpdate:[model getCreateSQL]],
                  @"创建表失败,SQL:%@,ERROR:%@",
                    NO,
                    [model getCreateSQL],
                    self.db.lastErrorMessage);
    
    NESMessage(@"CREATE SQL:%@",[model getCreateSQL]);
    
//    if (self.transactionStatus == TransactionStatusDefault) [self closeDB];
 
    return YES;
}

#pragma mark -
#pragma mark lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dbStatus = DBStatusClosed;
        self.transactionStatus = TransactionStatusDefault;
        if ([self openDB] && !tableIsSet) {
            tableIsSet = [self createAllTables];
            NESInfo(@"Table is %sset",tableIsSet ? "" : "not ");
        }
    }
    
    return self;
}

-(void)dealloc
{
    [self closeDB];
}

+(NESDBSync *)connection
{
    NESDBSync *connection = [[NESDBSync alloc] init];
    
    if ([connection openDB] && tableIsSet ) return connection;
    
    return nil;
}

#pragma mark -
#pragma mark db operation

-(BOOL)openDB
{
    if (self.dbStatus == DBStatusOpen) return YES;
    
    NESAssertReturn([self.db open],
                    @"open db failed with message:%@",
                    NO,
                    self.db.lastErrorMessage);
    
    self.dbStatus = DBStatusOpen;
    return YES;
}

-(BOOL)closeDB
{
    if (self.dbStatus == DBStatusClosed) return YES;
    
    NESAssertReturn([self.db close],
                    @"open db failed with message:%@",
                    NO,
                    self.db.lastErrorMessage);
    
    self.dbStatus = DBStatusClosed;
    self.transactionStatus = TransactionStatusDefault;
    return NO;
}

-(BOOL)beginTransaction
{
    if (self.transactionStatus == TransactionStatusBegin) return YES;

//    if (![self openDB]) return NO;
    NESAssertReturn([self openDB], @"", NO);
    
    NESAssertReturn([self.db beginTransaction],
                    @"can not begin transaction because:%@" ,
                    NO,
                    self.db.lastErrorMessage);
    
    self.transactionStatus = TransactionStatusBegin;
    
    return YES;
}

-(BOOL)commit
{
    if (self.dbStatus == DBStatusClosed) return YES;
    if (self.transactionStatus == TransactionStatusDefault) return YES;
    
    BOOL flag;
    
    NESAssertFlag([self.db commit],
                  @"commit error:%@",
                  flag,
                  self.db.lastErrorMessage);
    
    if (!flag) [self rollback];
    
    self.transactionStatus = TransactionStatusDefault;
    
    return flag;
}

-(BOOL)rollback
{
    return [self.db rollback];
}



@end
