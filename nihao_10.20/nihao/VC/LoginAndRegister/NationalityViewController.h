//
//  NationalityViewController.h
//  nihao 国籍选择
//
//  Created by 刘志 on 15/6/10.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "BaseViewController.h"
@class Nationality;

typedef NS_ENUM(NSUInteger,NationEnterSource) {
    NORMAL = 0,
    CONTACTS_FILTER,
};

@interface NationalityViewController : BaseViewController

@property (nonatomic,copy) void(^nationChoosed)(Nationality *nation);

@property (nonatomic,assign) NationEnterSource enterSource;

@property (nonatomic,copy) void(^allNationhoosed)(void);

@end
