//
//  DataBaseManager.m
//  PhotoDemo
//
//  Created by hangzhou on 15/10/9.
//  Copyright (c) 2015年 hangzhou. All rights reserved.
//

#import "DataBaseManager.h"
#import "FMDatabase.h"
@interface DataBaseManager ()
@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, copy) NSString *userDirectory;
@property (nonatomic, copy) NSString *databasePath;
@end

@implementation DataBaseManager

+ (DataBaseManager *)sharedInstance
{
    static DataBaseManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DataBaseManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        
    }
    return self;
}


- (void)loadDatabase
{
    if(![[NSFileManager defaultManager] fileExistsAtPath:self.userDirectory])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:self.userDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if(self.db)
    {
        [self.db close];
        self.db = nil;
    }
    
    self.db = [FMDatabase databaseWithPath:self.databasePath];
    
    if(![self.db open])
    {
        NSLog(@"数据库打开失败：%@",self.databasePath);
    }
    
    
    
}

- (NSString *)userDirectory
{
    NSString *documentDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [NSString stringWithFormat:@"%@/%@",@"007",documentDirectory];
}

- (NSString *)databasePath
{
    return [self.userDirectory stringByAppendingString:@"/DataCache.db"];
}

@end
