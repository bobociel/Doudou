//
//  BlingHelper.h
//  weddingTime
//
//  Created by jakf_17 on 15/10/19.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlingHelper : NSObject

- (void)makeAlertWith:(NSDictionary *)result type:(int)type callback:(void(^)(void))callback;
- (void)makeRefuseAlertWith:(NSDictionary *)result;
- (void)makeSuccessAlertWith:(NSDictionary *)result;
- (void)makeCancelBindAlerWith:(NSDictionary *)result;
+ (void)updateInviteStateCallback:(void(^)(void))callback;
@end
