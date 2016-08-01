//
//  SHViewController.h
//  weddingTime
//
//  Created by jakf_17 on 15/9/29.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
typedef NS_OPTIONS(NSInteger, ListType) {
    supplier_type = 0,
    hotel_type = 1,
};
@interface WTSHViewController : BaseViewController
@property (nonatomic, assign) WTWeddingType supplier_type;
@property (nonatomic, assign) ListType listType;

@property (nonatomic, assign) BOOL isFromSearch;
-(void)beginSearchWithKwyWord:(NSString*)key;
@end
