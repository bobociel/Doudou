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
#define ERRORDOMAIN            @"LOVEWITH"
#define ERROR_NoresultCode     404
#define SuccessStateCode       200
@implementation NetworkManager

+ (NetworkManager *)sharedClient {
    static NetworkManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[NetworkManager alloc] initWithBaseURL:[NSURL URLWithString:APIHOST]];
    });

    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
		[self.requestSerializer setValue:@"application/xml" forHTTPHeaderField:@"Accept"];
		self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"text/plain",nil];

		NSString *cookie = [NSString stringWithFormat:@"client-system=%@;client-os=%@;",[UIDevice currentDevice].model,[NSString stringWithFormat:@"iphone_%@",[UIDevice currentDevice].systemVersion] ];
		[self.requestSerializer setValue:cookie forHTTPHeaderField:@"Cookie"];
    }
    
    return  self;
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

#pragma mark - GET
- (NSURLSessionDataTask *)getPath:(NSString *)path parameters:(NSDictionary *)parameters withBlock:(void (^)(NSDictionary *, NSError *))block useCache:(BOOL)useCache {
	int expiredAfter=useCache?defaultExpiredAfter:-1;
	return [self getPath:path parameters:parameters withBlock:block expiredAfter:expiredAfter];
}

- (NSURLSessionDataTask *)getPath:(NSString *)path parameters:(NSDictionary *)parameters withBlock:(void (^)(NSDictionary *, NSError *))block expiredAfter:(NSInteger)expiredAfter {

	MSLog(@"request is %@",[self getRealPath:path parameters:parameters]);
	BOOL useCache = expiredAfter >= 0?YES:NO;
	NSString *cacheKey =  [NSString stringWithFormat:@"%@%@",path,parameters];
	NSDictionary *cache = [Kache valueForKey:cacheKey];
	if(useCache&&cache)
	{
		MSLog(@"请求使用的是缓存!");
		if(block) { block([NSDictionary dictionaryWithDictionary:cache], nil); }
		return nil;
	}
	else
	{
		NSURLSessionDataTask *task = [self GET:path parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject)
		{
			MSLog(@"请求成功:result is\n%@",responseObject);
			if(useCache) { [Kache setValue:responseObject forKey:cacheKey expiredAfter:60*60*expiredAfter]; }
			if(block) { block([NSDictionary dictionaryWithDictionary:responseObject], nil); }
		} failure:^(NSURLSessionDataTask *task, NSError *error) {
			MSLog(@"%li",(long)error.code);
			MSLog(@"请求失败返回错误:%@\noperation:%@",error,task.response);

			NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
			NSError *errorM = [NSError errorWithDomain:APIHOST code:response.statusCode userInfo:nil];
			if (errorM.code == 1038 ) {[LoginManager logoutWithFinishBlock:nil];}

			NSData *responseData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
			if(responseData){
				NSDictionary *reponseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
				errorM = [NSError errorWithDomain:APIHOST code:response.statusCode userInfo:reponseDict];
				if(block) { block(reponseDict, errorM); }
			}else {
				if(block) { block(nil, errorM); }
			}
		}];

		return task;
	}
}

#pragma mark - POST
- (void)postPath:(NSString *)path parameters:(NSDictionary *)parameters withBlock:(void (^)(NSDictionary *, NSError *))block {
    
    MSLog(@"path is %@ parms is %@",path,parameters);
    MSLog(@"request is %@",[self getRealPath:path]);
	[self POST:path parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
		MSLog(@"请求成功:result is\n%@",responseObject);
		if(block) { block([NSDictionary dictionaryWithDictionary:responseObject], nil); }
	} failure:^(NSURLSessionDataTask *task, NSError *error) {
		MSLog(@"%li",(long)error.code);
		MSLog(@"请求失败返回错误:%@\noperation:%@",error,task.response);

		NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
		NSError *errorM = [NSError errorWithDomain:APIHOST code:response.statusCode userInfo:nil];
		if (errorM.code == 1038 ) {[LoginManager logoutWithFinishBlock:nil];}

		NSData *responseData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
		if(responseData){
			NSDictionary *reponseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
			errorM = [NSError errorWithDomain:APIHOST code:response.statusCode userInfo:reponseDict];
			if(block) { block(reponseDict, errorM); }
		}else {
			if(block) { block(nil, errorM); }
		}
	}];
}

#pragma mark - PUT
- (void)putPath:(NSString *)path parameters:(NSDictionary *)parameters withBlock:(void (^)(NSDictionary *, NSError *))block {
    
    MSLog(@"path is %@ parms is %@",path,parameters);
    MSLog(@"request is %@",[self getRealPath:path]);
	[self PUT:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
		MSLog(@"请求成功:result is\n%@",responseObject);
		if(block) { block([NSDictionary dictionaryWithDictionary:responseObject], nil); }
	} failure:^(NSURLSessionDataTask *task, NSError *error) {
		MSLog(@"%li",(long)error.code);
		MSLog(@"请求失败返回错误:%@\noperation:%@",error,task.response);

		NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
		NSError *errorM = [NSError errorWithDomain:APIHOST code:response.statusCode userInfo:nil];
		if (errorM.code == 1038 ) {[LoginManager logoutWithFinishBlock:nil];}

		NSData *responseData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
		if(responseData){
			NSDictionary *reponseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
			errorM = [NSError errorWithDomain:APIHOST code:response.statusCode userInfo:reponseDict];
			if(block) { block(reponseDict, errorM); }
		}else {
			if(block) { block(nil, errorM); }
		}
	}];
}

#pragma mark - DELETE
- (void)deletePath:(NSString *)path parameters:(NSDictionary *)parameters withBlock:(void (^)(NSDictionary *, NSError *))block {

	MSLog(@"path is %@ parms is %@",path,parameters);
	MSLog(@"request is %@",[self getRealPath:path]);
	[self DELETE:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
		MSLog(@"请求成功:result is\n%@",responseObject);
		if(block){ block([NSDictionary dictionaryWithDictionary:responseObject], nil); }
	} failure:^(NSURLSessionDataTask *task, NSError *error) {
		MSLog(@"%li",(long)error.code);
		MSLog(@"请求失败返回错误:%@\noperation:%@",error,task.response);

		NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
		NSError *errorM = [NSError errorWithDomain:APIHOST code:response.statusCode userInfo:nil];
		if (errorM.code == 1038 ) {[LoginManager logoutWithFinishBlock:nil];}

		NSData *responseData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
		if(responseData){
			NSDictionary *reponseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
			errorM = [NSError errorWithDomain:APIHOST code:response.statusCode userInfo:reponseDict];
			if(block) { block(reponseDict, errorM); }
		}else {
			if(block) { block(nil, errorM); }
		}
	}];
}

#pragma mark - OTHER
/*
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

- (void)cancelAllHTTPOperationsWithMethod:(NSString *)method path:(NSString *)path {
    for (AFHTTPRequestOperation * ap in self.operationQueue.operations) {
        if([ap.request.URL path] == path){
            [ap cancel];
        }
    }
}
*/

@end

