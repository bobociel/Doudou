//
//  NewsCommentListViewController.m
//  nihao
//
//  Created by HelloWorld on 6/26/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "NewsCommentListViewController.h"
#import <MJExtension/MJExtension.h>
#import "UITableView+FDTemplateLayoutCell.h"
#import "PostCommentCell.h"
#import <MJRefresh/MJRefresh.h>
#import "HttpManager.h"
#import "BaseFunction.h"
#import "Comment.h"
#import "AppConfigure.h"
#import "Constants.h"
#import "CommentToolbar.h"
#import <MJExtension/MJExtension.h>
#import "News.h"
#import "EmptyListView.h"
#import "UserInfoViewController.h"

@interface NewsCommentListViewController () <UITableViewDelegate, UITableViewDataSource, CommentToolbarDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) CommentToolbar *commentToolBar;
//@property (strong, nonatomic) UILabel *hintLabel;
@property (strong, nonatomic) EmptyListView *emptyListView;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

@property (nonatomic, assign) BOOL cellHeightCacheEnabled;

@end

static NSString *NewsCommentsReusableCellIdentifier = @"NewsCommentsCell";

@implementation NewsCommentListViewController {
	CGFloat selfViewRealHeight;
	CGSize lastChangContentSize;
	NSInteger page;
	NSMutableArray *commentList;
	NSString *commentContent;
	NSString *newID;
}
#pragma mark - view lifecycles
- (void)viewDidLoad {
    [super viewDidLoad];
    [self dontShowBackButtonTitle];
    self.title = @"Comments";
	newID = [NSString stringWithFormat:@"%d", self.news.ni_id];
	if (IsStringNotEmpty(newID)) {
		self.cellHeightCacheEnabled = YES;
		page = 1;
		commentList = [[NSMutableArray alloc] init];
		
		self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		self.indicatorView.hidesWhenStopped = YES;
		[self.view addSubview:self.indicatorView];
		self.indicatorView.center = self.view.center;
		[self.indicatorView startAnimating];
		
		[self requestNewsComments];
	}
}

#pragma mark - Lifecycle

- (void)dealloc {
	self.tableView.delegate = nil;
	self.tableView.dataSource = nil;
	self.tableView = nil;
	self.commentToolBar.delegate = nil;
	self.commentToolBar = nil;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - Private

- (void)initViews {
	selfViewRealHeight = CGRectGetHeight(self.view.frame);
//	NSLog(@"self.view.height = %lf, selfViewRealHeight = %lf", CGRectGetHeight(self.view.frame), selfViewRealHeight);
	lastChangContentSize.height = 36;
	
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, selfViewRealHeight - 45.0)];
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.estimatedRowHeight = 65.0;
	[self.tableView registerNib:[UINib nibWithNibName:@"PostCommentCell" bundle:nil] forCellReuseIdentifier:NewsCommentsReusableCellIdentifier];
	self.tableView.tableFooterView = [[UIView alloc] init];
	self.tableView.backgroundColor = RootBackgroundWhitelyColor;
	self.tableView.sectionHeaderHeight = 30.0;
	
	[self.view addSubview:self.tableView];
	[BaseFunction addRefreshHeaderAndFooter:self.tableView refreshAction:@selector(refreshNewsCommentsList) loadMoreAction:@selector(loadMoreNewsCommentsList) target:self];
	
	self.commentToolBar = [[CommentToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [CommentToolbar defaultHeight], self.view.frame.size.width, [CommentToolbar defaultHeight]) withPlaceholderText:COMMENT_HINT_TEXT];
	self.commentToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
	self.commentToolBar.delegate = self;
	self.commentToolBar.maxTextInputViewHeight = 100;
	[self.view addSubview:self.commentToolBar];
	
	self.emptyListView = [[EmptyListView alloc] init];
	self.emptyListView.hidden = YES;
	[self.tableView addSubview:self.emptyListView];
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden)];
	[self.view addGestureRecognizer:tap];
}

#pragma mark - networking
#pragma mark 获取新闻评论
- (void)requestNewsComments {
	NSString *pageString = [NSString stringWithFormat:@"%ld", (long)page];
	NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[newID, @"3", @"1", pageString, DEFAULT_REQUEST_DATA_ROWS]
														   forKeys:@[@"cmi_source_id", @"cmi_source_type", @"cmi_recursive_type", @"page", @"rows"]];
	NSLog(@"parameters = %@", parameters);
	[HttpManager requestCommentsByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [resultDict[@"code"] integerValue];
		if (rtnCode == 0) {
			[self processNewsComments:resultDict[@"result"]];
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
		[self showHUDNetError];
	}];
}

// 刷新评论列表
- (void)refreshNewsCommentsList {
	page = 1;
	[self requestNewsComments];
}

// 获取更多评论
- (void)loadMoreNewsCommentsList {
	page++;
	[self requestNewsComments];
}

// 发送用户评论
- (void)sendComment {
	NSString *currentUserID = [NSString stringWithFormat:@"%@", [AppConfigure objectForKey:LOGINED_USER_ID]];
//	commentContent = [BaseFunction encodeToPercentEscapeString:commentContent];
	NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[commentContent, currentUserID, newID, @"3",newID,@"3"] forKeys:@[@"cmi_info", @"cmi_ci_id", @"cmi_source_id", @"cmi_source_type",@"cmi_final_source_id",@"cmi_final_source_type"]];
	[HttpManager commitUserCommentByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [resultDict[@"code"] integerValue];
		[self hideHud];
		if (rtnCode == 0) {
			Comment *myComment = [Comment objectWithKeyValues:responseObject[@"result"]];
			myComment.ci_nikename = [AppConfigure objectForKey:LOGINED_USER_NICKNAME];
			myComment.ci_header_img = [AppConfigure objectForKey:LOGINED_USER_ICON_URL];
			myComment.ci_sex = [[AppConfigure objectForKey:LOGINED_USER_SEX] intValue];
			[commentList addObject:myComment];
			[self.tableView reloadData];
			[self scrollViewToBottom:NO];
//			self.hintLabel.hidden = YES;
			self.emptyListView.hidden = YES;
			self.news.ni_sum_cmi_count = (int)commentList.count;
			[self keyBoardHidden];
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"error = %@", error);
		[self showHUDErrorWithText:BAD_NETWORK];
	}];
}

// 删除用户评论
- (void)deleteComment:(NSIndexPath *)indexPath {
	[self showHUDWithText:@"Delete..."];
	Comment *comment = [commentList objectAtIndex:indexPath.row];
	NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[[NSString stringWithFormat:@"%d", comment.cmi_id], [NSString stringWithFormat:@"%d", comment.cmi_ci_id], @"3"] forKeys:@[@"cmi_id", @"cmi_ci_id", @"cmi_source_type"]];
//	NSLog(@"deleteComment parameters = %@", parameters);
	[HttpManager deleteUserCommentByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [resultDict[@"code"] integerValue];
		[self hideHud];
		if (rtnCode == 0) {
			[commentList removeObjectAtIndex:indexPath.row];
			[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
			if (commentList.count <= 0) {
//				self.hintLabel.hidden = NO;
				[self showHintView];
			}
			self.news.ni_sum_cmi_count = (int)commentList.count;
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"error = %@", error);
		[self showHUDErrorWithText:BAD_NETWORK];
	}];
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
	commentContent = text;
	[self keyBoardHidden];
	[self showHUDWithText:@"Send..."];
	[self sendComment];
}

- (void)scrollViewToBottom:(BOOL)animated {
	if (self.tableView.contentSize.height > self.tableView.frame.size.height) {
		CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
		[self.tableView setContentOffset:offset animated:animated];
	}
}

#pragma mark - other functions
// 处理返回的新闻评论列表数据
- (void)processNewsComments:(NSDictionary *)newsComments {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
		if (page == 1) {
			[commentList removeAllObjects];
		}
		NSArray *tempArray = [Comment objectArrayWithKeyValuesArray:newsComments[@"rows"]];
		[commentList addObjectsFromArray:tempArray];
		
		dispatch_async(dispatch_get_main_queue(), ^(){
			if (!self.tableView) {
				[self initViews];
			}
			
			// 还能获取更多数据
			if (tempArray.count >= DEFAULT_REQUEST_DATA_ROWS_INT) {
				self.tableView.footer.hidden = NO;
			} else {// 已经获取全部数据
				self.tableView.footer.hidden = YES;
			}
			// 如果列表有数据
			if (commentList.count > 0) {
//				self.hintLabel.hidden = YES;
				self.emptyListView.hidden = YES;
				self.tableView.header.hidden = NO;
			} else {// 如果列表没有数据
//				self.hintLabel.hidden = NO;
				[self showHintView];
				self.tableView.footer.hidden = YES;
				self.tableView.header.hidden = YES;
			}
			
			if (self.tableView.footer.isRefreshing) {
				[self.tableView.footer endRefreshing];
			}
			if (self.tableView.header.isRefreshing) {
				[self.tableView.header endRefreshing];
			}
			
			[self.indicatorView stopAnimating];
			
			self.tableView.hidden = NO;
			[self.tableView reloadData];
		});
	});
}

- (void)showHintView {
	self.emptyListView.hidden = NO;
	[self.emptyListView setHintText:@"Add a new Comment"];
}

#pragma mark 点击用户头像
- (void)clickUserIcon:(NSIndexPath *)indexPath {
	Comment *comment = [commentList objectAtIndex:indexPath.row];
	UserInfoViewController *userInfoViewController = [[UserInfoViewController alloc] init];
	userInfoViewController.uid = comment.cmi_ci_id;
	userInfoViewController.uname = comment.ci_nikename;
	[self.navigationController pushViewController:userInfoViewController animated:YES];
}

#pragma mark - UITabBarDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return commentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	PostCommentCell *cell = (PostCommentCell *)[tableView dequeueReusableCellWithIdentifier:NewsCommentsReusableCellIdentifier forIndexPath:indexPath];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.cellHeightCacheEnabled) {
		return [tableView fd_heightForCellWithIdentifier:NewsCommentsReusableCellIdentifier cacheByIndexPath:indexPath configuration:^(PostCommentCell *cell) {
			[cell configureCellWithInfo:commentList[indexPath.row] forRowAtIndexPath:indexPath];
		}];
	} else {
		return [tableView fd_heightForCellWithIdentifier:NewsCommentsReusableCellIdentifier configuration:^(PostCommentCell *cell) {
			[cell configureCellWithInfo:commentList[indexPath.row] forRowAtIndexPath:indexPath];
		}];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - private
- (void)keyBoardHidden {
	[self.commentToolBar endEditing:YES];
}

@end
