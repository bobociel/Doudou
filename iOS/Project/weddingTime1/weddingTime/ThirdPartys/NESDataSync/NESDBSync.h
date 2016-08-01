//
//  NESDBSync.h
//  NESDataSyncDemo
//
//  Created by Nestor on 14/12/8.
//  Copyright (c) 2014年 NesTalk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NESBaseModel.h"

static const NSString * const NESDBSyncCloseDbFailedNoti = @"NESDBSyncCloseDbFailedNoti";

static const NSString * const NESDBSyncOpenDbFailedNoti = @"NESDBSyncOpenDbFailedNoti";

/**基于FMDB二次封装的轻量级数据库框架

 通过NESDBSync实例完成基本的数据库操作,同时完成本地与远程数据库的同步操作
 
 需要使用的类包括:

 - 'NESDBSync'核心类

 通过类方法'registTableWithModelClass:'和'registTables:'注册数据模型

 示例代码:
 [NESDBSync registTableWithModelClass:[NESBaseModel class]];
 [NESDBSync registTables:@[[NESBaseModel class],[NESBaseModel class]]];

 @note 同一个模型仅能添加依次,多次添加无效,不会产生错误,但是会在控制台打印一条警告信息.
 
 @warning 数据模型必须继承自"NESBaseModel"

 推荐在程序启动时进行数据模型的注册,注册仅需执行一次,一旦注册完成直接调用"connection"获取连接即可使用;
 数据库表的创建将在后台自动完成;

 @note TIPS

 1.数据库表的创建在 `NESDBSync` 对象实例化的同时完成,任何获取连接前新注册的表都将被自动创建,现有的表和数据不受影响;

 2.可以随时通过 `forceCreateAllTables` 强制重建数据库,也可作为清空数据缓存的方式使用

 */
@interface NESDBSync : NSObject

//设置数据库的路径,如果不进行手动指定则在实例首次创建的时候指定一个默认的路径
@property (nonatomic,copy) NSString *path;

/** 获取NESDBSync的唯一示例
 @reture 单例对象
 @warning 永远不要实例化该类
 */
+(NESDBSync *)connection;

/** 通过Class注册一个实例表
 @param modelClass 需要进行注册的模型
 @warning 该Class必须是NESBaseModel的子类
 */
+(void)registTableWithModelClass:(Class)modelClass;

/** 通过数组进行批量模型注册
 @param tables 包含所有需要注册的模型数组,数组元素应为NESBaseModel子类的Class
 @see registTableWithModelClass:
 */
+(void)registTables:(NSArray *)tables;

/** 获取所有已注册的表
 @return 包含NESBaseModel子类Class的数组
 */
+(NSArray *)registTables;

/** 测试连接是否成功
 @return 成功返回 `YES`,否则返回 `NO`
 */
-(BOOL)goodConnection;

/** 查看某个模型的表是否存在
 @param modelClass 需要检查的表的模型
 @return 如果存在返回YES;
 */
-(BOOL)isTableExists:(Class)modelClass;

@end

@interface NESDBSync (Create)

/** 插入单条数据

 model为包含数据的对象实体,如果没有设定某个字段,那么在最终生成的sql语句中将不会包含该字段的部分;

 如:user.username = @"username";

 生成的sql语句便是 `insert into tablename ('username') values ('username');`

 无论user模型包含多少字段,没有在程序中指定值的都将被自动忽略,数据库中对应的字段将以 `NULL` 值进行填充;
 
 @param model 包含数据的对象实体
 @return 执行语句所影响的行数
 */
-(int)insertByModel:(NESBaseModel *)model;
-(int)insertByModels:(NSArray *)models;

@end

@interface NESDBSync (Retrieve)

/** 获取指定模型表的数据行数
 @param 需要查询的表
 @return 行数
 */
-(NSUInteger)selectCount:(Class)modelClass;

/** 通过指定模型获取数据
 @param modelClass 获取本地数据库中该模型对应表的全部数据
 @return 包含modelClass对象的数据集
 */
-(NSArray *)selectAllByModel:(Class)modelClass;

/** 根据指定的Id获取数据
 @param model 需要进行数据映射的类
 @param modelId 需要查询的id
 @return 封装进modelClass后的对象
 */
-(id)selectModel:(Class)modelClass byId:(NSInteger)modelId;

/** 通过指定的条件获取数据集

 通过传入一个model对象,自动生成sql语句并返回匹配的结果

 假设一个Model包含三个属性,username,password,age;

 model.username = @"username";

 其他属性保持默认值;

 以该实例作为参数调用该方法,将会生成sql语句:

 select * from tablename where username='username'

 只需要设置需要查询的列即可,无须手动拼接
 
 @param model 设定了指定条件的实例
 @return 包含modelClass所指定类型对象的数据集
 */
-(NSArray *)selectByModel:(NESBaseModel *)model;

/** 查询指定时间之前的字段,默认降序排列,暂时不支持同时查询多个时间
 
 model.birthday = [NSDate date];
 
 [db selectModelBeforeDate:model];
 
 返回 `birthday` 在当前日期之前的降序数据集
 
 @see selectModelBeforeDate:asc:
 @param model 为指定日期字段赋值的对象
 @return 数据集
 */
-(NSArray *)selectModelBeforeDate:(NESBaseModel *)model;

/** 查询指定时间之前的字段,暂时不支持同时查询多个时间
 
 model.birthday = [NSDate date];
 
 [db selectModelBeforeDate:model asc:YES];
 
 返回 `birthday` 在当前日期之前的升序数据集,默认读取10条记录
 
 @see selectModelBeforeDate:asc:limit:
 @param model 为指定日期字段赋值的对象
 @param asc 是否升序,YES 升序,NO 降序
 @return 数据集
 */
-(NSArray *)selectModelBeforeDate:(NESBaseModel *)model asc:(BOOL)asc;

/** 查询指定时间之前的字段,暂时不支持同时查询多个时间
 
 model.birthday = [NSDate date];
 
 [db selectModelBeforeDate:model asc:YES limit:20];
 
 返回 `birthday` 在当前日期之前的升序数据集,读取20条记录

 @param model 为指定日期字段赋值的对象
 @param asc 是否升序,YES 升序,NO 降序
 @limit limit 提取数据的数量,如果不做条数限定,limit赋值0
 @return 数据集
 */
-(NSArray *)selectModelBeforeDate:(NESBaseModel *)model asc:(BOOL)asc limit:(NSUInteger)limit;

/** 查询指定时间之前的字段,默认降序排列,暂时不支持同时查询多个时间
 
 model.birthday = [NSDate dateWithTimeIntervalSince1970:60*60*24*365*18];
 
 [db selectModelAfterDate:model];
 
 返回 `birthday` 在1988前之后的降序数据集
 
 @see selectModelAfterDate:asc
 @param model 为指定日期字段赋值的对象
 @return 数据集
 */
-(NSArray *)selectModelAfterDate:(NESBaseModel *)model;

/** 查询指定时间之前的字段,暂时不支持同时查询多个时间
 
 model.birthday = [NSDate dateWithTimeIntervalSince1970:60*60*24*365*18];
 
 [db selectModelAfterDate:model asc:YES];
 
 返回 `birthday` 在1988前之后的升序数据集
 
 @param model 为指定日期字段赋值的对象
 @param asc 是否升序,YES 升序,NO 降序
 @return 数据集
 */
-(NSArray *)selectModelAfterDate:(NESBaseModel *)model asc:(BOOL)asc;

/** 查询指定时间之前的字段,暂时不支持同时查询多个时间
 
 model.birthday = [NSDate date];
 
 [db selectModelAfterDate:model asc:YES limit:20];
 
 返回 `birthday` 在当前日期之前的升序数据集,读取20条记录
 
 @param model 为指定日期字段赋值的对象
 @param asc 是否升序,YES 升序,NO 降序
 @limit limit 提取数据的数量,如果不做条数限定,limit赋值0
 @return 数据集
 */
-(NSArray *)selectModelAfterDate:(NESBaseModel *)model asc:(BOOL)asc limit:(NSUInteger)limit;

/** 通过指定的SQL语句查询,并映射成为对应的Model对象
 @param modelClass 需要映射的类
 @param sql 要执行的sql语句
 @return 查询结果映射的数组
 */
-(NSArray *)select:(Class)modelClass sql:(NSString *)sql;

@end

@interface NESDBSync (Update)

/** 根据主键更新指定的数据
 @param model 包含新数据的值,同时必须包含主键值,没有手动设置新值的字段不会被更新
 @return 受影响的行数
 */
-(int)updateByModel:(NESBaseModel *)model;
/** 批量更新数据
 @param 包含NESBaseModel子类对象的数组,所有的对象必须对主键字段赋值
 @return 受影响的函数
 */
-(int)updateByModels:(NSArray *)models;
/** 根据特定的条件更新数据

 #### Demo

 newModel.age = 20;
 model.name = @"name";
 [db update:newModel where:model];

 执行的语句为:update tableName set age = '20' where name='name'
 
 @warning 该方法不支持文件映射功能!因为如果model对应多行记录,那么在进行更新时所有的条目将指向同一个文件,如果在这之后对该文件进行删除操作则其他引用该文件的字段将无法获取应有的值
 @param newModel 包含新数据的对象,未手动赋值的字段不会被更改
 @param model 包含筛选条件的对象,未手动赋值的字段不会作为筛选条件
 @return 受影响的行数
 */
-(int)update:(NESBaseModel *)newModel where:(NESBaseModel *)model;

@end

@interface NESDBSync (Delete)

/** 根据特定的条件删除数据
 @param model 包含删除条件的对象,未手动赋值的字段不会作为条件
 @return 操作结果
 */
-(BOOL)deleteByModel:(NESBaseModel *)model;
/** 根据指定的id删除数据
 @param modelId 需要删除的数据ID
 @return 操作结果
 */
-(BOOL)deleteModel:(Class)modelClass ById:(NSInteger)modelId;

/** 删除指定日期字段时间小于某个时间的数据

 #### Demo

 model.lastUpdate = [NSdate date];

 [db deleteModelByDateBefore:model];

 上面两行代码将删除model对应的表中,所有的 `lastUpdate` 字段值在当前时间之前的数据

 @param model 为指定日期字段赋边界值的对象
 @return 操作结果
 */
-(BOOL)deleteModelByDateBefore:(NESBaseModel *)model;

/** 删除指定日期字段时间小于某个时间的数据
 
 #### Demo

 NSDateFormatter *fmt = [[NSDateFormatter alloc] init];

 fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";

 model.lastUpdate = [fmt dateFromString:@"2014-12-22 00:00:00"];

 [db deleteModelByDateBefore:model];
 
 上述代码将删除model对应的表中,所有的 `lastUpdate` 字段值在 `2014-12-22日`0点整 之后的数据
 
 @param model 为指定日期字段赋边界值的对象
 @return 操作结果
 */
-(BOOL)deleteModelByDateAfter:(NESBaseModel *)model;

@end

@interface NESDBSync (DBOperation)
-(BOOL)openDB;
-(BOOL)closeDB;
-(BOOL)beginTransaction;
-(BOOL)commit;
-(BOOL)rollback;
@end

@interface NESDBSync (TableOperation)

/** 创建所有已经注册的表 */
-(BOOL)createAllTables;

/** 强制创建所有已注册的表 */
-(BOOL)forceCreateAllTables;

/** 根据指定的模型创建表
 默认调用-createTable:force:并为force提供一个默认的参数NO;
 @param modelClass 需要创建的模型类,该类必须继承自'NESBaseModel';
 @return 创建成功返回YES,否则NO;
 */
-(BOOL)createTableWithModel:(Class)modelClass;

/** 根据指定的模型创建表
 @param force 如果为YES,无论是否存在都将重新创建该表,该操作不可逆,可以用来清空数据
 @return 创建成功返回YES,否则NO;
 */
-(BOOL)createTable:(Class)modelClass force:(BOOL)force;

@end
