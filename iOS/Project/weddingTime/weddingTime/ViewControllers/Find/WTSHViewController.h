//
//  SHViewController.h
//  weddingTime
//
//  Created by jakf_17 on 15/9/29.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "WTFilterHotelViewController.h"
@interface WTSHViewController : BaseViewController
@property (nonatomic, assign) WTWeddingType supplier_type;
@property (nonatomic, assign) WTSegmentType segmentType;

- (void)beginSearchWithKwyWord:(NSString*)key;
- (void)filterDataWithSType:(WTWeddingType)type
                    segType:(WTSegmentType)segType
                      synID:(NSString *)synID
                    filters:(WTHotelFilters *)filters;
@end
