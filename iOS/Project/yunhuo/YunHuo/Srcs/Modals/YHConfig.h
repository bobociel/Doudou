//
//  YHConfig.h
//  YunHuo
//
//  Created by yuyunfeng on 15/1/12.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHConfig : NSObject
@property (nonatomic) NSMutableArray	*yunhuoPages;
@property (nonatomic) BOOL				lanuchedBefore;
@property (nonatomic) BOOL				projectsLanuchedBefore;
@property (nonatomic) NSDate			*lastLanuchTime;

+ (YHConfig*) instance;

- (void) load;
- (void) save;

- (NSArray*) getVisibleYunHuoPages;

@end
