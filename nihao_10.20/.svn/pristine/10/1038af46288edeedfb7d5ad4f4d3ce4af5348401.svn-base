//
//  PostDetailViewController.h
//  nihao
//
//  Created by HelloWorld on 6/19/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "BaseViewController.h"
@class UserPost;

typedef NS_ENUM(NSUInteger, PostDetailFromType) {
	PostDetailFromTypeDiscover = 0,
	PostDetailFromTypeFollow,
	PostDetailFromTypeMe,
};

@interface PostDetailViewController : BaseViewController

// 当前 Post 的 ID
@property (nonatomic, copy) NSString *postID;
@property (nonatomic, strong) UserPost *userPost;
// 从列表传入的 Cell 的高度，详情界面就可以直接设置 HeaderView 的高度。如果不是 Home 页的列表进入的，可以不用传，传 postID 即可
//@property (nonatomic, assign) CGFloat headerViewHeight;
// 该 Post 的评论总数
@property (nonatomic, assign) NSInteger commentCount;

@property (nonatomic, assign) PostDetailFromType postDetailFromType;

@property (nonatomic,copy) void(^deletePost)();

@end
