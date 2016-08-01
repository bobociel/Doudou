//
//  NetworkManager.m
//  NetworkManager
//
//  Created by imqiuhang on 15/3/30.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "NetworkManager.h"
#import "KCH.h"
#import "LoginManager.h"
//错误信息打印头
#define ERRORDOMAIN                           @"LOVEWITH"
#define ERROR_NoresultCode                    404
#define SuccessStateCode    200
@implementation NetworkManager

+ (NetworkManager *)sharedClient {
    static NetworkManager *_sharedClient = nil;
#if defined(__IPHONE_5_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_5_0
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
#ifdef DEBUG
        NSString * api = APIHOST;
        _sharedClient = [[NetworkManager alloc] initWithBaseURL:[NSURL URLWithString:api]];
        
#else
        _sharedClient = [[NetworkManager alloc] initWithBaseURL:[NSURL URLWithString:APIHOST]];
#endif
    });
#elif defined(__IPHONE_4_3) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_3
    if (nil == _sharedClient) {
        _sharedClient = [[NetworkManager alloc] initWithBaseURL:[NSURL URLWithString:APIHOST]];
    }
#else
#error 4.3以下不支持单例模式
#endif
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    //    [self.requestSerializer registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
    [self.requestSerializer setValue:@"application/xml" forHTTPHeaderField:@"Accept"];
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",nil];
    
    [self.requestSerializer setValue:[NSString stringWithFormat:@"client-system=%@;client-os=%@;",
                                      [UIDevice currentDevice].model,
                                      [NSString stringWithFormat:@"iphone_%@", [UIDevice currentDevice].systemVersion]
                                      ] forHTTPHeaderField:@"Cookie"];

    
    return  self;
}

- (void)postPath:(NSString *)path parameters:(NSDictionary *)parameters withBlock:(void (^)(NSDictionary *, NSError *))block {
    
    MSLog(@"path is %@ parms is %@",path,parameters);
    MSLog(@"request is %@",[self getRealPath:path]);
    
    [self POST:path
    parameters:parameters
       success:^(AFHTTPRequestOperation *operation, id JSON) {
           
           id result =JSON;
           
           MSLog(@"请求成功:result is\n%@",result);
           block([NSDictionary dictionaryWithDictionary:result], nil);
           
       }
       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           MSLog(@"请求失败返回错误:%@\noperation:%@",error,operation);
           MSLog(@"%li",(long)operation.response.statusCode);
           NSError *cusErr = [NSError errorWithDomain:error.domain code:error.code userInfo:operation.responseObject];
           //todo替换
           if ([cusErr.userInfo[@"status"] intValue] == 1038) {
               [LoginManager logoutWithFinishBlock:^{
                   
               }];
           }
           block(operation.responseObject, cusErr);
       }
     ];
}

- (AFHTTPRequestOperation *)getPath:(NSString *)path parameters:(NSDictionary *)parameters withBlock:(void (^)(NSDictionary *, NSError *))block expiredAfter:(NSInteger)expiredAfter {
    
    MSLog(@"request is %@",[self getRealPath:path parameters:parameters]);
    BOOL useCache = expiredAfter>=0?YES:NO;
    NSString *cacheKey =  [NSString stringWithFormat:@"%@%@",path,parameters];
    NSDictionary *cache = [Kache valueForKey:cacheKey];
    if(useCache&&cache){
        MSLog(@"请求使用的是缓存!");
        block([NSDictionary dictionaryWithDictionary:cache], nil);
        return nil;
    }else{
        
       return [self GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
              id result =JSON;
              if (block) {
                  if (!result) {
                      NSError *error = [NSError errorWithDomain:ERRORDOMAIN code:ERROR_NoresultCode userInfo:nil];
                      block(nil, error);
                      
                      MSLog(@"请求成功,但是里面没有数据");
                  } else {
                      if (useCache) {
                          [Kache setValue:result forKey:cacheKey expiredAfter:60*60*expiredAfter];
                      }
                      MSLog(@"请求成功:result is\n%@",result);
                      block([NSDictionary dictionaryWithDictionary:result], nil);
                  }
              } else {
                  
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MSLog(@"请求失败返回错误:%@\noperation:%@",error,operation);
              MSLog(@"%li",(long)operation.response.statusCode);
              if (block) {
                  NSError *cusErr = [NSError errorWithDomain:error.domain code:error.code userInfo:operation.responseObject];
                  //todo替换
                  if ([cusErr.userInfo[@"status"] intValue] == 1038) {
                      [LoginManager logoutWithFinishBlock:^{
                          
                      }];
                  }
                  block(operation.responseObject, cusErr);
              }
          }
         ];
    }
}



- (void)multipartFormPath:(NSString *)path parameters:(NSDictionary *)params fileSource:(NSArray *)fileSource withBlock:(void (^)(NSDictionary *, NSError *))block{
    
    MSLog(@"request is %@",[self getRealPath:path]);
    
    NSString * url = [NSString stringWithFormat:@"%@%@",self.baseURL,path];
    NSMutableURLRequest *request=[self.requestSerializer
                                  multipartFormRequestWithMethod:@"POST" URLString:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                      
                                      for (int i=0; i<[fileSource count]; i++) {
                                          NSData *fileData =[[fileSource objectAtIndex:i] valueForKey:@"imageData"];
                                          NSString *name = [[fileSource objectAtIndex:i] valueForKey:@"name"];
                                          NSString *filePath = [NSString stringWithFormat:@"%@-%d",name,i];
                                          //            NSString *filePath = [[fileSource objectAtIndex:i] valueForKey:@"filePath"];
                                          
                                          if (fileData != NULL) {
                                              [formData appendPartWithFileData:fileData name:name fileName:filePath mimeType:@"image/png"];
                                          }
                                      }
                                  } error:nil];
    
    
    AFHTTPRequestOperation *operation=[self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        id result =responseObject;
        if (block) {
            MSLog(@"%d",[[result objectForKey:@"status"] intValue]);
            if ([[result objectForKey:@"status"] intValue]!=SuccessStateCode) {
                NSError *error = [NSError errorWithDomain:ERRORDOMAIN code:[[result objectForKey:@"status"] intValue] userInfo:[NSDictionary dictionaryWithDictionary:result]];
                MSLog(@"服务器返回错误:msg:%@\nurl:%@\n",[result objectForKey:@"msg"],[NSString stringWithFormat:@"msg:%@",[NSString stringWithFormat:@"url:%@",operation.request.URL]]);
                block(nil, error);
            } else {
                block([NSDictionary dictionaryWithDictionary:result], nil);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            MSLog(@"请求失败返回错误:%@",error);
            block(nil, error);
        }
    }];
    
    [operation start];
}

- (void)multipartFormPath:(NSString *)path parameters:(NSDictionary *)params fileSource:(NSArray *)fileSource
            ProgressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progressBlock
          CompletionBlock:(void (^)(NSDictionary *responseJSON, NSError *error))comPleteBlock{
    MSLog(@"request is %@",[self getRealPath:path]);
    NSString * url = [NSString stringWithFormat:@"%@%@",self.baseURL,path];
    NSMutableURLRequest *request=[self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (int i=0; i<[fileSource count]; i++) {
            NSData *fileData =[[fileSource objectAtIndex:i] valueForKey:@"imageData"];
            NSString *name = [[fileSource objectAtIndex:i] valueForKey:@"name"];
            NSString *filePath = [[fileSource objectAtIndex:i] valueForKey:@"filePath"];
            
            if (fileData != NULL) {
                [formData appendPartWithFileData:fileData name:name fileName:filePath mimeType:@"image/png"];
            }
        }
    } error:nil];
    
    AFHTTPRequestOperation *operation=[self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        id result =responseObject;
        if (comPleteBlock) {
            if ([[result objectForKey:@"status"] intValue]!=SuccessStateCode) {
                NSError *error = [NSError errorWithDomain:ERRORDOMAIN code:[[result objectForKey:@"status"] intValue] userInfo:[NSDictionary dictionaryWithDictionary:result]];
                MSLog(@"服务器返回错误:msg:%@\nurl:%@\n",[result objectForKey:@"msg"],[NSString stringWithFormat:@"msg:%@",[NSString stringWithFormat:@"url:%@",operation.request.URL]]);
                comPleteBlock(nil, error);
            } else {
                comPleteBlock([NSDictionary dictionaryWithDictionary:result], nil);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (comPleteBlock) {
            MSLog(@"请求失败返回错误:%@",error);
            comPleteBlock(operation.responseObject, error);
        }
    }];
    
    [operation start];
}


- (AFHTTPRequestOperation *)getPath:(NSString *)path parameters:(NSDictionary *)parameters withBlock:(void (^)(NSDictionary *, NSError *))block useCache:(BOOL)useCache {
    int expiredAfter=useCache?defaultExpiredAfter:-1;
    return [self getPath:path parameters:parameters withBlock:block expiredAfter:expiredAfter];
}

- (void)cancelAllHTTPOperationsWithMethod:(NSString *)method path:(NSString *)path {
    for (AFHTTPRequestOperation * ap in self.operationQueue.operations) {
        if([ap.request.URL path] == path){
            [ap cancel];
        }
    }
}


- (NSString *) getRealPath:(NSString *)path parameters:(NSDictionary *)parameters {
    NSMutableString * query = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@%@?",self.baseURL,path]];
    for (NSString * key in (NSDictionary *)parameters) {
        [query appendString:[NSString stringWithFormat:@"%@=%@&",key,[parameters objectForKey:key]]];
    }
    
    return query;
}

- (NSString *) getRealPath:(NSString *)path {
    return [NSString stringWithFormat:@"%@%@",self.baseURL,path];
}
@end

