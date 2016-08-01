//
//  BlingService.h
//  weddingTime
//
//  Created by jakf_17 on 15/9/18.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlingService : NSObject

+ (void)blingPartnerWithPhone:(NSString *)phone block:(void (^)(NSDictionary *result, NSError *error))block;
+ (void)getInviteStateWithBlock:(void (^)(NSDictionary *result, NSError *error))block;
+ (void)acceptInviteWithBlock:(void (^)(NSDictionary *result, NSError *error))block;
+ (void)refuseInviteWithBlock:(void (^)(NSDictionary *result, NSError *error))block;

@end
