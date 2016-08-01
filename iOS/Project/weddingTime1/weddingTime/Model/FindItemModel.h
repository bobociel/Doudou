//
//  FindItemModel.h
//  weddingTime
//
//  Created by jakf_17 on 15/9/23.
//  Copyright (c) 2015年 默默. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLiteProtocol.h"
typedef NS_ENUM(NSInteger,FindItemType) {
	FindItemTypeSupplier = 1,
	FindItemTypeInspiretion ,
	FindItemTypeTopic,
	FindItemTypePost
};

@interface FindItemModel : NSObject <SQLiteProtocol>

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *city_id;
@property (nonatomic, copy) NSString *post_id;
@property (nonatomic, copy) NSString *supplier_id;
@property (nonatomic, assign) long long update_time;
@property (nonatomic, assign) FindItemType type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, copy) NSString *counts;

@end
