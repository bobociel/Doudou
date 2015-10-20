//
//  ShareWithViewController.h
//  nihao
//
//  Created by 刘志 on 15/6/18.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "BaseViewController.h"

@interface ShareWithViewController : BaseViewController

//0表示所有人可见，1表示好友可见
@property (nonatomic, assign) NSInteger type;

@property (nonatomic, copy) void(^typeChanged)(NSInteger type);

@end
