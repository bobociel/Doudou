//
//  NESBaseModel.m
//  NESDataSyncDemo
//
//  Created by Nestor on 14/12/8.
//  Copyright (c) 2014年 NesTalk. All rights reserved.
//

#import "NESBaseModel.h"
#import <objc/runtime.h>
#import "FMDatabase.h"
#import <CommonCrypto/CommonDigest.h>

#define TIMESTYLE_DATETIME  @"yyyy-MM-dd HH:mm:ss"
#define TIMESTYLE_DATE      @"yyyy-MM-dd"
#define TIMESTYLE_TIME      @"HH:mm:ss"

@interface NSString (md5)

-(NSString *)md5String;

@end

@implementation NSString (md5)

-(NSString *)md5String
{
    unsigned char digest[16], i;
    CC_MD5([self UTF8String], (unsigned int)[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    NSMutableString *ms = [NSMutableString string];
    for (i=0;i<16;i++) {
        [ms appendFormat: @"%x", (int)(digest[i])];
    }
    return ms;
}

@end

@interface NSDictionary (modelUtil)

-(NSString *)name;
-(long)mask;
-(NSString *)value;
-(NSInteger)integerForKey:(id)key;
-(NSString *)stringForKey:(id)key;
-(NSNumber *)numberForKey:(id)key;
@end

@implementation NSDictionary (modelUtil)

-(NSNumber *)numberForKey:(id)key
{

    id value = [self objectForKey:key];
    if (!value || [value isKindOfClass:[NSNull class]]) return [NSNumber numberWithInt:0];

    return value;
}

-(NSInteger)integerForKey:(id)key
{
    id value = [self objectForKey:key];
    if (!value || [value isKindOfClass:[NSNull class]]) return 0;
    return [value integerValue];
}

-(NSString *)stringForKey:(id)key
{
    id value = [self objectForKey:key];
    if (value == nil) return @"";
    if ([value isKindOfClass:[NSNumber class]]) return [NSString stringWithFormat:@"%@",value];
    if (![value isKindOfClass:[NSString class]]) return @"";
    if ([[value lowercaseString] isEqual:@"(null)"]) return @"";
    if ([[value lowercaseString] isEqual:@"<null>"]) return @"";
    
    return value;
}

-(NSString *)name
{
    return [self valueForKey:@"fieldName"];
}

-(long)mask
{
    return [[self valueForKey:@"mask"] longValue];
}

-(NSString *)value
{
    return [self valueForKey:@"value"];
}

@end

#pragma mark -
#pragma mark type check

bool isObject(NSString *type)
{
    return [type rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]].location != NSNotFound;
}

bool isString(NSString *type)
{
    return [type rangeOfString:@"NSString"].location != NSNotFound;
}

bool isData(NSString *type)
{
    return [type rangeOfString:@"NSData"].location != NSNotFound;
}

bool isImage(NSString *type)
{
    return [type rangeOfString:@"UIImage"].location != NSNotFound;
}

bool isDate(NSString *type)
{
    return [type rangeOfString:@"NSDate"].location != NSNotFound;
}

bool isInteger(NSString *type)
{
    
    return !isObject(type) && [type rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"cislqCISLQ"]].location != NSNotFound;
}

bool isLong(NSString *type)
{
    return !isObject(type) && [type rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"lLqQ"]].location != NSNotFound;
}

bool isFLoat(NSString *type)
{
    return !isObject(type) && [type rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"fd"]].location != NSNotFound;
}

bool isBool(NSString *type)
{
    return !isObject(type) && [type rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"B"]].location != NSNotFound;
}

#pragma mark -
#pragma mark TagMask

typedef NS_ENUM(NSInteger, TagMask)
{
    TagMaskPk = 1,
    TagMaskT = 1 << 2,
    TagMaskDT = 1 << 3,
    TagMaskD = 1 << 4,
    TagMaskTT = 1 << 5,
    TagMaskV = 1 << 6,
    TagMaskF = 1 << 7,
    TagMaskN = 1 << 8,
    TagMaskU = 1 << 9,
};


@interface NESBaseModel ()
{
    NSNumber *_defaultId;
}

@property (nonatomic,copy) NSString *defaultIdName;
@property (nonatomic,retain) NSMutableDictionary *validFields;
@property (nonatomic,retain) NSMutableDictionary *defaultValues;
@property (nonatomic,retain) NSMutableArray *alwaysNow;
@property (nonatomic,retain) NSMutableDictionary *cacheFields;
@property (nonatomic,retain) NSString *cachePath;
@property (nonatomic,assign,getter=isMapping) BOOL mapping;

@end

@implementation NESBaseModel

#pragma mark -
#pragma mark getters

-(NSMutableDictionary *)cacheFields
{
    if (!_cacheFields) {
        _cacheFields = [NSMutableDictionary dictionary];
    }
    return _cacheFields;
}

-(NSMutableArray *)alwaysNow
{
    if (!_alwaysNow) {
        _alwaysNow = [NSMutableArray array];
    }
    return _alwaysNow;
}

-(NSString *)tableName
{
    if (!_tableName) {
        _tableName = [[NSString stringWithFormat:@"t_%@",NSStringFromClass([self class])] lowercaseString];
    }
    
    return _tableName;
}

-(NSString *)cachePath
{
    if (!_cachePath) {
        _cachePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"fileCache/%@",self.tableName]];
    }
    
    return _cachePath;
}

-(NSMutableDictionary *)validFields
{
    if (!_validFields) {
        _validFields = [NSMutableDictionary dictionary];
    }
    return _validFields;
}

-(NSMutableDictionary *)defaultValues
{
    if (!_defaultValues) {
        _defaultValues = [NSMutableDictionary dictionary];
    }
    return _defaultValues;
}

-(NSString *)defaultIdName
{
    if (!_defaultIdName) {
        
        if (self.useDefaultPK) {
            _defaultIdName = [NSString stringWithFormat:@"%@_id",NSStringFromClass([self class])].lowercaseString;
        }
        else
        {
            [self enumerateIvarsUsingBlock:^(NSString *vName, NSString *vType, Ivar var, BOOL *stop, NSInteger index) {
                NSDictionary *dict = [self tagHandler:vName];
                if (dict.mask & TagMaskPk) {
                    _defaultIdName = dict.name;
                    *stop = YES;
                    return;
                }
            }];
        }
    }
    return _defaultIdName;
}

#pragma mark -
#pragma mark lifecycle

-(void)dealloc
{
    [self enumeratePropertiesUsingBlock:^(NSString *pName, objc_objectptr_t property, BOOL *stop, NSInteger index) {
        NSDictionary *dict = [self tagHandler:pName];
        
        if (dict.mask & TagMaskT) return;
        
        NSString *name = pName;
        [self removeObserver:self forKeyPath:name];
    }];
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.useDefaultPK = YES;
        
        [self enumeratePropertiesUsingBlock:^(NSString *pName, objc_objectptr_t property, BOOL *stop, NSInteger index) {
            
            NSDictionary *dict = [self tagHandler:pName];
            if (dict.mask & TagMaskT) return;
            if (dict.mask & TagMaskV) {
                [self.defaultValues setObject:dict.value forKey:dict.name];
            }
            if (dict.mask & TagMaskN) {
                [self.alwaysNow addObject:pName];
            }
            if (dict.mask & TagMaskF) {
                [self.cacheFields setObject:@"" forKey:pName];
            }
            
            [self addObserver:self
                   forKeyPath:pName
                      options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                      context:nil];
        }];
    }
    return self;
}

#pragma mark -
#pragma mark observer

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.isMapping) return;
    
    NSDictionary *dict = [self tagHandler:keyPath];
    NSString *name = dict.name;
    NSString *ivarName = [@"_" stringByAppendingString:keyPath];
    
    Ivar var = class_getInstanceVariable([self class], ivarName.UTF8String);
    
    id value = [change objectForKey:@"new"];
    
    NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(var)];
    
    if(isDate(type))
    {
        long mask = dict.mask;
        NSString *format;
        if (mask & TagMaskD) format = TIMESTYLE_DATE;
        else if (mask & TagMaskTT) format = TIMESTYLE_TIME;
        else format = TIMESTYLE_DATETIME;
        value = [[self dateFormatWithPattern:format] stringFromDate:value];
    }
    else if (isData(type))
    {
        if (dict.mask & TagMaskF) {
            NSString *fileName = [NSString stringWithFormat:@"%.0f%u",[[NSDate date] timeIntervalSince1970],arc4random() % 1000].md5String;
            id temp = value;
            value = fileName;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                NSString *oldName = [change objectForKey:@"old"];
                if (oldName != nil && ![oldName isKindOfClass:[NSNull class]] && oldName.length > 0) {
                    NSString *oldPath = [self.cachePath stringByAppendingPathComponent:oldName];
                    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:oldPath];
                    if (exists) {
                        [[NSFileManager defaultManager] removeItemAtPath:oldPath error:nil];
                    }
                }
                
                BOOL succ = [self cacheFileAtPath:self.cachePath name:fileName content:temp attr:nil];
                if (!succ) {
                    NESTodo(@"添加文件创建失败处理");
                    NESError(@"创建文件失败");
                }
            });


        }
    }
    else if (isImage(type))
    {
        if (![value isKindOfClass:[UIImage class]]) return;
        
        if (dict.mask & TagMaskF) {
            NSString *fileName = [NSString stringWithFormat:@"%.0f%u",[[NSDate date] timeIntervalSince1970],arc4random() % 1000].md5String;
            id temp = value;
            value = fileName;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSString *path = [self.cachePath stringByAppendingPathComponent:fileName];
                NSData *data    = UIImageJPEGRepresentation(temp, 1);
                if (!data) data = UIImagePNGRepresentation(temp);
                BOOL succ;
                NESAssertFlag([[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil], @"于 `%@` 位置创建文件失败", succ,path);
                if (!succ) {
                    NESTodo(@"添加文件创建失败处理");
                }

            });
            
        }
    }
    
    if (value == nil) {
        value = @"";
    }
    
    NESInfo(@"%@ - %@",name,value);
    
    [self.validFields setObject:value forKey:name];
}

#pragma mark -
#pragma mark api

-(BOOL)mappingWithDictionary:(NSDictionary *)dict
{
    
    [self enumerateIvarsUsingBlock:^(NSString *vName, NSString *vType, Ivar var, BOOL *stop, NSInteger index) {
        
        NSDictionary *config = [self tagHandler:vName];
        NSString *name = config.name;
        long mask = config.mask;
        
        if (mask & TagMaskT || mask & TagMaskPk) return;
        
        id value = [NSNull null];
        
        if (mask & TagMaskV) {
            value = [dict objectForKey:name];
            if (value == nil || [value isKindOfClass:[NSNull class]]) return;
        }
        
        if (isLong(vType) || isFLoat((vType)) || isInteger(vType) || isBool(vType))
            value = [dict numberForKey:name];
        else if (isString(vType))
            value = [dict stringForKey:name];
        else if (isDate(vType))
        {
            value = [dict stringForKey:name];
            NSString *format;
            if (mask & TagMaskD) format = TIMESTYLE_DATE;
            else if (mask & TagMaskTT) format = TIMESTYLE_TIME;
            else format = TIMESTYLE_DATETIME;
            
            value = [[self dateFormatWithPattern:format] dateFromString:value];
            
            if (value)
                objc_setAssociatedObject(value, @"format", format, OBJC_ASSOCIATION_COPY);
        }
        else if (isData(vType)){
            value = [dict objectForKey:name];
        }
        else if (isImage(vType))
        {
            value = [dict objectForKey:name];
            if ([value isKindOfClass:[NSData class]]) {
                value = [UIImage imageWithData:value];
            }
        }
        
        NESInfo(@"%@-%@-%@",name,vName,value);
        
        [self setValue:value forKey:vName];
        
    }];
    
    return YES;
}

-(BOOL)mapping:(FMResultSet *)rs
{
    sqlite3_stmt *stmt = rs.statement.statement;

    [self setId:[rs intForColumn:self.defaultIdName]];
    
    self.mapping = YES;
    
    [self enumerateIvarsUsingBlock:^(NSString *vName, NSString *vType, Ivar var, BOOL *stop, NSInteger index) {

        NSDictionary *dict = [self tagHandler:vName];
        NSString *name = dict.name;
        long mask = dict.mask;
        
        if (mask & TagMaskT || mask & TagMaskPk) return;
        
        int cIndex = [rs columnIndexForName:name];
    
        id value = [NSNull null];
        
        if (isLong(vType)) value = [NSNumber numberWithLongLong:sqlite3_column_int64(stmt, cIndex)];
        else if (isFLoat((vType))) value = [NSNumber numberWithDouble:sqlite3_column_double(stmt, cIndex)];
        else if (isInteger((vType))) value = [NSNumber numberWithInt:sqlite3_column_int(stmt, cIndex)];
        else if (isBool((vType))) value = [NSNumber numberWithInt:sqlite3_column_int(stmt, cIndex) != 0];
        else if (isString((vType))) value = [self stringForColumn:stmt index:cIndex];
        else if (isDate(vType)) [self dateForColumn:stmt index:cIndex mask:mask value:&value];
        else if (isData(vType))
        {
            if (mask & TagMaskF) {
                NSString *cacheName = [self stringForColumn:stmt index:cIndex];
                [self.cacheFields setObject:cacheName forKey:vName];
                value = [self dataWithContentOfCacheName:cacheName];
            }
            else
            {
                value = [self dataForColumn:stmt index:cIndex];
            }
            
        }
        else if (isImage(vType))
        {
            if (mask & TagMaskF) {
                NSString *cacheName = [self stringForColumn:stmt index:cIndex];
                [self.cacheFields setObject:cacheName forKey:vName];
                value = [self dataWithContentOfCacheName:cacheName];
                BOOL notNull;
                NESAssertFlag(value && [value isKindOfClass:[NSData class]], @"字段:%@没有图片",notNull,name);
                value = notNull ? [UIImage imageWithData:value] : value;
            }
            else
            {
                value = [self dataForColumn:stmt index:cIndex];
                BOOL notNull;
                NESAssertFlag(value && [value isKindOfClass:[NSData class]], @"字段:%@没有图片",notNull,name);
                value = notNull ? [UIImage imageWithData:value] : value;
            }

        }

        [self setValue:value forKey:vName];
        
    }];
    
    return YES;
}

-(NSString *)getCreateSQL
{
    __block NSString *fields = @"";

    [self enumerateIvarsUsingBlock:^(NSString *vName, NSString *vType, Ivar var, BOOL *stop, NSInteger index) {
        NSDictionary *dict = [self tagHandler:vName];
        NSString *name = dict.name;
        long mask = dict.mask;

        if (mask & TagMaskT || mask & TagMaskPk) return;
        
        NSString *type;
        
        if (isInteger(vType) || isBool(vType)) {
            type = @"INTEGER";
        }
        else if (isFLoat(vType))
        {
            type = @"REAL";
        }
        else if (isObject(vType))
        {
            type = (isString(vType) ||
                    isDate(vType) ||
                    ((isImage(vType) || isData(vType)) && (mask & TagMaskF))) ?
            @"TEXT" : @"BLOB";
        }
        
        fields = [NSString stringWithFormat:@"%@,%@ %@",fields,name,type];
    }];
    
    fields = [fields substringFromIndex:1];
    
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (%@ INTEGER PRIMARY KEY AUTOINCREMENT , %@)",self.tableName,self.defaultIdName,fields];
    
    return sql;
}

-(void)setId:(NSInteger)newId
{
    object_setIvar(self, class_getInstanceVariable([self class], "_defaultId"), [NSNumber numberWithInteger:newId]);
}

-(NSInteger)getId
{
    Ivar var = class_getInstanceVariable([self class], "_defaultId");
    return [object_getIvar(self, var) integerValue];
}

-(NSString *)description
{
    NSString *desc = [NSString stringWithFormat:@"MODEL-[%@]:{#REPLACE#}",NSStringFromClass([self class])];
    __block NSString *temp = @"";
    
    if (self.useDefaultPK) {
        temp = [NSString stringWithFormat:@",%@:%@",self.defaultIdName,@(self.getId)];
    }
    
    [self enumeratePropertiesUsingBlock:^(NSString *pName, objc_objectptr_t property, BOOL *stop, NSInteger index) {
        
        NSDictionary *dict = [self tagHandler:pName];
        
        if (dict.mask & TagMaskT) return ;
        
        NSString *name = dict.name;
        NSString *key = dict.mask & TagMaskPk ? @"defaultId" : pName;
        id value = [self valueForKey:key];
        
        if ([value isKindOfClass:[NSDate class]]) {
            NSDate *date = value;
            value = date.dateString;
        }
        
        temp = [NSString stringWithFormat:@"%@,%@:%@",temp,name,value];
    }];
    
    temp = [temp substringFromIndex:1];
    desc = [desc stringByReplacingOccurrencesOfString:@"#REPLACE#" withString:temp];
    return desc;
}

+(id)model
{
    return [[[self class] alloc] init];
}

#pragma mark -
#pragma mark util

-(BOOL)cacheFileAtPath:(NSString *)path name:(NSString *)name content:(NSData *)content attr:(NSDictionary *)attrs
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:path]) {
        BOOL succ;
        NESAssertFlag([manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil], @"于 `%@` 文件创建失败", succ,path);
        if (!succ) {
            NESTodo(@"添加创建文件失败处理");
            return NO;
        }
    }
    
    NSString *fileName = [path stringByAppendingPathComponent:name];
    return [manager createFileAtPath:fileName contents:content attributes:attrs];
}

-(void)enumeratePropertiesUsingBlock:(void (^)(NSString *pName,objc_objectptr_t property,BOOL *stop,NSInteger index))block
{
    unsigned int count;
    objc_property_t * props = class_copyPropertyList([self class], &count);
    BOOL stop = NO;
    for (unsigned int i = 0; i<count; i++) {
        objc_property_t property = props[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        block(name,property,&stop,i);
        if (stop) break;
    }
    free(props);
}

-(void)enumerateIvarsUsingBlock:(void (^)(NSString *vName,NSString *vType,Ivar var,BOOL *stop,NSInteger index))block
{
    unsigned int count;
    Ivar * ivars = class_copyIvarList([self class], &count);
    BOOL stop = NO;
    for (unsigned int i = 0; i<count; i++) {
        Ivar var = ivars[i];
        NSString *name = [[NSString stringWithUTF8String:ivar_getName(var)] substringFromIndex:1];
        NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(var)];
        NESInfo(@"name = %@",name);
        block(name,type,var,&stop,i);
        if (stop) break;
    }
    free(ivars);
}

-(NSDictionary *)tagHandler:(NSString *)name
{
    
    NSArray *arr = [name componentsSeparatedByString:@"$"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:arr.firstObject forKey:@"fieldName"];

    if (arr.count == 1) return dict;

    long mask = 0x0;
    
    NSString *last = [arr lastObject];
    
    if([arr indexOfObject:@"pk"] != NSNotFound) mask |= TagMaskPk;
    if([arr indexOfObject:@"t"] != NSNotFound) mask |= TagMaskT;
    if([arr indexOfObject:@"dt"] != NSNotFound) mask |= TagMaskDT;
    if([arr indexOfObject:@"tt"] != NSNotFound) mask |= TagMaskTT;
    if([arr indexOfObject:@"d"] != NSNotFound) mask |= TagMaskD;
    if([arr indexOfObject:@"f"] != NSNotFound) mask |= TagMaskF;
    if([arr indexOfObject:@"n"] != NSNotFound) mask |= TagMaskN;
    if([arr indexOfObject:@"u"] != NSNotFound) mask |= TagMaskU;
    
    if (last.UTF8String[0] == 'v') {
        mask |= TagMaskV;
        NSString *value = [last substringFromIndex:1];
        
        if (value.length == 0){

            NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(class_getInstanceVariable([self class], [@"_" stringByAppendingString:name].UTF8String))];
            
            if (isDate(type)) {
                if (mask & TagMaskD)
                    value = [[self dateFormatWithPattern:TIMESTYLE_DATE] stringFromDate:[NSDate date]];
                else if (mask & TagMaskTT)
                    value = [[self dateFormatWithPattern:TIMESTYLE_TIME] stringFromDate:[NSDate date]];
                else
                    value = [[self dateFormatWithPattern:TIMESTYLE_DATETIME] stringFromDate:[NSDate date]];
            }
            

        }

        [dict setValue:value forKey:@"value"];
    }
    
    [dict setObject:@(mask) forKey:@"mask"];
    
    return dict;
}

-(void)dateForColumn:(sqlite3_stmt *)stmt index:(int)index mask:(long)mask value:(id *)value;
{
    if (sqlite3_column_type(stmt,index) == SQLITE_NULL || (index < 0)) {
        *value = [NSNull null];
    }
    else
    {
        const char *c = (const char *)sqlite3_column_text(stmt, index);
        if (!c || strlen(c) == 0) {
            *value = [NSNull null];
        }
        else
        {
            NSString *format;
            if (mask & TagMaskD) format = TIMESTYLE_DATE;
            else if (mask & TagMaskTT) format = TIMESTYLE_TIME;
            else format = TIMESTYLE_DATETIME;
            
            *value = [[self dateFormatWithPattern:format] dateFromString:[NSString stringWithUTF8String:c]];
            
            objc_setAssociatedObject(*value, @"format", format, OBJC_ASSOCIATION_COPY);
        }
    }
}

-(NSString *)stringForColumn:(sqlite3_stmt *)stmt index:(int)index
{
    if (sqlite3_column_type(stmt,index) == SQLITE_NULL || (index < 0)) {
        return @"";
    }
    else
    {
        const char *c = (const char *)sqlite3_column_text(stmt, index);
        if (!c) {
            return @"";
        }
        else
            return [NSString stringWithUTF8String:c];
    }
}

-(id)dataWithContentOfCacheName:(NSString *)name
{
    NSString *path = [self.cachePath stringByAppendingPathComponent:name];
    NESInfo(@"file path%@",path);
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path]) {
        return [manager contentsAtPath:path];
    };
    
    return [NSNull null];
}

-(id)dataForColumn:(sqlite3_stmt *)stmt index:(int)index
{
    if (sqlite3_column_type(stmt, index) == SQLITE_NULL || (index < 0)) {
        return [NSNull null];
    }
    else
    {
        int dataSize = sqlite3_column_bytes(stmt, index);
        const char *dataBuffer = sqlite3_column_blob(stmt, index);
        
        if (dataBuffer == NULL) {
            return [NSNull null];
        }
        else
        {
            return [NSData dataWithBytes:(const void *)dataBuffer length:(NSUInteger)dataSize];
        }
    }
}

-(NSDateFormatter *)dateFormatWithPattern:(NSString *)pattern
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = pattern;
    fmt.timeZone = [NSTimeZone localTimeZone];

    return fmt;
}

@end

@implementation NSArray (NESBaseModelMapping)

-(NSArray *)mappingWithModel:(Class)modelClass
{
    if (![modelClass isSubclassOfClass:[NESBaseModel class]]) return nil;
    
    NSMutableArray *arr = [NSMutableArray array];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NESBaseModel *model = [[modelClass alloc] init];
        [model mappingWithDictionary:obj];
        [arr addObject:model];
    }];
    
    return arr;
}

@end

@implementation NSDate (NESDBSync)

-(NSString *)dateString
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.timeZone = [NSTimeZone localTimeZone];
    fmt.dateFormat = objc_getAssociatedObject(self, @"format");
    return [fmt stringFromDate:self];
}

@end

