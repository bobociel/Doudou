//
//  AskDetailViewController.m
//  nihao
//
//  Created by HelloWorld on 7/15/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "AskDetailViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "AskContentCell.h"
#import "AskAnswerCell.h"
#import "BestAnswerCell.h"
#import "AnswerSectionCell.h"
#import "HttpManager.h"
#import "BaseFunction.h"
#import "AppConfigure.h"
#import "AskContent.h"
#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>
#import "ListingLoadingStatusView.h"
#import "CommentToolbar.h"
#import "MoreReplyCell.h"
#import "AnswerReplyCell.h"
#import "AnswerDetailViewController.h"
#import "UserInfoViewController.h"
#import "ReportViewController.h"

#define TagDeleteAnswerAlert 10
#define TagDeleteReplyAlert 11
#define TagDeleteAskAlert 12

@interface AskDetailViewController () <UITableViewDelegate, UITableViewDataSource, AskAnswerCellDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UITextViewDelegate, CommentToolbarDelegate, MoreReplyCellDelegate, AnswerReplyCellDelegate> {
	ListingLoadingStatusView *_loadingStatus;
}

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) CommentToolbar *answerToolBar;

@property (nonatomic, assign) BOOL cellHeightCacheEnabled;

@end

static NSString *AskContentCellIdentifier = @"AskContentCell";
static NSString *AskAnswerCellIdentifier = @"AskAnswerCell";
static NSString *AskBestAnswerCellIdentifier = @"BestAnswerCell";
static NSString *AskAnswerSectionCellIdentifier = @"AnswerSectionCell";
static NSString *AskAnswerMoreReplyCellIdentifier = @"MoreReplyCell";
static NSString *AskAnswerReplyCellIdentifier = @"AnswerReplyCell";

static const NSInteger AnswerSectionCellHeight = 45;
static const NSInteger AnswerMoreReplyCellHeight = 34;

@implementation AskDetailViewController {
	CGFloat viewHeight;
	CGSize lastChangeContentSize;
	BOOL hasBestAnswer;
	AskContent *currentAskContent;
	Comment *bestAnswer;
	NSInteger page;
	NSMutableArray *answerList;
//	NSIndexPath *deleteAnswerIndexPath;
	NSIndexPath *operateAnswerIndexPath;
	BOOL isReply;
	NSString *answerContent;
	NSString *replyAnswerSourceID;
    NSString *replyTwoAnswerSourceID;
	// 被回复的答案的用户的 id
	NSString *replyAnswerUserID;
	NSIndexPath *deleteReplyIndexPath;
	BOOL isDeleteReply;
	NSIndexPath *showMoreReplyIndexPath;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	[self dontShowBackButtonTitle];
	
	self.cellHeightCacheEnabled = YES;
	hasBestAnswer = NO;
	page = 1;
	answerList = [[NSMutableArray alloc] init];
	showMoreReplyIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	operateAnswerIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	isReply = NO;
	isDeleteReply = NO;
	
	if (IsStringNotEmpty(self.questionID)) {
		[self initLoadingViews];
		[self requestQuestionInfo];
	}
}

#pragma mark - Lifecycle
- (void)dealloc {
	_tableView.delegate = nil;
	_tableView.dataSource = nil;
	_tableView = nil;
	
	self.answerToolBar.delegate = nil;
	self.answerToolBar = nil;
}

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
	[self.tableView registerNib:[UINib nibWithNibName:AskContentCellIdentifier bundle:nil] forCellReuseIdentifier:AskContentCellIdentifier];
	[self.tableView registerNib:[UINib nibWithNibName:AskAnswerCellIdentifier bundle:nil] forCellReuseIdentifier:AskAnswerCellIdentifier];
	[self.tableView registerNib:[UINib nibWithNibName:AskBestAnswerCellIdentifier bundle:nil] forCellReuseIdentifier:AskBestAnswerCellIdentifier];
	[self.tableView registerNib:[UINib nibWithNibName:AskAnswerSectionCellIdentifier bundle:nil] forCellReuseIdentifier:AskAnswerSectionCellIdentifier];
	[self.tableView registerNib:[UINib nibWithNibName:AskAnswerMoreReplyCellIdentifier bundle:nil] forCellReuseIdentifier:AskAnswerMoreReplyCellIdentifier];
	[self.tableView registerNib:[UINib nibWithNibName:AskAnswerReplyCellIdentifier bundle:nil] forCellReuseIdentifier:AskAnswerReplyCellIdentifier];
	
	self.tableView.tableFooterView = [[UIView alloc] init];
	self.tableView.backgroundColor = RootBackgroundWhitelyColor;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[BaseFunction addRefreshHeaderAndFooter:self.tableView refreshAction:@selector(refreshAskAnswerList) loadMoreAction:@selector(loadMoreAskAnswerList) target:self];
	[self.view addSubview:self.tableView];
	self.tableView.footer.hidden = YES;
	self.tableView.hidden = YES;
	
	self.answerToolBar = [[CommentToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [CommentToolbar defaultHeight], self.view.frame.size.width, [CommentToolbar defaultHeight]) withPlaceholderText:ANSWER_HINT_TEXT];
	self.answerToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
	self.answerToolBar.delegate = self;
	self.answerToolBar.maxTextInputViewHeight = 100;
	[self.view addSubview:self.answerToolBar];
	self.answerToolBar.hidden = YES;
	
//	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden)];
//	[self.view addGestureRecognizer:tap];
}

- (void)initLoadingViews {
	_loadingStatus = [[ListingLoadingStatusView alloc] initWithFrame:self.view.frame];
	__weak AskDetailViewController *weakSelf = self;
	_loadingStatus.refresh = ^() {
		__strong AskDetailViewController *strongSelf = weakSelf;
		[strongSelf requestQuestionInfo];
	};
	[self.view addSubview:_loadingStatus];
	[_loadingStatus showWithStatus:Loading];
}

#pragma mark - Network
#pragma mark 获取 Question 详情
- (void)requestQuestionInfo {
	NSString *userID = [AppConfigure objectForKey:LOGINED_USER_ID];
	NSString *random = [NSString stringWithFormat:@"%d", [BaseFunction random:1000]];
	NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[userID, self.questionID, random] forKeys:@[@"ci_id", @"aki_id", @"random"]];
	[HttpManager requestAskDetailByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"code"] integerValue] == 0) {
			currentAskContent = [AskContent objectWithKeyValues:responseObject[@"result"]];
			
			NSArray *bestAnswerList = currentAskContent.bestComment[@"rows"];
			if (bestAnswerList.count > 0) {
				[Comment setupObjectClassInArray:^NSDictionary *{
					return @{ @"comments" : @"Comment" };
				}];
				bestAnswer = [Comment objectWithKeyValues:bestAnswerList[0]];
				[self processAnswer:bestAnswer];
				hasBestAnswer = YES;
			} else {
				hasBestAnswer = NO;
			}
			
			if (!self.tableView) {
				[self initViews];
			}
			[self requestQuestionAnswerList];
		} else {
			[self processServerErrorWithCode:[responseObject[@"code"] integerValue] andErrorMsg:[responseObject objectForKey:@"message"]];
			[_loadingStatus showWithStatus:NetErr];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
		[_loadingStatus showWithStatus:NetErr];
	}];
}

#pragma mark 获取 Question 回答列表
- (void)requestQuestionAnswerList {
	NSString *pageString = [NSString stringWithFormat:@"%ld", page];
	NSString *random = [NSString stringWithFormat:@"%d", [BaseFunction random:1000]];
	NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[self.questionID, @"4", @"2", pageString, DEFAULT_REQUEST_DATA_ROWS, random]
														   forKeys:@[@"cmi_source_id", @"cmi_source_type", @"cmi_recursive_type", @"page", @"rows", @"random"]];
	NSLog(@"requestQuestionAnswerList parameters = %@", parameters);
	[HttpManager requestCommentsByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"code"] integerValue] == 0) {
			if (page == 1) {
				[answerList removeAllObjects];
			}
			
			[Comment setupObjectClassInArray:^NSDictionary *{
				return @{ @"comments" : @"Comment" };
			}];
			
			NSArray *tempArray = [Comment objectArrayWithKeyValuesArray:responseObject[@"result"][@"rows"]];
			[answerList addObjectsFromArray:tempArray];
			[self processAnswerList];
			
			if (tempArray.count >= DEFAULT_REQUEST_DATA_ROWS_INT) {
				self.tableView.footer.hidden = NO;
			} else {
				self.tableView.footer.hidden = YES;
			}
			
			// 如果列表有数据
			if (answerList.count > 0) {
				[_loadingStatus showWithStatus:Done];
			} else {// 如果列表没有数据
				if (!_loadingStatus.superview) {
					[self.view addSubview:_loadingStatus];
				}
				//[_loadingStatus showWithStatus:Empty];
                //[_loadingStatus setEmptyImage:@"icon_no_answer" emptyContent:@"No answers"];
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

- (void)processAnswerList {
	for (Comment *answer in answerList) {
		[self processAnswer:answer];
	}
}

- (void)processAnswer:(Comment *)answer {
	if (!answer.showComments) {
		answer.showComments = [[NSMutableArray alloc] init];
	}
	
	if (answer.comments.count == 1) {
		[answer.showComments addObject:answer.comments[0]];
	} else if (answer.comments.count >= 2) {
		[answer.showComments addObjectsFromArray:@[answer.comments[0], answer.comments[1]]];
	}
    
    [answer.showComments sortUsingComparator:^NSComparisonResult(Comment *obj1, Comment *obj2) {
        NSString *dateString1 = obj1.cmi_date;
        NSString *dateString2 = obj2.cmi_date;
        NSDate *date1 = [BaseFunction longDateFromString:dateString1];
        NSDate *date2 = [BaseFunction longDateFromString:dateString2];
        return date2.timeIntervalSinceReferenceDate - date1.timeIntervalSinceReferenceDate;
    }];
}

#pragma mark 刷新
- (void)refreshAskAnswerList {
	page = 1;
	[self requestQuestionInfo];
}

#pragma mark 加载更多回答
- (void)loadMoreAskAnswerList {
	page++;
	[self requestQuestionAnswerList];
}

#pragma mark 提交回答
- (void)commitUserAnswer {
	NSString *currentUserID = [NSString stringWithFormat:@"%@", [AppConfigure objectForKey:LOGINED_USER_ID]];
//	answerContent = [BaseFunction encodeToPercentEscapeString:answerContent];
	
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:answerContent forKey:@"cmi_info"];// 评论内容
	[parameters setObject:currentUserID forKey:@"cmi_ci_id"];// 评论人 ID
	[parameters setObject:self.questionID forKey:@"cmi_final_source_id"];// 评论最终源 ID
	[parameters setObject:@"4" forKey:@"cmi_final_source_type"];// 评论最终源属性
	NSString *finalSourceCiId = [NSString stringWithFormat:@"%ld", self.askContent.aki_source_id];
	[parameters setObject:finalSourceCiId forKey:@"cmi_final_source_ci_id"];// // 评论最终源用户 ID
	
	if (isReply) {
		[parameters setObject:replyAnswerSourceID forKey:@"cmi_source_id"];// 评论源 ID
		[parameters setObject:replyAnswerUserID forKey:@"cmi_source_ci_id"];// 评论源用户 ID
		[parameters setObject:@"2" forKey:@"cmi_source_type"];// 评论源属性
        [parameters setObject:@"2" forKey:@"cmi_two_source_type"];
        [parameters setObject:replyTwoAnswerSourceID forKey:@"cmi_two_source_id"];
	} else {
		[parameters setObject:self.questionID forKey:@"cmi_source_id"];
		[parameters setObject:@"4" forKey:@"cmi_source_type"];
		[parameters setObject:finalSourceCiId forKey:@"cmi_source_ci_id"];// 评论源用户 ID
	}
	
	NSLog(@"commitUserAnswer parameters = %@", parameters);
	
	[HttpManager commitUserCommentByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"code"] integerValue] == 0) {
			Comment *myAnswer = [Comment objectWithKeyValues:responseObject[@"result"]];
			myAnswer.ci_nikename = [AppConfigure objectForKey:LOGINED_USER_NICKNAME];
			myAnswer.ci_header_img = [AppConfigure objectForKey:LOGINED_USER_ICON_URL];
			myAnswer.ci_sex = [[AppConfigure objectForKey:LOGINED_USER_SEX] intValue];
			if (isReply) {
				NSInteger index = [self indexOfAnswerAtIndexPath:operateAnswerIndexPath];
				Comment *answer = answerList[index];
				myAnswer.cmi_source_nikename = answer.ci_nikename;
				if (!answer.comments) {
					answer.comments = [[NSMutableArray alloc] init];
				}
				[answer.comments addObject:myAnswer];
				if (answer.showComments.count < 2 || (answer.showComments.count > 2 && answer.showComments.count < 10)) {
					if (!answer.showComments) {
						answer.showComments = [[NSMutableArray alloc] init];
					}
					[answer.showComments addObject:myAnswer];
				}
				[self.tableView reloadData];
			} else {
                if(answerList.count == 0) {
                    [_loadingStatus showWithStatus:Done];
                }
				[answerList addObject:myAnswer];
				[self.tableView reloadData];
				self.askContent.aki_sum_cmi_count++;
			}
			
			[self keyBoardHidden];
		} else {
			[self processServerErrorWithCode:[responseObject[@"code"] integerValue] andErrorMsg:[responseObject objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"error = %@", error);
		[self showHUDErrorWithText:BAD_NETWORK];
	}];
}

#pragma mark 删除回答
- (void)deleteUserAnswer {
	Comment *comment;
	
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	
	if (isDeleteReply) {
		NSInteger index = [self indexOfAnswerAtIndexPath:deleteReplyIndexPath];
		Comment *answer = answerList[index];
		comment = answer.showComments[deleteReplyIndexPath.row - 1];
	} else {
		comment = [answerList objectAtIndex:[self indexOfOperatorAnswerIndexPath]];
	}
	
	[parameters setObject:[NSString stringWithFormat:@"%d", comment.cmi_id] forKey:@"cmi_id"];
	[parameters setObject:[NSString stringWithFormat:@"%d", comment.cmi_ci_id] forKey:@"cmi_ci_id"];
	[parameters setObject:[NSString stringWithFormat:@"%d", comment.cmi_source_type] forKey:@"cmi_source_type"];
	[parameters setObject:self.questionID forKey:@"cmi_final_source_id"];
	[parameters setObject:@"4" forKey:@"cmi_final_source_type"];
	
	[HttpManager deleteUserCommentByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [resultDict[@"code"] integerValue];
		if (rtnCode == 0) {
//			if (isDeleteReply) {
//				NSInteger index = [self indexOfAnswerAtIndexPath:deleteReplyIndexPath];
//				Comment *answer = answerList[index];
//				[answer.comments removeObjectAtIndex:deleteReplyIndexPath.row - 1];
//				[answer.showComments removeObjectAtIndex:deleteReplyIndexPath.row - 1];
//				if (answer.comments.count > 1) {
//					[answer.showComments addObject:answer.comments[1]];
//				}
//				[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:deleteReplyIndexPath.section] withRowAnimation:UITableViewRowAnimationNone];
//			} else {
//				[self deletedAnswerAtIndexPath:operateAnswerIndexPath];
////				[answerList removeObjectAtIndex:[self indexOfOperatorAnswerIndexPath]];
////				[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:operateAnswerIndexPath.section] withRowAnimation:UITableViewRowAnimationNone];
////				self.askContent.aki_sum_cmi_count--;
//			}
			[self requestQuestionInfo];
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"error = %@", error);
		[self showHUDErrorWithText:BAD_NETWORK];
	}];
}

#pragma mark 删除Ask
- (void)deleteThisAsk {
	NSString *askID = [NSString stringWithFormat:@"%ld", self.askContent.aki_id];
	NSString *userID = [NSString stringWithFormat:@"%ld", [AppConfigure integerForKey:LOGINED_USER_ID]];
	NSDictionary *parameters = @{@"aki_id" : askID, @"ci_id" : userID};
	
	[HttpManager deleteAskByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [resultDict[@"code"] integerValue];
		if (rtnCode == 0) {
			[self hideHud];
			if (self.deletedAsk) {
				self.deletedAsk();
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
	answerContent = text;
	[self commitAnswer];
}

- (void)scrollViewToBottom:(BOOL)animated {
	if (self.tableView.contentSize.height > self.tableView.frame.size.height) {
		CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
		[self.tableView setContentOffset:offset animated:animated];
	}
}

#pragma mark - Private

- (NSInteger)needMoreRowForComment:(Comment *)answer {
	NSInteger moreRow = 0;
	
// 2015-08-14 start -------------
//	if (answer.comments.count > 2) {// 大于2条评论，就有可能要显示更多
//		if (answer.showComments.count > 2) {// 大于2说明当前点击过查看更多
//			if (answer.comments.count > 10) {// 如果评论列表大于10条，则显示查看更多，否则说明没有更多的评论可以查看
//				moreRow = 1;
//			}
//		} else {// 这里只会是等于2，说明没有点击过查看更多，但是有更多
//			moreRow = 1;
//		}
//	}
// 2015-08-14 end -------------
	
// modify start ------
	moreRow = answer.comments.count > 2 ? 1 : 0;
// modify end ------
	
	return moreRow;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
	NSInteger index = hasBestAnswer ? section - 3 : section - 2;
	Comment *answer = answerList[index];
	NSInteger moreRow = [self needMoreRowForComment:answer];
	return 1 + answer.showComments.count + moreRow;
}

- (NSInteger)indexOfOperatorAnswerIndexPath {
	return [self indexOfAnswerAtIndexPath:operateAnswerIndexPath];
}

- (Comment *)answerOfOperatorAnswerIndexPath {
	Comment *answer;
	
	if (hasBestAnswer && operateAnswerIndexPath.section == 1) {
		answer = bestAnswer;
	} else {
		answer = [answerList objectAtIndex:[self indexOfOperatorAnswerIndexPath]];
	}
	
	return answer;
}

- (NSInteger)indexOfAnswerAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger index = 0;
	if (hasBestAnswer) {
        if(indexPath.section == 1) {
            for(Comment *comment in answerList) {
                if(comment.cmi_id == bestAnswer.cmi_id) {
                    index = [answerList indexOfObject:comment];
                    break;
                }
            }
        } else {
            index = indexPath.section - 3;
        }
	} else {
		index = indexPath.section - 2;
	}
	
	return index;
}

- (void)deletedAnswerAtIndexPath:(NSIndexPath *)indexPath {
	[answerList removeObjectAtIndex:[self indexOfAnswerAtIndexPath:indexPath]];
	self.askContent.aki_sum_cmi_count--;
	[self.tableView reloadData];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (hasBestAnswer) {
		return 3 + answerList.count;
	} else {
		return 2 + answerList.count;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:// 问题详情
			return 1;
		case 1: {
			if (hasBestAnswer) {// 最佳答案
				NSInteger moreRow = [self needMoreRowForComment:bestAnswer];
				return 1 + bestAnswer.showComments.count + moreRow;
			} else {// Answer Count
				return 1;
			}
		}
		case 2: {
			if (hasBestAnswer) {// Other Answer Count
				return 1;
			} else {// Answer
				return [self numberOfRowsInSection:section];
			}
		}
		default: {// Answer
			return [self numberOfRowsInSection:section];
		}
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	__weak typeof(self) weakSelf = self;
	
	switch (indexPath.section) {
		case 0: {
			AskContentCell *cell = (AskContentCell *)[tableView dequeueReusableCellWithIdentifier:AskContentCellIdentifier];
			[cell configureCellWithContent:currentAskContent];
			cell.clickAskContentUserIcon = ^() {
				[weakSelf clickAskContentUserIcon];
			};
			cell.deleteClicked = ^() {
				[weakSelf clickDeleteBtn];
			};
			return cell;
		}
		case 1: {
			// 如果有最佳答案
			if (hasBestAnswer) {
				if (indexPath.row == 0) {
					BestAnswerCell *cell = (BestAnswerCell *)[tableView dequeueReusableCellWithIdentifier:AskBestAnswerCellIdentifier];
					[cell configureCellWithBestAnswer:bestAnswer];
					cell.clickBestAnswerUserIcon = ^() {
						[weakSelf clickBestAnswerUserIcon];
					};
					return cell;
				} else {
					if (indexPath.row <= bestAnswer.showComments.count) {
						AnswerReplyCell *cell = (AnswerReplyCell *)[tableView dequeueReusableCellWithIdentifier:AskAnswerReplyCellIdentifier forIndexPath:indexPath];
						[cell configureCellWithReply:bestAnswer.showComments[indexPath.row - 1] forRowAtIndexPath:indexPath];
						cell.delegate = self;
						return cell;
					} else {// 查看更多
						MoreReplyCell *cell = (MoreReplyCell *)[tableView dequeueReusableCellWithIdentifier:AskAnswerMoreReplyCellIdentifier forIndexPath:indexPath];
						[cell configureCellWithAnswer:bestAnswer forRowAtIndexPath:indexPath];
						cell.delegate = self;
						return cell;
					}
				}
			} else {// 没有最佳答案
				AnswerSectionCell *cell = (AnswerSectionCell *)[tableView dequeueReusableCellWithIdentifier:AskAnswerSectionCellIdentifier];
				[cell configureCellWithText:[NSString stringWithFormat:@"Answer (%ld)", answerList.count]];
				return cell;
			}
		}
		case 2: {
			// 如果有最佳答案
			if (hasBestAnswer) {
				AnswerSectionCell *cell = (AnswerSectionCell *)[tableView dequeueReusableCellWithIdentifier:AskAnswerSectionCellIdentifier];
				[cell configureCellWithText:[NSString stringWithFormat:@"Other Answer (%ld)", answerList.count]];
				return cell;
			} else {
				if (indexPath.row == 0) {
					AskAnswerCell *cell = (AskAnswerCell *)[tableView dequeueReusableCellWithIdentifier:AskAnswerCellIdentifier];
					[cell configureCellWithAnswer:answerList[indexPath.section - 2] questionUserID:[NSString stringWithFormat:@"%ld", currentAskContent.aki_source_id] forRowAtIndexPath:indexPath];
					cell.delegate = self;
					return cell;
				} else {
					Comment *answer = answerList[indexPath.section - 2];
					if (indexPath.row <= answer.showComments.count) {
						AnswerReplyCell *cell = (AnswerReplyCell *)[tableView dequeueReusableCellWithIdentifier:AskAnswerReplyCellIdentifier forIndexPath:indexPath];
						[cell configureCellWithReply:answer.showComments[indexPath.row - 1] forRowAtIndexPath:indexPath];
						cell.delegate = self;
						return cell;
					} else {// 查看更多
						MoreReplyCell *cell = (MoreReplyCell *)[tableView dequeueReusableCellWithIdentifier:AskAnswerMoreReplyCellIdentifier forIndexPath:indexPath];
						[cell configureCellWithAnswer:answer forRowAtIndexPath:indexPath];
						cell.delegate = self;
						return cell;
					}
				}
			}
		}
		default : {// Answer
			NSInteger index = [self indexOfAnswerAtIndexPath:indexPath];
			Comment *answer = answerList[index];
			if (indexPath.row == 0) {
				AskAnswerCell *cell = (AskAnswerCell *)[tableView dequeueReusableCellWithIdentifier:AskAnswerCellIdentifier];
				[cell configureCellWithAnswer:answer questionUserID:[NSString stringWithFormat:@"%ld", currentAskContent.aki_source_id] forRowAtIndexPath:indexPath];
				cell.delegate = self;
				return cell;
			} else {
				if (indexPath.row <= answer.showComments.count) {
					AnswerReplyCell *cell = (AnswerReplyCell *)[tableView dequeueReusableCellWithIdentifier:AskAnswerReplyCellIdentifier forIndexPath:indexPath];
					[cell configureCellWithReply:answer.showComments[indexPath.row - 1] forRowAtIndexPath:indexPath];
					cell.delegate = self;
					return cell;
				} else {// 查看更多
					MoreReplyCell *cell = (MoreReplyCell *)[tableView dequeueReusableCellWithIdentifier:AskAnswerMoreReplyCellIdentifier forIndexPath:indexPath];
					[cell configureCellWithAnswer:answer forRowAtIndexPath:indexPath];
					cell.delegate = self;
					return cell;
				}
			}
		}
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.cellHeightCacheEnabled) {
		switch (indexPath.section) {
			case 0: {
				return [tableView fd_heightForCellWithIdentifier:AskContentCellIdentifier cacheByIndexPath:indexPath configuration:^(AskContentCell *cell) {
					[cell configureCellWithContent:currentAskContent];
				}];
			}
			case 1: {
				// 如果有最佳答案
				if (hasBestAnswer) {
					if (indexPath.row == 0) {
						return [tableView fd_heightForCellWithIdentifier:AskBestAnswerCellIdentifier cacheByIndexPath:indexPath configuration:^(BestAnswerCell *cell) {
							[cell configureCellWithBestAnswer:bestAnswer];
						}];
					} else {
						if (indexPath.row <= bestAnswer.showComments.count) {
							return [tableView fd_heightForCellWithIdentifier:AskAnswerReplyCellIdentifier cacheByIndexPath:indexPath configuration:^(AnswerReplyCell *cell) {
								[cell configureCellWithReply:bestAnswer.showComments[indexPath.row - 1] forRowAtIndexPath:indexPath];
//								cell.delegate = self;
							}];
						} else {// 查看更多
							return AnswerMoreReplyCellHeight;
						}
					}
				} else {// 没有最佳答案
					return AnswerSectionCellHeight;
				}
			}
			case 2: {
				// 如果有最佳答案
				if (hasBestAnswer) {
					return AnswerSectionCellHeight;
				} else {
					if (indexPath.row == 0) {
						return [tableView fd_heightForCellWithIdentifier:AskAnswerCellIdentifier cacheByIndexPath:indexPath configuration:^(AskAnswerCell *cell) {
							[cell configureCellWithAnswer:answerList[indexPath.section - 2] questionUserID:[NSString stringWithFormat:@"%ld", currentAskContent.aki_source_id] forRowAtIndexPath:indexPath];
						}];
					} else {
						Comment *answer = answerList[indexPath.section - 2];
						if (indexPath.row <= answer.showComments.count) {
							return [tableView fd_heightForCellWithIdentifier:AskAnswerReplyCellIdentifier cacheByIndexPath:indexPath configuration:^(AnswerReplyCell *cell) {
								[cell configureCellWithReply:answer.showComments[indexPath.row - 1] forRowAtIndexPath:indexPath];
//								cell.delegate = self;
							}];
						} else {// 查看更多
							return AnswerMoreReplyCellHeight;
						}
					}
				}
			}
			default : {// Answer
				NSInteger index = [self indexOfAnswerAtIndexPath:indexPath];
				Comment *answer = answerList[index];
				if (indexPath.row == 0) {
					return [tableView fd_heightForCellWithIdentifier:AskAnswerCellIdentifier cacheByIndexPath:indexPath configuration:^(AskAnswerCell *cell) {
						[cell configureCellWithAnswer:answer questionUserID:[NSString stringWithFormat:@"%ld", currentAskContent.aki_source_id] forRowAtIndexPath:indexPath];
					}];
				} else {
					if (indexPath.row <= answer.showComments.count) {
						return [tableView fd_heightForCellWithIdentifier:AskAnswerReplyCellIdentifier cacheByIndexPath:indexPath configuration:^(AnswerReplyCell *cell) {
							[cell configureCellWithReply:answer.showComments[indexPath.row - 1] forRowAtIndexPath:indexPath];
//							cell.delegate = self;
						}];
					} else {// 查看更多
						return AnswerMoreReplyCellHeight;
					}
				}
			}
		}
	} else {
		switch (indexPath.section) {
			case 0: {
				return [tableView fd_heightForCellWithIdentifier:AskContentCellIdentifier configuration:^(AskContentCell *cell) {
					[cell configureCellWithContent:currentAskContent];
				}];
			}
			case 1: {
				// 如果有最佳答案
				if (hasBestAnswer) {
					if (indexPath.row == 0) {
						return [tableView fd_heightForCellWithIdentifier:AskBestAnswerCellIdentifier configuration:^(BestAnswerCell *cell) {
							[cell configureCellWithBestAnswer:bestAnswer];
						}];
					} else {
						if (indexPath.row <= bestAnswer.showComments.count) {
							return [tableView fd_heightForCellWithIdentifier:AskAnswerReplyCellIdentifier configuration:^(AnswerReplyCell *cell) {
								[cell configureCellWithReply:bestAnswer.showComments[indexPath.row - 1] forRowAtIndexPath:indexPath];
//								cell.delegate = self;
							}];
						} else {// 查看更多
							return AnswerMoreReplyCellHeight;
						}
					}
				} else {// 没有最佳答案
					return AnswerSectionCellHeight;
				}
			}
			case 2: {
				// 如果有最佳答案
				if (hasBestAnswer) {
					return AnswerSectionCellHeight;
				} else {
					if (indexPath.row == 0) {
						return [tableView fd_heightForCellWithIdentifier:AskAnswerCellIdentifier configuration:^(AskAnswerCell *cell) {
							[cell configureCellWithAnswer:answerList[indexPath.section - 2] questionUserID:[NSString stringWithFormat:@"%ld", currentAskContent.aki_source_id] forRowAtIndexPath:indexPath];
						}];
					} else {
						Comment *answer = answerList[indexPath.section - 2];
						if (indexPath.row <= answer.showComments.count) {
							return [tableView fd_heightForCellWithIdentifier:AskAnswerReplyCellIdentifier configuration:^(AnswerReplyCell *cell) {
								[cell configureCellWithReply:answer.showComments[indexPath.row - 1] forRowAtIndexPath:indexPath];
//								cell.delegate = self;
							}];
						} else {// 查看更多
							return AnswerMoreReplyCellHeight;
						}
					}
				}
			}
			default : {// Answer
				NSInteger index = [self indexOfAnswerAtIndexPath:indexPath];
				Comment *answer = answerList[index];
				if (indexPath.row == 0) {
					return [tableView fd_heightForCellWithIdentifier:AskAnswerCellIdentifier configuration:^(AskAnswerCell *cell) {
						[cell configureCellWithAnswer:answer questionUserID:[NSString stringWithFormat:@"%ld", currentAskContent.aki_source_id] forRowAtIndexPath:indexPath];
					}];
				} else {
					if (indexPath.row <= answer.showComments.count) {
						return [tableView fd_heightForCellWithIdentifier:AskAnswerReplyCellIdentifier configuration:^(AnswerReplyCell *cell) {
							[cell configureCellWithReply:answer.showComments[indexPath.row - 1] forRowAtIndexPath:indexPath];
//							cell.delegate = self;
						}];
					} else {// 查看更多
						return AnswerMoreReplyCellHeight;
					}
				}
			}
		}
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self keyBoardHidden];
}

#pragma mark - AskAnswerCellDelegate
// 显示对回答操作的菜单
- (void)showAnswerOperationsWithCurrentCellIndexPath:(NSIndexPath *)indexPath {
	// 保存当前操作的 Cell 的位置
	operateAnswerIndexPath = indexPath;
	UIActionSheet *sheet;
	
	NSInteger loginUserID = [[NSString stringWithFormat:@"%@", [AppConfigure objectForKey:LOGINED_USER_ID]] integerValue];
//	if (loginUserID == askContent.aki_source_id && !hasBestAnswer) {// 如果当前用户是改问题的题主，并且没有设置过最佳答案，那么显示的菜单里有 Best Answer 选项
//		sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reply", @"Best Answer", @"Report", nil];
//	} else {// 如果当前用户不是题主或者该问题已经设置过最佳答案，那么显示的菜单里就只有 Reply 和 Report
//		sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reply", @"Report", nil];
//	}
	
	Comment *operatorAnswer = [answerList objectAtIndex:[self indexOfOperatorAnswerIndexPath]];
	
	if (loginUserID == currentAskContent.aki_source_id) {// 如果当前用户是该问题的题主// ，并且没有设置过最佳答案，那么显示的菜单里有 Best Answer 选项
		if (operatorAnswer.cmi_ci_id == loginUserID && operatorAnswer.cmi_id != bestAnswer.cmi_id) {// 是自己的评论
			sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reply", @"Best Answer", @"Delete", @"Report", nil];
		} else {
			sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reply", @"Best Answer", @"Report", nil];
		}
	} else {// 如果当前用户不是题主// 或者该问题已经设置过最佳答案，那么显示的菜单里就只有 Reply 和 Report
		if (operatorAnswer.cmi_ci_id == loginUserID && operatorAnswer.cmi_id != bestAnswer.cmi_id) {// 是自己的评论
			sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reply", @"Delete", @"Report", nil];
		} else {
			sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reply", @"Report", nil];
		}
	}
	
	[sheet showInView:self.view];
}

// 删除某条自己的回答
- (void)clickedDeleteBtnForRowAtIndexPath:(NSIndexPath *)indexPath {
	// 保存当前要删除的回答的 Cell 的位置
//	deleteAnswerIndexPath = indexPath;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Delete Answer?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
	alert.tag = TagDeleteAnswerAlert;
	[alert show];
}

- (void)clickedUserIconAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger index = [self indexOfAnswerAtIndexPath:indexPath];
	Comment *answer = answerList[index];
	[self openUserInfoVCWithAnswer:answer];
}

#pragma mark - MoreReplyCellDelegate

- (void)showMoreReplyFromIndexPath:(NSIndexPath *)indexPath {
//	NSLog(@"%@ indexPath = %@", NSStringFromSelector(_cmd), indexPath);
	showMoreReplyIndexPath = indexPath;
//	if (hasBestAnswer) {
////		Comment *selectedAnswer = answerList[indexPath.section - 1];
////		NSLog(@"selectedAnswer.cmi_info = %@", selectedAnswer.cmi_info);
//	} else {
//		Comment *selectedAnswer = answerList[indexPath.section - 2];
//		NSLog(@"selectedAnswer.cmi_info = %@", selectedAnswer.cmi_info);
//	}
	AnswerDetailViewController *answerDetailViewController = [[AnswerDetailViewController alloc] init];
	
	if (hasBestAnswer && indexPath.section == 1) {
		answerDetailViewController.answerContent = bestAnswer;
		answerDetailViewController.isBestAnswer = YES;
	} else {
		NSInteger index = [self indexOfAnswerAtIndexPath:indexPath];
		Comment *answer = answerList[index];
		answerDetailViewController.answerContent = answer;
		answerDetailViewController.isBestAnswer = answer.cmi_id == bestAnswer.cmi_id;
	}
	
	answerDetailViewController.questionUserID = currentAskContent.aki_source_id;
	answerDetailViewController.questionID = self.questionID;
	__weak typeof(self) weakSelf = self;
	answerDetailViewController.deletedAnswer = ^() {
		__strong typeof(weakSelf) strongSelf = weakSelf;
		[strongSelf deletedAnswerAtIndexPath:showMoreReplyIndexPath];
	};
	[self.navigationController pushViewController:answerDetailViewController animated:YES];
}

#pragma mark - AnswerReplyCellDelegate

- (void)deleteReplyAtIndexPath:(NSIndexPath *)indexPath {
//	NSInteger index = [self indexOfAnswerAtIndexPath:indexPath];
//	Comment *answer = answerList[index];
//	Comment *reply = answer.showComments[indexPath.row - 1];
//	NSLog(@"delete reply info = %@", reply.cmi_info);
	deleteReplyIndexPath = indexPath;
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Delete Reply?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
	alert.tag = TagDeleteReplyAlert;
	[alert show];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	NSString *actionTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	
	if ([actionTitle isEqualToString:@"Reply"]) {
		[self replyAnswer];
	} else if ([actionTitle isEqualToString:@"Best Answer"]) {
		[self showWithLabelText:@"" executing:@selector(setBestAnswer)];
	} else if ([actionTitle isEqualToString:@"Report"]) {
		[self reportUserAnswer];
	} else if ([actionTitle isEqualToString:@"Delete"]) {
		[self clickedDeleteBtnForRowAtIndexPath:operateAnswerIndexPath];
	}
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {// Delete
		switch (alertView.tag) {
			case TagDeleteAnswerAlert: {
				isDeleteReply = NO;
				[self showWithLabelText:@"" executing:@selector(deleteUserAnswer)];
			}
				break;
			case TagDeleteReplyAlert: {
				isDeleteReply = YES;
				[self showWithLabelText:@"" executing:@selector(deleteUserAnswer)];
			}
				break;
			case TagDeleteAskAlert: {
				[self showHUDWithText:@""];
				[self deleteThisAsk];
			}
				break;
		}
	}
}

#pragma mark - touch events

// 提交回答
- (void)commitAnswer {
	if (IsStringNotEmpty(answerContent)) {
		// 如果是回复评论状态，则拼接回复的字符串
		if (isReply) {
			Comment *answer = [answerList objectAtIndex:[self indexOfOperatorAnswerIndexPath]];
//			answerContent = [NSString stringWithFormat:@"Reply@%@:%@", answer.ci_nikename, answerContent];
			replyAnswerSourceID = [NSString stringWithFormat:@"%d", answer.cmi_id];
			replyAnswerUserID = [NSString stringWithFormat:@"%d", answer.cmi_ci_id];
            replyTwoAnswerSourceID = [NSString stringWithFormat:@"%d",answer.cmi_id];
		}
		
		[self showWithLabelText:@"" executing:@selector(commitUserAnswer)];
	}
}

// 回复用户回答，如果当前是回答状态，那就改为回复回答状态，并修改输入框的提示文字，弹出键盘
- (void)replyAnswer {
	NSLog(@"%@", NSStringFromSelector(_cmd));
	Comment *answer = [self answerOfOperatorAnswerIndexPath];
	NSString *answerUserName = answer.ci_nikename;
	self.answerToolBar.hintText = [NSString stringWithFormat:@"@%@:", answerUserName];
	isReply = YES;
	[self.answerToolBar.inputTextView becomeFirstResponder];
}

// 举报用户
- (void)reportUserAnswer {
    Comment *answer = [self answerOfOperatorAnswerIndexPath];
    ReportViewController *controller = [[ReportViewController alloc] initWithNibName:@"ReportViewController" bundle:nil];
    controller.commentId = answer.cmi_id;
    [self.navigationController pushViewController:controller animated:YES];
}

// 设置最佳答案
- (void)setBestAnswer {
	Comment *answer = [self answerOfOperatorAnswerIndexPath];
	
	NSString *answerID = [NSString stringWithFormat:@"%d", answer.cmi_id];
	NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[self.questionID, answerID] forKeys:@[@"aki_id", @"aki_best"]];
	[HttpManager setAskBestAnswerByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"code"] integerValue] == 0) {
			// 将这个回答赋值给最佳答案变量
			bestAnswer = answer;
//			// 然后从回答列表移除
//			[answerList removeObjectAtIndex:operateAnswerIndexPath.row];
			// 设置是否有最佳答案标记
			hasBestAnswer = YES;
			// 刷新列表
			[self.tableView reloadData];
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
	if (isReply) {
		if (self.answerToolBar.inputTextView.text.length == 0) {
			self.answerToolBar.hintText = COMMENT_HINT_TEXT;
			isReply = NO;
		}
	}
}

- (void)clickBestAnswerUserIcon {
	[self openUserInfoVCWithAnswer:bestAnswer];
}

- (void)clickAskContentUserIcon {
	Comment *ask = [[Comment alloc] init];
	ask.cmi_ci_id = (int)self.askContent.aki_source_id;
	ask.ci_nikename = self.askContent.aki_source_nikename;
	[self openUserInfoVCWithAnswer:ask];
}

- (void)clickDeleteBtn {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Delete Ask?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
	alert.tag = TagDeleteAskAlert;
	[alert show];
}

- (void)openUserInfoVCWithAnswer:(Comment *)answer {
	UserInfoViewController *userInfoViewController = [[UserInfoViewController alloc] init];
	userInfoViewController.uid = answer.cmi_ci_id;
	userInfoViewController.uname = answer.ci_nikename;
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
