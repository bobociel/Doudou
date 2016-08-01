//
//  NESBaseModel.h
//  NESDataSyncDemo
//
//  Created by Nestor on 14/12/8.
//  Copyright (c) 2014年 NesTalk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NESQuickLogger.h"
@class FMResultSet;

@interface NSArray (NESBaseModelMapping)

/** 将NSArray中的对象映射成为指定模型对象
 @waning NSArray中的对象必须为NSDictionary,如果词典中不包含指定模型中的字段则会封装一个空的实例
 @param modelClass 指定封装的模型类
 @return 封装完成的数组,如果指定的class不是NESBaseModel的子类,那么返回nil
 */
-(NSArray *)mappingWithModel:(Class)modelClass;

@end

@interface NSDate (NESDBSync)

/** 获取日期字符串
 @return 根据当前表的特定字段设置获取对应的日期字符串;
 */
-(NSString *)dateString;

@end

/** 建立实体类继承自该类 
 
 ### How to use:

 每张表都是一个单独的Model,继承自NESBaseModel,数据库中的每个字段都对应了一个属性,在声明属性的时候可以指定任何基本数据类型,字符串,日期或者NSData类型,在创建本地数据库时将根据不同的属性类型创建不同类型的表字段,如果对某些属性有特殊需求,可以通过字段标记进行声明.

 ### 字段标记

 直接在字段名后面添加 `$tag`即可,可用标记如下:

 $t     :忽略字段,该属性将不会作为数据库的字段

 $pk    :表主键,仅当使用手动声明主键时进行设置

 ##日期标记

 $dt    :日期格式标记,显示完整时间,`yyyy-MM-dd hh:mm:ss`

 @note `$dt`是默认日期格式,可以省略,也可进行显示标记以增强可读性

 $d     :日期格式标记,仅显示日期`yyyy-MM-dd`

 $tt    :日期格式标记,不同于忽略字段标记 `$t`,仅显示时间 `hh:mm:ss`
 
 $n     :日期格式标记,最后一次更新时间,无论在插入还是更新时,永远记录当前时间

 @note 日期格式标记应当仅在使用NSDate类型的属性时标注!

 ## 默认值标记

 $v[...]:指定字段的默认值,手动指定默认值时直接将值写在标记后边即可

 例:属性`sex$v1`的含义是创建名为sex的字段,默认值为1
 
 属性`status$vdefault`的含义是创建名为`status`的字段,默认值为`default`.

 默认值仅在执行插入操作的时候有效,根据数据模型进行搜索时将自动忽略

 对于没有设置`$v`标记的字段,插入新数据时会以数据库的NULL类型进行处理

 对于字符串类型的字段添加 `$v` 代表默认值为空字符串,
 str和str$v在数据库中将使用不同方式进行处理,如果不对属性`str`赋值,那么插入后str字段在数据空中的值为NULL
 而如果不对str$v字段进行赋值,插入后该字段的值为 "" .

 但是无论是否存在默认值,ORM映射对于没有有效数据的字符串类型字段返回相同的结果,即 `NULL` 或者 "" 都将按照 @"" 进行赋值

 对于NSDate类型的字段 `$v` 代表当前时间,可以配合上述日期格式标记同时使用,如:$dt$v

 @warning `$v` 在用于NSDate类型字段时仅在创建数据时有效,但是在更新数据时不会进行任何修改,换言之,`$v`仅适用于记录创建时间,如果希望每次更新时自动记录更新时间,应该使用`$n`标记!

 @note $v始终应该作为最后一个标记使用!

 @warning NSDate类型的字段不支持非当前时间的默认参数,`$v2014-12-11`,`$v2014-12-11 12:22:22`等等都是非法的

 ## 文件标记

 $f     :对于NSData,UIImage类型的数据可以添加$f,指定其作为文件类型保存到沙盒目录下,在文件进行读取的时候会自动找到对应的文件并转换成相应的格式,如果没有$f标记,则会将文件以二进制形式直接保存进数据库

 @warning 属性的名字应该与数据库字段的名字完全匹配!否则将无法完成ORM映射
 */
@interface NESBaseModel : NSObject

/** 在子类的初始化方法中为该属性赋值,如果没有赋值则会自动生成一个全部小写的默认的表名,格式为t_classname */
@property (nonatomic,retain) NSString *tableName;

/** 是否使用默认主键,默认为:YES
 
 在开启状态下不要为子类创建主键属性,每一个子类都会自动生成一个名为"类名_id"的自增主键,主键的所有字母均为小写
 @note 这里的主键与远程数据库中的主键并不相同,该主键仅用于维护本地数据库,当数据从远程获得时是如果包含主键字段,那么在放入本地数据库时会因为手动指定自增主键的值产生问题,如果远程获取的数据不包含主键值,那么会造成本地和远程数据库的同步问题,很难提出一个最好的解决方案,所以采用此种这种方案,在本地设立独立自增主键,而降远程服数据库的主键作为一个常规字段进行处理,如果服务器返回则存储,不返回则滞空即可
 @note "在子类的init方法中设置该属性为NO将其关闭,如果试用用默认的主键,需要手动声明主键名称,并在列名后添加_pk标记"
 
 - "\@property (nonatomic,copy) NSString * userId_pk;"
 *
 通过上述属性声明将指定当前表的主键名为userId
 
 */
@property (nonatomic,assign) BOOL useDefaultPK;

/** 如果包含$u字段标记的字段,即需要通过网络获取数据的字段,同是映射词典中包含的是相对路径而非完整URL,那么需要手动设置baseURL,否则无法获取指定数据 */
@property (nonatomic,copy) NSString *baseURL;

/** 通过当前类的属性列表创建完全匹配的数据库
 如果希望某个属性在数据库中不可见,在属性名后面添加_t标记
 
 @note  \@property (nonatomic,retain) NSString *confirm_t;
 */
-(NSString *)getCreateSQL;

/** 获取当前数据的主键值 
 无论是否开启useDefaultPK_t都可以正确的获取主键值
 */
-(NSInteger)getId;
/** 设置主键值
 无需知道当前表的主键究竟叫什么,调用setId:即可将主键设置到正确的列中
 @param newId 主键值;
 */
-(void)setId:(NSInteger)newId;

/** 获取一个空的实例 */
+(id)model;

/** ORM数据映射
 将FMDB返回的数据集直接映射到对象中,需要在确定 `FMResultSet` 的 `next` 方法返回值为YES的前提下调用,通常不需要直接调用
 @param 包含数据的FMResultSet实例
 @return 如果成功完成数据映射返回 YES,否则返回 NO.
 @waring 当前版本存在FMDB库的依赖,必须引入该三方库
 */
-(BOOL)mapping:(FMResultSet *)rs;

/** ORM数据映射方法
 将任何形词典对象映射为对应的实体对象,主要用在服务器返回数据的映射上
 @param dict 包含数据的词典对象
 @return 映射是否成功
 */
-(BOOL)mappingWithDictionary:(NSDictionary *)dict;

@end
