//
//  DiscoverView.h
//  nihao
//
//  Created by HelloWorld on 6/15/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "BaseView.h"
@class UserPost;

@interface DiscoverView : BaseView

@property (nonatomic, strong) UINavigationController *navController;

- (void)refreshTableView;

- (void) addUserPost : (UserPost *) post atIndex:(NSInteger) index;

@end
