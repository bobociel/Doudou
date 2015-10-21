//
//  PostDetailViewController.m
//  nihao
//
//  Created by HelloWorld on 6/19/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "PostDetailViewController.h"
#import "BaseFunction.h"
#import "HttpManager.h"
#import "ListingLoadingStatusView.h"
#import "Comment.h"
#import <MJExtension/MJExtension.h>
#import "UITableView+FDTemplateLayoutCell.h"
#import "PostCommentCell.h"
#import "PostDetailHeaderView.h"
#import <MJRefresh/MJRefresh.h>
#import "AppConfigure.h"
#import "UserPost.h"
#import "UserInfoViewController.h"
#import "CommentToolbar.h"
#import "DynamicCell.h"
#import "ReportViewController.h"
#import "SettingMenu.h"
#import "EmptyListView.h"

#define TypingChooseWordHeight 21

@interface PostDetailViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, CommentToolbarDelegate, UIActionSheetDelegate> {
	ListingLoadingStatusView *_loadingStatus;
	//当前选中tableviewcell里面的图片集
	NSMutableArray *_imgs;
    SettingMenu *_menu;
}

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *sectionHeaderView;
//@property (strong, nonatomic) PostDetailHeaderView *postDetailHeaderView;
@property (strong, nonatomic) UILabel *commentCountLabel;
@property (strong, nonatomic) CommentToolbar *commentToolBar;
@property (strong, nonatomic) EmptyListView *emptyListView;

@property (nonatomic, assign) BOOL cellHeightCacheEnabled;

@end

static NSString *CommentsReusableCellIdentifier = @"CommentsCell";
static NSString *PostReusableCellIdentifier = @"PostCell";

@implementation PostDetailViewController {
    CGFloat selfViewRealHeight;
    CGSize lastChangeContentSize;
	// 保存评论列表
	NSMutableArray *commentList;
	NSInteger page;
	NSString *commentContent;
	// 是否是回复的状态
	BOOL isReply;
	// 选择的评论的位置
	NSIndexPath *selectedIndexPath;
	// 被回复的评论的源 id
	NSString *replyCommentSourceID;
	// 被回复的评论的用户的 id
	NSString *replyCommentUserID;
}

#pragma mark - view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self dontShowBackButtonTitle];
    [self addSettingMenu];
//	NSLog(@"postID = %@", self.postID);
	if (IsStringNotEmpty(self.postID)) {
		self.cellHeightCacheEnabled = YES;
		page = 1;
		commentList = [[NSMutableArray alloc] init];
		_imgs = [[NSMutableArray alloc] init];
		isReply = NO;
		replyCommentSourceID = @"";
		replyCommentUserID = @"";
		
		[self initLoadingViews];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.hidesBottomBarWhenPushed = YES;
}

#pragma mark - Lifecycle

- (void)dealloc {
	_tableView.delegate = nil;
	_tableView.dataSource = nil;
	_tableView = nil;
	
	self.commentToolBar.delegate = nil;
	self.commentToolBar = nil;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Private

// 初始化加载视图
- (void)initLoadingViews {
	_loadingStatus = [[ListingLoadingStatusView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
	__weak PostDetailViewController *weakSelf = self;
	_loadingStatus.refresh = ^() {
		[weakSelf requestPostComments];
	};
	[self.view addSubview:_loadingStatus];
	[_loadingStatus showWithStatus:Loading];
	self.tableView.hidden = YES;
	
	if (!self.userPost) {
		[self requestPostInfo];
	} else {
		[self requestPostComments];
	}
}

/**
 *  添加举报入口
 */
- (void) addSettingMenu {
    UIButton *button = [self createNavBtnByTitle:nil icon:@"icon_menu" action:@selector(menuClick)];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *spacerButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spacerButton.width = -20;
    self.navigationItem.rightBarButtonItems = @[spacerButton,barButton];
}

- (void) menuClick {
    if(!_menu) {
        _menu = [[SettingMenu alloc] init];
        [_menu setData:@[@"Report"]];
        __weak typeof(self) weakSelf = self;
        _menu.menuClickAtIndex = ^(NSInteger item) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf report];
        };
        [self.view addSubview:_menu];
    }
    
    if(_menu.hidden) {
        [_menu showInView:self.view];
    } else {
        [_menu dismiss];
    }
}

- (void) report {
    ReportViewController *reportController = [[ReportViewController alloc] initWithNibName:@"ReportViewController" bundle:nil];
    reportController.postId = [_postID integerValue];
    [self.navigationController pushViewController:reportController animated:YES];
}


#pragma mark - Networking
#pragma mark 获取评论详情
- (void)requestPostInfo {
	NSString *userID = [AppConfigure valueForKey:LOGINED_USER_ID];
	NSDictionary *parameters = @{@"cd_id" : self.postID, @"ci_id" : userID};
	[HttpManager requestPostInfoByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [resultDict[@"code"] integerValue];
		if (rtnCode == 0) {
			[UserPost setupObjectClassInArray:^NSDictionary *{
				return @{@"pictures" : @"Picture"};
			}];
			self.userPost = [UserPost objectWithKeyValues:resultDict[@"result"]];
			self.commentCount = self.userPost.cd_sum_cmi_count;
			[self requestPostComments];
		} else {
			[self processServerErrorWithCode:[responseObject[@"code"] integerValue] andErrorMsg:[responseObject objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
		[self showHUDNetError];
		if(_loadingStatus.hidden) {
			_loadingStatus.hidden = NO;
		}
		[_loadingStatus showWithStatus:NetErr];
	}];
}

#pragma mark 获取评论列表
- (void)requestPostComments {
	NSString *pageString = [NSString stringWithFormat:@"%ld", page];
	NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[self.postID, @"1", @"1", pageString, DEFAULT_REQUEST_DATA_ROWS]
														   forKeys:@[@"cmi_source_id", @"cmi_source_type", @"cmi_recursive_type", @"page", @"rows"]];
	[HttpManager requestCommentsByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [resultDict[@"code"] integerValue];
		if (rtnCode == 0) {
			[self hideHud];
			[self processPostComments:resultDict[@"result"]];
		} else {
			[self processServerErrorWithCode:[responseObject[@"code"] integerValue] andErrorMsg:[responseObject objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
		[self showHUDNetError];
		if(_loadingStatus.hidden) {
			_loadingStatus.hidden = NO;
		}
		[_loadingStatus showWithStatus:NetErr];
	}];
}

// 刷新评论列表
- (void)refreshPostCommentsList {
	page = 1;
	[self requestPostComments];
}

// 获取更多评论
- (void)loadMorePostCommentsList {
	page++;
	[self requestPostComments];
}

// 处理返回数据
- (void)processPostComments:(NSDictionary *)postComments {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
		if (page == 1) {
			[commentList removeAllObjects];
		}
		
		NSArray *tempArray = [Comment objectArrayWithKeyValuesArray:postComments[@"rows"]];
		[commentList addObjectsFromArray:tempArray];
		
		dispatch_async(dispatch_get_main_queue(), ^(){
			self.userPost.cd_sum_cmi_count = (int)commentList.count;
			if (!self.tableView) {
				[self initViews];
			} else {
//				[self.postDetailHeaderView configureHeaderViewWithPostInfo:self.userPost];
//				[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
			}
			
			// 还能获取更多数据
			if (tempArray.count >= DEFAULT_REQUEST_DATA_ROWS_INT) {
				self.tableView.footer.hidden = NO;
			} else {// 已经获取全部数据
				self.tableView.footer.hidden = YES;
			}
			// 如果列表有数据
			if (commentList.count > 0) {
				[_loadingStatus showWithStatus:Done];
//				self.tableView.header.hidden = NO;
			} else {// 如果列表没有数据
				if (!_loadingStatus.superview) {
					[self.view addSubview:_loadingStatus];
				}
				[_loadingStatus showWithStatus:Done];
				self.tableView.footer.hidden = YES;
//				self.tableView.header.hidden = YES;
			}
			
			if (self.tableView.footer.isRefreshing) {
				[self.tableView.footer endRefreshing];
			}
			if (self.tableView.header.isRefreshing) {
				[self.tableView.header endRefreshing];
			}
			
			self.commentCountLabel.text = [NSString stringWithFormat:@"Discuss(%ld)", commentList.count];
			self.tableView.hidden = NO;
			[self.tableView reloadData];
		});
	});
}

- (void)initViews {
    selfViewRealHeight = CGRectGetHeight(self.view.frame);
//    NSLog(@"self.view.height = %lf, selfViewRealHeight = %lf", CGRectGetHeight(self.view.frame), selfViewRealHeight);
    lastChangeContentSize.height = 36;
	
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, selfViewRealHeight - 45.0)];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight; // UIViewAutoresizingFlexibleWidth | ;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
	self.tableView.estimatedRowHeight = 65.0;
	[self.tableView registerNib:[UINib nibWithNibName:@"PostCommentCell" bundle:nil] forCellReuseIdentifier:CommentsReusableCellIdentifier];
	[self.tableView registerNib:[UINib nibWithNibName:@"DynamicCell" bundle:nil] forCellReuseIdentifier:PostReusableCellIdentifier];
	self.tableView.tableFooterView = [[UIView alloc] init];
	self.tableView.backgroundColor = RootBackgroundWhitelyColor;
//	self.tableView.sectionHeaderHeight = 30.0;
	
//	__weak typeof(self)weakSelf = self;
//	
//	if (!(CURRENT_IOS_VERSION >= 7.0 && CURRENT_IOS_VERSION < 8.0)) {
//		self.headerViewHeight += 14;
//	}
//	self.postDetailHeaderView = [[PostDetailHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.headerViewHeight)];
//	[self.postDetailHeaderView configureHeaderViewWithPostInfo:self.userPost];
//	self.postDetailHeaderView.deletePost = ^(){
//        __strong typeof(weakSelf) strongSelf = weakSelf;
//		[strongSelf deleteThisPost];
//	};
//	self.postDetailHeaderView.followUser = ^(){
//		__strong typeof(weakSelf) strongSelf = weakSelf;
//		[strongSelf followUser];
//	};
//	
//    __weak typeof(UserPost)*weakPost = self.userPost;
//    self.postDetailHeaderView.viewUserInfo = ^() {
//        __strong typeof(weakSelf) strongSelf = weakSelf;
//        __strong typeof(weakPost) strongPost = weakPost;
//        UserInfoViewController *controller = [[UserInfoViewController alloc] initWithNibName:@"UserInfoViewController" bundle:nil];
//        controller.uid = strongPost.cd_ci_id;
//        controller.uname = strongPost.ci_nikename;
//        [strongSelf.navigationController pushViewController:controller animated:YES];
//    };
//	self.tableView.tableHeaderView = self.postDetailHeaderView;
	
    [self.view addSubview:self.tableView];
	[BaseFunction addRefreshHeaderAndFooter:self.tableView refreshAction:@selector(refreshPostCommentsList) loadMoreAction:@selector(loadMorePostCommentsList) target:self];
    
	self.commentToolBar = [[CommentToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [CommentToolbar defaultHeight], self.view.frame.size.width, [CommentToolbar defaultHeight]) withPlaceholderText:COMMENT_HINT_TEXT];
	self.commentToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
	self.commentToolBar.delegate = self;
	self.commentToolBar.maxTextInputViewHeight = 100;
	[self.view addSubview:self.commentToolBar];
}

#pragma mark - DXMessageToolBarDelegate

- (void)didChangeFrameToHeight:(CGFloat)toHeight {
	[UIView animateWithDuration:kDefaultAnimationDuration animations:^{
		CGRect rect = self.tableView.frame;
		rect.origin.y = 0;
		rect.size.height = self.view.frame.size.height - toHeight;
		self.tableView.frame = rect;
	}];
	[self scrollViewToBottom:NO];
}

- (void)didSendText:(NSString *)text {
	[self keyBoardHidden];
	commentContent = text;
	[self sendComment];
}

- (void)scrollViewToBottom:(BOOL)animated {
	if (self.tableView.contentSize.height > self.tableView.frame.size.height) {
		CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
		[self.tableView setContentOffset:offset animated:animated];
	}
}

#pragma mark - click events
- (void)sendComment {
	if (IsStringNotEmpty(commentContent)) {
		// 如果是回复评论状态，则拼接回复的字符串
		if (isReply) {
			Comment *comment = [commentList objectAtIndex:selectedIndexPath.row];
//			commentContent = [NSString stringWithFormat:@"Reply@%@:%@", comment.ci_nikename, commentContent];
			replyCommentSourceID = [NSString stringWithFormat:@"%d", comment.cmi_id];
			replyCommentUserID = [NSString stringWithFormat:@"%d", comment.cmi_ci_id];
		}
		
		[self showHUDWithText:@""];
		[self commitUserComment];
//		[self showWithLabelText:@"" executing:@selector(commitUserComment)];
	}
}

/* 类似微信朋友圈，当在回复某个答案的时候，如果输入框内没有文字，那么就将状态改为非回复回答，即改为回答问题，改变提示文字，否则不都改变
 在回答问题的状态下，如果点击回复某条回答，将状态改为回复回答，输入框内的输入文字不变，改变提示文字 */
- (void)keyBoardHidden {
	[self.commentToolBar endEditing:YES];
	if (isReply) {
		if (self.commentToolBar.inputTextView.text.length == 0) {
			self.commentToolBar.hintText = COMMENT_HINT_TEXT;
			isReply = NO;
		}
	}
}

#pragma mark 提交用户评论
- (void)commitUserComment {
	NSString *currentUserID = [NSString stringWithFormat:@"%@", [AppConfigure objectForKey:LOGINED_USER_ID]];
//	commentContent = [BaseFunction encodeToPercentEscapeString:commentContent];
	
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:commentContent forKey:@"cmi_info"];// 评论内容
	[parameters setObject:currentUserID forKey:@"cmi_ci_id"];// 评论人 ID
	[parameters setObject:self.postID forKey:@"cmi_final_source_id"];// 评论最终源 ID
	[parameters setObject:@"1" forKey:@"cmi_final_source_type"];// 评论最终源属性
	NSString *finalSourceCiId = [NSString stringWithFormat:@"%d", self.userPost.cd_ci_id];
	[parameters setObject:finalSourceCiId forKey:@"cmi_final_source_ci_id"];// // 评论最终源用户 ID
    

	if (isReply) {
		[parameters setObject:replyCommentSourceID forKey:@"cmi_source_id"];// 评论源 ID
		[parameters setObject:replyCommentUserID forKey:@"cmi_source_ci_id"];// 评论源用户 ID
		[parameters setObject:@"2" forKey:@"cmi_source_type"];// 评论源属性
	} else {
		[parameters setObject:self.postID forKey:@"cmi_source_id"];
		[parameters setObject:@"1" forKey:@"cmi_source_type"];
		[parameters setObject:finalSourceCiId forKey:@"cmi_source_ci_id"];// 评论源用户 ID
	}
	
	NSLog(@"submit user comment parameters = %@", parameters);
	
	[HttpManager commitUserCommentByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"code"] integerValue] == 0) {
			[self hideHud];
			Comment *myComment = [Comment objectWithKeyValues:responseObject[@"result"]];
			myComment.ci_nikename = [AppConfigure objectForKey:LOGINED_USER_NICKNAME];
			myComment.ci_header_img = [AppConfigure objectForKey:LOGINED_USER_ICON_URL];
			myComment.ci_sex = [[AppConfigure objectForKey:LOGINED_USER_SEX] intValue];
			if (isReply) {
				Comment *comment = [commentList objectAtIndex:selectedIndexPath.row];
				myComment.cmi_source_nikename = comment.ci_nikename;
			}
			[commentList addObject:myComment];
			self.commentCount++;
			[self.tableView reloadData];
			self.commentCountLabel.text = [NSString stringWithFormat:@"Discuss(%ld)", self.commentCount];
			self.userPost.cd_sum_cmi_count++;
//			[self.postDetailHeaderView refreshHeaderViewWithFriendType:self.userPost.friend_type];
			[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
			[self keyBoardHidden];
//			[self requestPostComments];
//			[self keyBoardHidden];
		} else {
			[self processServerErrorWithCode:[responseObject[@"code"] integerValue] andErrorMsg:[responseObject objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"error = %@", error);
		[self showHUDErrorWithText:BAD_NETWORK];
	}];
}

#pragma mark 删除用户评论
- (void)deleteComment:(NSIndexPath *)indexPath {
	[self showHUDWithText:@""];
	Comment *comment = [commentList objectAtIndex:indexPath.row];
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	
	[parameters setObject:[NSString stringWithFormat:@"%d", comment.cmi_id] forKey:@"cmi_id"];
	[parameters setObject:[NSString stringWithFormat:@"%d", comment.cmi_ci_id] forKey:@"cmi_ci_id"];
	[parameters setObject:[NSString stringWithFormat:@"%d", comment.cmi_source_type] forKey:@"cmi_source_type"];
	[parameters setObject:self.postID forKey:@"cmi_final_source_id"];
	[parameters setObject:@"1" forKey:@"cmi_final_source_type"];
	
	[HttpManager deleteUserCommentByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [resultDict[@"code"] integerValue];
		if (rtnCode == 0) {
//			[commentList removeObjectAtIndex:indexPath.row];
//			self.commentCount--;
//			[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//			[self.tableView reloadSectionIndexTitles];
//			self.commentCountLabel.text = [NSString stringWithFormat:@"Discuss(%ld)", self.commentCount];
//			self.userPost.cd_sum_cmi_count--;
//			[self.postDetailHeaderView refreshHeaderViewWithFriendType:self.userPost.friend_type];
			[self requestPostComments];
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"error = %@", error);
		[self showHUDErrorWithText:BAD_NETWORK];
	}];
}

#pragma mark 点击用户头像
- (void)clickUserIcon:(NSIndexPath *)indexPath {
	Comment *comment = [commentList objectAtIndex:indexPath.row];
	UserInfoViewController *userInfoViewController = [[UserInfoViewController alloc] init];
	userInfoViewController.uid = comment.cmi_ci_id;
	userInfoViewController.uname = comment.ci_nikename;
	[self.navigationController pushViewController:userInfoViewController animated:YES];
}

#pragma mark 删除这条 Post
- (void)deleteThisPost {
	NSString *currentUserID = [NSString stringWithFormat:@"%@", [AppConfigure objectForKey:LOGINED_USER_ID]];
	NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[self.postID, currentUserID] forKeys:@[@"cd_id", @"cd_ci_id"]];
	[HttpManager deleteUserPostByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [resultDict[@"code"] integerValue];
		if (rtnCode == 0) {
			if (self.deletePost) {
				self.deletePost();
			}
			[self.navigationController popViewControllerAnimated:YES];
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
	}];
}

#pragma mark 关注对方
//- (void)followUser {
//	NSString *uid = [AppConfigure objectForKey:LOGINED_USER_ID];
//	if(self.userPost.friend_type == UserFriendTypeNone || self.userPost.friend_type == UserFriendTypeFollower) {
//		// follow
//		[self showHUDWithText:@"Following..."];
//		[HttpManager addRelationBySelfUserID:uid toPeerUserID:[NSString stringWithFormat:@"%d", self.userPost.cd_ci_id] success:^(AFHTTPRequestOperation *operation, id responseObject) {
//			if ([responseObject[@"code"] integerValue] == 0) {
//				[self showHUDDoneWithText:@"Followed"];
//				if (self.userPost.friend_type == UserFriendTypeNone) {
//					self.userPost.friend_type = 2;
//				} else {
//					self.userPost.friend_type = 4;
//				}
////				[self.postDetailHeaderView refreshHeaderViewWithFriendType:self.userPost.friend_type];
//				[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//			} else {
//				[self processServerErrorWithCode:[responseObject[@"code"] integerValue] andErrorMsg:responseObject[@"message"]];
//			}
//		} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
//			[self showHUDNetError];
//		}];
//	} else {
//		//delete focus
//		[self showHUDWithText:@"UnFollowing..."];
//		[HttpManager removeRelationBySelfUserID:uid toPeerUserID:[NSString stringWithFormat:@"%d", self.userPost.cd_ci_id] success:^(AFHTTPRequestOperation *operation, id responseObject) {
//			if ([responseObject[@"code"] integerValue] == 0) {
//				[self showHUDDoneWithText:@"Unfollowed"];
//				if (self.userPost.friend_type == UserFriendTypeFollowed) {
//					self.userPost.friend_type = 1;
//				} else {
//					self.userPost.friend_type = 3;
//				}
////				[self.postDetailHeaderView refreshHeaderViewWithFriendType:self.userPost.friend_type];
//				[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//			} else {
//				[self processServerErrorWithCode:[responseObject[@"code"] integerValue] andErrorMsg:responseObject[@"message"]];
//			}
//		} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
//			[self showHUDNetError];
//		}];
//	}
//}

#pragma mark 回复某一条评论或者回复
- (void)replyComment {
	Comment *comment = [commentList objectAtIndex:selectedIndexPath.row];
	self.commentToolBar.hintText = [NSString stringWithFormat:@"@%@", comment.ci_nikename];
	isReply = YES;
	[self.commentToolBar.inputTextView becomeFirstResponder];
}

#pragma mark - UITabBarDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 1;
	} else {
		return commentList.count;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return 0;
	} else {
		return 30;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return nil;
	} else {
		if (!self.sectionHeaderView) {
			self.sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
			self.sectionHeaderView.backgroundColor = RootBackgroundWhitelyColor;
			self.commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 6, SCREEN_WIDTH - 30, 17)];
			self.commentCountLabel.font = FontNeveLightWithSize(14.0);
			self.commentCountLabel.textColor = NormalTextColor;
			self.commentCountLabel.text = [NSString stringWithFormat:@"Discuss(%ld)", commentList.count];
			[self.sectionHeaderView addSubview:self.commentCountLabel];
		}
		
		return self.sectionHeaderView;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		DynamicCell *cell = [tableView dequeueReusableCellWithIdentifier:PostReusableCellIdentifier];
        self.navigationController.navigationBar.translucent = YES;
        cell.navigationController = self.navigationController;
		[self configureDynamicCell:cell atIndexPath:indexPath];
		__weak typeof(self) weakSelf = self;
		cell.addFoucs = ^(UserPost *post){
			weakSelf.userPost.friend_type = post.friend_type;
			[weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
		};
		cell.cancelFocus = ^(UserPost *post) {
			weakSelf.userPost.friend_type = post.friend_type;
			[weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
		};
		cell.viewUserInfo = ^(UserPost *post) {
			UserInfoViewController *controller = [[UserInfoViewController alloc] initWithNibName:@"UserInfoViewController" bundle:nil];
			controller.uname = post.ci_nikename;
			controller.uid = post.cd_ci_id;
			[weakSelf.navigationController pushViewController:controller animated:YES];
		};
		cell.deletePost = ^(UserPost *post, NSIndexPath *indexPath) {
			[weakSelf deleteThisPost];
		};
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	} else {
		PostCommentCell *cell = (PostCommentCell *)[tableView dequeueReusableCellWithIdentifier:CommentsReusableCellIdentifier forIndexPath:indexPath];
		[cell configureCellWithInfo:commentList[indexPath.row] forRowAtIndexPath:indexPath];
		__weak typeof(self)weakSelf = self;
		cell.deleteComment = ^(NSIndexPath *indexPath) {
			[weakSelf deleteComment:indexPath];
		};
		cell.clickUserIcon = ^(NSIndexPath *indexPath) {
			[weakSelf clickUserIcon:indexPath];
		};
		
		return cell;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	__weak typeof(self) weakSelf = self;
	if (self.cellHeightCacheEnabled) {
		if (indexPath.section == 0) {
			return [tableView fd_heightForCellWithIdentifier:PostReusableCellIdentifier cacheByIndexPath:indexPath configuration:^(DynamicCell *cell) {
				[weakSelf configureDynamicCell:cell atIndexPath:indexPath];
			}];
		} else {
			return [tableView fd_heightForCellWithIdentifier:CommentsReusableCellIdentifier cacheByIndexPath:indexPath configuration:^(PostCommentCell *cell) {
				[cell configureCellWithInfo:commentList[indexPath.row] forRowAtIndexPath:indexPath];
			}];
		}
	} else {
		if (indexPath.section == 0) {
			return [tableView fd_heightForCellWithIdentifier:PostReusableCellIdentifier configuration:^(DynamicCell *cell) {
				[weakSelf configureDynamicCell:cell atIndexPath:indexPath];
			}];
		} else {
			return [tableView fd_heightForCellWithIdentifier:CommentsReusableCellIdentifier configuration:^(PostCommentCell *cell) {
				[cell configureCellWithInfo:commentList[indexPath.row] forRowAtIndexPath:indexPath];
			}];
		}
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section != 0) {
		selectedIndexPath = indexPath;
		
		UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reply", @"Hide Keyboard", nil];
		[sheet showInView:self.view];
	}
}

- (void)configureDynamicCell:(DynamicCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	switch (self.postDetailFromType) {
		case PostDetailFromTypeDiscover:
			[cell configureCellForPostDetail:self.userPost forRowAtIndexPath:indexPath];
			break;
		case PostDetailFromTypeFollow:
			[cell configureCellForPostDetail:self.userPost forRowAtIndexPath:indexPath];
			break;
		case PostDetailFromTypeMe:
			[cell configureCellForMyPosts:self.userPost forRowAtIndexPath:indexPath];
			break;
	}
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	NSLog(@"buttonIndex = %ld", buttonIndex);
	switch (buttonIndex) {
		case 0:// Reply
			[self replyComment];
			break;
		case 1:// Hide Keyboard
			[self keyBoardHidden];
			break;
	}
}


@end
