//
//  WTWeddingStory.h
//  weddingTime
//
//  Created by wangxiaobo on 15/12/11.
//  Copyright © 2015年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYKit.h"
typedef enum {
	WTFileTypeImage          = 1,
	WTFileTypeAudio ,
	WTFileTypeVideo ,
}WTFileType;

@interface WTWeddingStory : NSObject <YYModel>
@property (nonatomic, assign) CGFloat ID;
@property (nonatomic, assign) WTFileType media_type;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *media;
@property (nonatomic, copy) NSString *path;
//@property (nonatomic,assign) double sort;
//@property (nonatomic,assign) double user;
//@property (nonatomic, copy) NSString *title;
- (BOOL)hasSource;

@end
