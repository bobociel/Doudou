//
//  WDStoryViewController.h
//  lovewith
//
//  Created by wangxiaobo on 15/5/14.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

typedef void(^StopUploadBlock)(BOOL isStop);

typedef enum {
    SegmentTypePhoto = 0,
    SegmentTypeVideo = 1
}SegmentType;

#import "BaseViewController.h"

@interface WTStoryListViewController : BaseViewController

@end
