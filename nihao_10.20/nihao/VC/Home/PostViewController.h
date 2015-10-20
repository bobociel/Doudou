//
//  PostViewController.h
//  nihao
//
//  Created by HelloWorld on 6/12/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "BaseViewController.h"
@class UserPost;

@interface PostViewController : BaseViewController

@property (nonatomic, copy) void(^post)(UserPost *post);

@end
