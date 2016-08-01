//
//  NetworkManager.h
//  NetworkManager
//
//  Created by imqiuhang on 15/2/5.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#define defaultExpiredAfter 10
#define NetworkStuationNotGood @"网络情况不佳，请稍后再试"

@interface NetworkManager : AFHTTPRequestOperationManager

+ (NetworkManager *)sharedClient;

///post 
-(void)postPath:(NSString *)path parameters:(NSDictionary *)parameters withBlock:(void (^)(NSDictionary *, NSError *))block;

///get useCache是否使用缓存  默认缓存时间为10分钟
-(AFHTTPRequestOperation *)getPath:(NSString *)path parameters:(NSDictionary *)parameters withBlock:(void (^)(NSDictionary *, NSError *))block useCache:(BOOL)useCache;

///get 设置缓存时间
-(AFHTTPRequestOperation *)getPath:(NSString *)path parameters:(NSDictionary *)parameters withBlock:(void (^)(NSDictionary *, NSError *))block expiredAfter:(NSInteger)expiredAfter;

///上传文件
-(void)multipartFormPath:(NSString *)path parameters:(NSDictionary *)params fileSource:(NSArray *)fileSource withBlock:(void (^)(NSDictionary *, NSError *))block;

///上传文件  带进度信息
-(void)multipartFormPath:(NSString *)path parameters:(NSDictionary *)params fileSource:(NSArray *)fileSource
            ProgressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progressBlock
          CompletionBlock:(void (^)(NSDictionary *responseJSON, NSError *error))comPleteBlock;
 -(void)cancelAllHTTPOperationsWithMethod:(NSString *)method path:(NSString *)path;

@end
