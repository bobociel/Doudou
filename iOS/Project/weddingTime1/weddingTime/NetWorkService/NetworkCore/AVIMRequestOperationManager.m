//
//  AVIMRequestOperationManager.m
//  weddingTime
//
//  Created by 默默 on 15/11/13.
//  Copyright © 2015年 默默. All rights reserved.
//

#import "AVIMRequestOperationManager.h"

@implementation AVIMRequestOperationManager
+ (AVIMRequestOperationManager *)sharedClient
{
    static AVIMRequestOperationManager *_sharedClient = nil;
#if defined(__IPHONE_5_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_5_0
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
#ifdef DEBUG
        NSString * api = AVIMHOST;
        _sharedClient = [[AVIMRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:api]];
        
#else
        _sharedClient = [[AVIMRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:AVIMHOST]];
#endif
    });
#elif defined(__IPHONE_4_3) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_3
    if (nil == _sharedClient) {
        _sharedClient = [[AVIMRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:AVIMHOST]];
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
  //  self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",nil];
    [self.requestSerializer setValue:nil forHTTPHeaderField:@"Accept-Language"];
    [self.requestSerializer setValue:nil forHTTPHeaderField:@"User-Agent"];
    
    [self.requestSerializer setValue:AVOSAPPID forHTTPHeaderField:@"X-LC-Id"];
    [self.requestSerializer setValue:[NSString stringWithFormat:@"%@,master",AVOSMasterKey]  forHTTPHeaderField:@"X-LC-Key"];
   // [self.requestSerializer setValue:AVOSAPPKEY  forHTTPHeaderField:@"X-LC-Key"];
    [self.requestSerializer setValue:@"application/json"  forHTTPHeaderField:@"Content-Type"];
    
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
           block(operation.responseObject, cusErr);
       }
     ];
}

- (NSString *) getRealPath:(NSString *)path {
    return [NSString stringWithFormat:@"%@%@",self.baseURL,path];
}

@end
