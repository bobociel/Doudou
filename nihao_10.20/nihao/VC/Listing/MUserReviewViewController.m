//
//  MUserReviewViewController.m
//  nihao
//
//  Created by HelloWorld on 8/24/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "MUserReviewViewController.h"
#import "HttpManager.h"
#import "MerchantComment.h"
#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>
#import "UITableView+FDTemplateLayoutCell.h"
#import "MCommentCell.h"
#import "BaseFunction.h"
#import "UserInfoViewController.h"
#import "ListingLoadingStatusView.h"

@interface MUserReviewViewController () <UITableViewDelegate, UITableViewDataSource> {
	ListingLoadingStatusView *_loadingStatus;
}

@property (nonatomic, strong) UITableView *tableView;

@end

static NSString *CommentCellID = @"MCommentCell";

@implementation MUserReviewViewController {
	NSMutableArray *comments;
	NSInteger page;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.title = @"User review";
	
	comments = [[NSMutableArray alloc] init];
	page = 1;
	
	[self initLoadingViews];
	
	self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.tableFooterView = [[UIView alloc] init];
	[self.tableView registerNib:[UINib nibWithNibName:CommentCellID bundle:nil] forCellReuseIdentifier:CommentCellID];
	[self.view addSubview:self.tableView];
	
	[BaseFunction addRefreshHeaderAndFooter:self.tableView refreshAction:@selector(refreshComments) loadMoreAction:@selector(loadMoreComments) target:self];
	self.tableView.footer.hidden = YES;
	self.tableView.hidden = YES;
	
	[self requestMerchantComments];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.tableView.frame = self.view.bounds;
}

#pragma mark - Lifecycle

- (void)dealloc {
	self.tableView.delegate = nil;
	self.tableView.dataSource = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

// 初始化加载视图
- (void)initLoadingViews {
	_loadingStatus = [[ListingLoadingStatusView alloc] initWithFrame:self.view.bounds];
	__weak MUserReviewViewController *weakSelf = self;
	__weak ListingLoadingStatusView *weakStatusView = _loadingStatus;
	[_loadingStatus showWithStatus:Loading];
	self.tableView.hidden = YES;
	_loadingStatus.refresh = ^() {
		[weakStatusView showWithStatus:Loading];
		[weakSelf requestMerchantComments];
	};
	[self.view addSubview:_loadingStatus];
	[_loadingStatus showWithStatus:Loading];
}

#pragma mark - Networking

- (void)requestMerchantComments {
	NSString *merchantIDString = [NSString stringWithFormat:@"%ld", self.merchantID];
	NSString *pageString = [NSString stringWithFormat:@"%ld", page];
	NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[merchantIDString, @"5", @"1", pageString, DEFAULT_REQUEST_DATA_ROWS]
														   forKeys:@[@"cmi_source_id", @"cmi_source_type", @"cmi_recursive_type", @"page", @"rows"]];
	//	NSLog(@"request Merchant Comment List parameters = %@", parameters);
	[HttpManager requestCommentsByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"code"] integerValue] == 0) {
			[MerchantComment setupObjectClassInArray:^NSDictionary *{
				return @{ @"pictures" : @"Picture" };
			}];
			NSArray *commentList = responseObject[@"result"][@"rows"];
			comments = [MerchantComment objectArrayWithKeyValuesArray:commentList];
			
			// 还能获取更多数据
			if (commentList.count >= DEFAULT_REQUEST_DATA_ROWS_INT) {
				self.tableView.footer.hidden = NO;
			} else {// 已经获取全部数据
				self.tableView.footer.hidden = YES;
			}
			// 如果列表有数据
			if (commentList.count > 0) {
				[_loadingStatus showWithStatus:Done];
			} else {// 如果列表没有数据
				if (!_loadingStatus.superview) {
					[self.view addSubview:_loadingStatus];
				}
				[_loadingStatus showWithStatus:Empty];
				self.tableView.footer.hidden = YES;
			}
			
			if (self.tableView.footer.isRefreshing) {
				[self.tableView.footer endRefreshing];
			}
			if (self.tableView.header.isRefreshing) {
				[self.tableView.header endRefreshing];
			}
			
			self.tableView.hidden = NO;
			[self.tableView reloadData];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
	}];
}

- (void)refreshComments {
	page = 1;
	[self requestMerchantComments];
}

- (void)loadMoreComments {
	page++;
	[self requestMerchantComments];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	MCommentCell *cell = (MCommentCell *)[tableView dequeueReusableCellWithIdentifier:CommentCellID];
	[cell configureCellWithMerchantComment:comments[indexPath.row] commentContentType:MCommentContentTypeDetail];
	__weak typeof(self) weakSelf = self;
	cell.clickedUserIcon = ^(MerchantComment *comment) {
		[weakSelf lookUserInfoById:comment.ci_id userNickname:comment.ci_nikename];
	};
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [tableView fd_heightForCellWithIdentifier:CommentCellID configuration:^(MCommentCell *cell) {
		[cell configureCellWithMerchantComment:comments[indexPath.row] commentContentType:MCommentContentTypeDetail];
	}];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Touch Events

- (void)lookUserInfoById:(NSInteger)userId userNickname:(NSString *)nickname {
	UserInfoViewController *userInfoViewController = [[UserInfoViewController alloc] init];
	userInfoViewController.uid = userId;
	userInfoViewController.uname = nickname;
	[self.navigationController pushViewController:userInfoViewController animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
