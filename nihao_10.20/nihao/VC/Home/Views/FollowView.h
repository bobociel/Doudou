//
//  FollowView.h
//  nihao
//
//  Created by HelloWorld on 6/15/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "BaseView.h"

@interface FollowView : BaseView

@property (nonatomic, strong) UINavigationController *navController;

@property (nonatomic, copy) void(^reloadDatas)();

- (void)refreshTableView;

@end
