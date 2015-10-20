//
//  AnswerDetailViewController.m
//  nihao
//
//  Created by HelloWorld on 8/14/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "AnswerDetailViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "CommentToolbar.h"
#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>
#import "BaseFunction.h"
#import "Comment.h"
#import "AnswerReplyCell.h"
#import "AskAnswerCell.h"
#import "HttpManager.h"
#import "ListingLoadingStatusView.h"
#import "AppConfigure.h"
#import "ReportViewController.h"

#define TagDeleteReplyAlert 10
#define TagDeleteAnswerAlert 11

@interface AnswerDetailViewController () <UITableViewDelegate, UITableViewDataSource, CommentToolbarDelegate, AskAnswerCellDelegate, AnswerReplyCellDelegate, UIAlertViewDelegate, UIActionSheetDelegate> {
	ListingLoadingStatusView *_loadingStatus;
}

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) CommentToolbar *answerToolBar;

@end

static NSString *AnswerContentCellID = @"AnswerContentCell";
static NSString *AnswerReplyCellID = @"AnswerReplyCell";

@implementation AnswerDetailViewController {
	CGFloat viewHeight;
	CGSize lastChangeContentSize;
	NSMutableArray *dataSource;
	NSInteger page;
	NSString *replyContent;
	NSIndexPath *deleteReplyIndexPath;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	dataSource = [[NSMutableArray alloc] init];
	page = 1;
	
	[self initLoadingViews];
	[self requestAnswerReplyList];
}

#pragma mark - Lifecycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)initViews {
	viewHeight = SCREEN_HEIGHT - 64;
	lastChangeContentSize.height = 36;
	
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, viewHeight - 44)];
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.estimatedRowHeight = 85.0;
	[self.tableView registerNib:[UINib nibWithNibName:@"AskAnswerCell" bundle:nil] forCellReuseIdentifier:AnswerContentCellID];
	[self.tableView registerNib:[UINib nibWithNibName:@"AnswerReplyCell" bundle:nil] forCellReuseIdentifier:AnswerReplyCellID];
	
	self.tableView.tableFooterView = [[UIView alloc] init];
	self.tableView.backgroundColor = RootBackgroundWhitelyColor;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[BaseFunction addRefreshHeaderAndFooter:self.tableView refreshAction:@selector(refreshAnswer) loadMoreAction:@selector(loadMoreAnswerReply) target:self];
	[self.view addSubview:self.tableView];
	self.tableView.footer.hidden = YES;
	self.tableView.hidden = YES;
	
	self.answerToolBar = [[CommentToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [CommentToolbar defaultHeight], self.view.frame.size.width, [CommentToolbar defaultHeight]) withPlaceholderText:ANSWER_HINT_TEXT];
	self.answerToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
	self.answerToolBar.delegate = self;
	self.answerToolBar.maxTextInputViewHeight = 100;
	[self.view addSubview:self.answerToolBar];
	self.answerToolBar.hidden = YES;
}

- (void)initLoadingViews {
	_loadingStatus = [[ListingLoadingStatusView alloc] initWithFrame:self.view.frame];
	__weak typeof(self) weakSelf = self;
	_loadingStatus.refresh = ^() {
		[weakSelf requestAnswerReplyList];
	};
	[self.view addSubview:_loadingStatus];
	[_loadingStatus showWithStatus:Loading];
}

// 提交回复
- (void)commitReply {
	if (IsStringNotEmpty(replyContent)) {
		[self showWithLabelText:@"" executing:@selector(commitUserReply)];
	}
}

#pragma mark - Networking

- (void)requestAnswerReplyList {
	NSString *sourceID = [NSString stringWithFormat:@"%d", self.answerContent.cmi_id];
	NSString *pageString = [NSString stringWithFormat:@"%ld", page];
	NSString *random = [NSString stringWithFormat:@"%d", [BaseFunction random:1000]];
	
	NSDictionary *parameters = @{@"cmi_source_id" : sourceID,
								 @"cmi_source_type" : @"2",
								 @"cmi_recursive_type" : @"1",
								 @"page" : pageString,
								 @"rows" : DEFAULT_REQUEST_DATA_ROWS,
								 @"random" : random};
	NSLog(@"request Answer Reply List parameters = %@", parameters);
	
	[HttpManager requestCommentsByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"code"] integerValue] == 0) {
			if (page == 1) {
				[dataSource removeAllObjects];
			}
			
//			[Comment setupObjectClassInArray:^NSDictionary *{
//				return @{ @"comments" : @"Comment" };
//			}];
			
			NSArray *tempArray = [Comment objectArrayWithKeyValuesArray:responseObject[@"result"][@"rows"]];
			[dataSource addObjectsFromArray:tempArray];
			
			if (!self.tableView) {
				[self initViews];
			}
			
			if (tempArray.count >= DEFAULT_REQUEST_DATA_ROWS_INT) {
				self.tableView.footer.hidden = NO;
			} else {
				self.tableView.footer.hidden = YES;
			}
			
			// 如果列表有数据
			if (dataSource.count > 0) {
				[_loadingStatus showWithStatus:Done];
			} else {// 如果列表没有数据
				if (!_loadingStatus.superview) {
					[self.view addSubview:_loadingStatus];
				}
				[_loadingStatus showWithStatus:Empty];
                [_loadingStatus setEmptyImage:@"icon_no_answer" emptyContent:@"No answers" imageSize:NO_ANSWER];
				self.tableView.footer.hidden = YES;
			}
			
			if (self.tableView.footer.isRefreshing) {
				[self.tableView.footer endRefreshing];
			}
			if (self.tableView.header.isRefreshing) {
				[self.tableView.header endRefreshing];
			}
			
			self.answerToolBar.hidden = NO;
			self.tableView.hidden = NO;
			[self.tableView reloadData];
		} else {
			[self processServerErrorWithCode:[responseObject[@"code"] integerValue] andErrorMsg:[responseObject objectForKey:@"message"]];
			[_loadingStatus showWithStatus:NetErr];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
		[_loadingStatus showWithStatus:NetErr];
	}];
}

- (void)refreshAnswer {
	page = 1;
	[self requestAnswerReplyList];
}

- (void)loadMoreAnswerReply {
	page++;
	[self requestAnswerReplyList];
}

- (void)commitUserReply {
	NSString *currentUserID = [NSString stringWithFormat:@"%@", [AppConfigure objectForKey:LOGINED_USER_ID]];
	NSString *replyAnswerSourceID = [NSString stringWithFormat:@"%d", self.answerContent.cmi_id];
	NSString *replyAnswerUserID = [NSString stringWithFormat:@"%d", self.answerContent.cmi_ci_id];

	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:replyContent forKey:@"cmi_info"];
	[parameters setObject:currentUserID forKey:@"cmi_ci_id"];
	[parameters setObject:replyAnswerSourceID forKey:@"cmi_source_id"];
	[parameters setObject:replyAnswerUserID forKey:@"cmi_source_ci_id"];
	[parameters setObject:@"2" forKey:@"cmi_source_type"];
	[parameters setObject:self.questionID forKey:@"cmi_final_source_id"];
	[parameters setObject:@"4" forKey:@"cmi_final_source_type"];
	NSString *finalSourceCiId = [NSString stringWithFormat:@"%ld", self.questionUserID];
	[parameters setObject:finalSourceCiId forKey:@"cmi_final_source_ci_id"];// // 评论最终源用户 ID
    
    [parameters setObject:replyAnswerSourceID forKey:@"cmi_two_source_id"];
    [parameters setObject:@"2" forKey:@"cmi_two_source_type"];
	
	[HttpManager commitUserCommentByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"code"] integerValue] == 0) {
			Comment *myReply = [Comment objectWithKeyValues:responseObject[@"result"]];
			myReply.ci_nikename = [AppConfigure objectForKey:LOGINED_USER_NICKNAME];
			myReply.ci_header_img = [AppConfigure objectForKey:LOGINED_USER_ICON_URL];
			myReply.ci_sex = [[AppConfigure objectForKey:LOGINED_USER_SEX] intValue];
			myReply.cmi_source_nikename = self.answerContent.ci_nikename;
			[dataSource addObject:myReply];
			[self.tableView reloadData];
			[self keyBoardHidden];
		} else {
			[self processServerErrorWithCode:[responseObject[@"code"] integerValue] andErrorMsg:[responseObject objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"error = %@", error);
		[self showHUDErrorWithText:BAD_NETWORK];
	}];
}

- (void)deleteUserReply {
	Comment *reply = [dataSource objectAtIndex:deleteReplyIndexPath.row - 1];
	
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:self.questionID forKey:@"cmi_final_source_id"];
	[parameters setObject:@"4" forKey:@"cmi_final_source_type"];
	[parameters setObject:[NSString stringWithFormat:@"%d", reply.cmi_id] forKey:@"cmi_id"];
	[parameters setObject:[NSString stringWithFormat:@"%d", reply.cmi_ci_id] forKey:@"cmi_ci_id"];
	[parameters setObject:@"2" forKey:@"cmi_source_type"];
	
	[HttpManager deleteUserCommentByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [resultDict[@"code"] integerValue];
		if (rtnCode == 0) {
			[dataSource removeObjectAtIndex:deleteReplyIndexPath.row - 1];
			[self.tableView deleteRowsAtIndexPaths:@[deleteReplyIndexPath] withRowAnimation:UITableViewRowAnimationNone];
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"error = %@", error);
		[self showHUDErrorWithText:BAD_NETWORK];
	}];
}

#pragma mark 删除回答
- (void)deleteUserAnswer {
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[NSString stringWithFormat:@"%d", self.answerContent.cmi_id] forKey:@"cmi_id"];
	[parameters setObject:[NSString stringWithFormat:@"%d", self.answerContent.cmi_ci_id] forKey:@"cmi_ci_id"];
	[parameters setObject:[NSString stringWithFormat:@"%d", self.answerContent.cmi_source_type] forKey:@"cmi_source_type"];
	[parameters setObject:self.questionID forKey:@"cmi_final_source_id"];
	[parameters setObject:@"4" forKey:@"cmi_final_source_type"];
	
	[HttpManager deleteUserCommentByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [resultDict[@"code"] integerValue];
		if (rtnCode == 0) {
			[self hideHud];
			if (self.deletedAnswer) {
				self.deletedAnswer();
			}
			[self.navigationController popViewControllerAnimated:YES];
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"error = %@", error);
		[self showHUDErrorWithText:BAD_NETWORK];
	}];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1 + dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		AskAnswerCell *cell = (AskAnswerCell *)[tableView dequeueReusableCellWithIdentifier:AnswerContentCellID];
		[cell configureCellWithAnswer:self.answerContent questionUserID:[NSString stringWithFormat:@"%ld", self.questionUserID] forRowAtIndexPath:indexPath];
		cell.delegate = self;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	} else {
		AnswerReplyCell *cell = (AnswerReplyCell *)[tableView dequeueReusableCellWithIdentifier:AnswerReplyCellID forIndexPath:indexPath];
		[cell configureCellWithReply:dataSource[indexPath.row - 1] forRowAtIndexPath:indexPath];
		cell.delegate = self;
		return cell;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		return [tableView fd_heightForCellWithIdentifier:AnswerContentCellID configuration:^(AskAnswerCell *cell) {
			[cell configureCellWithAnswer:self.answerContent questionUserID:[NSString stringWithFormat:@"%ld", self.questionUserID] forRowAtIndexPath:indexPath];
		}];
	} else {
		return [tableView fd_heightForCellWithIdentifier:AnswerReplyCellID configuration:^(AnswerReplyCell *cell) {
			[cell configureCellWithReply:dataSource[indexPath.row - 1] forRowAtIndexPath:indexPath];
		}];
	}
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - AskAnswerCellDelegate

- (void)showAnswerOperationsWithCurrentCellIndexPath:(NSIndexPath *)indexPath {
	UIActionSheet *sheet;
	
	NSInteger loginUserID = [[NSString stringWithFormat:@"%@", [AppConfigure objectForKey:LOGINED_USER_ID]] integerValue];
	if (loginUserID == self.answerContent.cmi_ci_id) {// 如果当前用户是该问题的题主// ，并且没有设置过最佳答案，那么显示的菜单里有 Best Answer 选项
		if (self.answerContent.cmi_ci_id == loginUserID && !self.isBestAnswer) {// 是自己的评论
			sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reply", @"Best Answer", @"Delete", @"Report", nil];
		} else {
			sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reply", @"Best Answer", @"Report", nil];
		}
	} else {// 如果当前用户不是题主// 或者该问题已经设置过最佳答案，那么显示的菜单里就只有 Reply 和 Report
		if (self.answerContent.cmi_ci_id == loginUserID && !self.isBestAnswer) {// 是自己的评论
			sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reply", @"Delete", @"Report", nil];
		} else {
			sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reply", @"Report", nil];
		}
	}
	
	[sheet showInView:self.view];
}

- (void)clickedDelete {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Delete Answer?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
	alert.tag = TagDeleteAnswerAlert;
	[alert show];
}

#pragma mark - AnswerReplyCellDelegate

- (void)deleteReplyAtIndexPath:(NSIndexPath *)indexPath {
//	Comment *reply = dataSource[indexPath.row - 1];
//	NSLog(@"delete reply info = %@", reply.cmi_info);
	// 保存当前要删除的回答的 Cell 的位置
	deleteReplyIndexPath = indexPath;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Delete Reply?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
	alert.tag = TagDeleteReplyAlert;
	[alert show];
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
	replyContent = text;
	[self commitReply];
}

- (void)scrollViewToBottom:(BOOL)animated {
	if (self.tableView.contentSize.height > self.tableView.frame.size.height) {
		CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
		[self.tableView setContentOffset:offset animated:animated];
	}
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {// Delete
		if (alertView.tag == TagDeleteReplyAlert) {
			[self showWithLabelText:@"" executing:@selector(deleteUserReply)];
		} else if (alertView.tag == TagDeleteAnswerAlert) {
			[self showHUDWithText:@""];
			[self deleteUserAnswer];
		}
	}
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	NSString *actionTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	if ([actionTitle isEqualToString:@"Reply"]) {
		[self.answerToolBar.inputTextView becomeFirstResponder];
	} else if ([actionTitle isEqualToString:@"Best Answer"]) {
		[self showWithLabelText:@"" executing:@selector(setBestAnswer)];
	} else if ([actionTitle isEqualToString:@"Report"]) {
        ReportViewController *reportController = [[ReportViewController alloc] initWithNibName:@"ReportViewController" bundle:nil];
        reportController.commentId = self.answerContent.cmi_id;
        [self.navigationController pushViewController:reportController animated:YES];
	} else if ([actionTitle isEqualToString:@"Delete"]) {
		[self clickedDelete];
	}
}

#pragma mark - Touch Events

// 设置最佳答案
- (void)setBestAnswer {
	NSString *answerID = [NSString stringWithFormat:@"%d", self.answerContent.cmi_id];
	NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[self.questionID, answerID] forKeys:@[@"aki_id", @"aki_best"]];
	[HttpManager setAskBestAnswerByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"code"] integerValue] == 0) {
			[self showHUDDoneWithText:@"Done"];
		} else {
			[self processServerErrorWithCode:[responseObject[@"code"] integerValue] andErrorMsg:[responseObject objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"error = %@", error);
		[self showHUDNetError];
	}];
}

- (void)keyBoardHidden {
	[self.answerToolBar endEditing:YES];
}

@end
