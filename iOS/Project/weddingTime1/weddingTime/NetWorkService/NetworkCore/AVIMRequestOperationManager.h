//
//  AVIMRequestOperationManager.h
//  weddingTime
//
//  Created by 默默 on 15/11/13.
//  Copyright © 2015年 默默. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface AVIMRequestOperationManager : AFHTTPRequestOperationManager
+ (AVIMRequestOperationManager *)sharedClient;
-(void)postPath:(NSString *)path parameters:(NSDictionary *)parameters withBlock:(void (^)(NSDictionary *, NSError *))block;
@end
