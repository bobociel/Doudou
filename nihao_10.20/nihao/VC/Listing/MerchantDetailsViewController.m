//
//  MerchantDetailsViewController.m
//  nihao
//
//  Created by HelloWorld on 8/14/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "MerchantDetailsViewController.h"
#import "BaseFunction.h"
#import "Merchant.h"
#import "HttpManager.h"
#import <MJExtension/MJExtension.h>
#import "CenterTableView.h"
#import "MHeaderCell.h"
#import "MLocationCell.h"
#import "MCommonCell.h"
#import "MCommentCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "MerchantDiscountViewController.h"
#import "TaxiViewController.h"
#import "AddMCommentViewController.h"
#import "MerchantComment.h"
#import "UserInfoViewController.h"
#import "MUserReviewViewController.h"

@interface MerchantDetailsViewController () <UITableViewDelegate, UITableViewDataSource, MLocationCellDelegate, CenterTableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *commentButton;

@end

static NSString *HeaderCellID = @"MHeaderCell";
static NSString *LocationCellID = @"MLocationCell";
static NSString *CommonCellID = @"MCommonCell";
static NSString *CommentCellID = @"MCommentCell";
static NSString *CommentHeaderCellID = @"CommentHeaderCell";

@implementation MerchantDetailsViewController {
	NSArray *comments;
	BOOL hasDiscount;
}

// 商户详情列表
NSMutableArray *merchantDetail;

#pragma mark - View Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
//	self.title = self.merchantInfo.mhi_name;
	// 不显示返回 Title
	[self dontShowBackButtonTitle];
//	[[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
//	self.navigationController.edgesForExtendedLayout = UIRectEdgeNone;
	
//	UIBarButtonItem *addCommentItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_bar_add_comment"] style:UIBarButtonItemStylePlain target:self action:@selector(addComment)];
//	self.navigationItem.rightBarButtonItem = addCommentItem;
	
//	self.navigationController.navigationBar.translucent = YES;
//	self.automaticallyAdjustsScrollViewInsets = NO;
	
	hasDiscount = NO;
	
	CGRect tFrame = self.view.bounds;
	tFrame.size.height -= 50;
	self.tableView = [[UITableView alloc] initWithFrame:tFrame style:UITableViewStyleGrouped];
	self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
//	self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGFLOAT_MIN)];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.sectionFooterHeight = 0;
	[self.tableView registerNib:[UINib nibWithNibName:HeaderCellID bundle:nil] forCellReuseIdentifier:HeaderCellID];
	[self.tableView registerNib:[UINib nibWithNibName:LocationCellID bundle:nil] forCellReuseIdentifier:LocationCellID];
	[self.tableView registerNib:[UINib nibWithNibName:CommonCellID bundle:nil] forCellReuseIdentifier:CommonCellID];
	[self.tableView registerNib:[UINib nibWithNibName:CommentCellID bundle:nil] forCellReuseIdentifier:CommentCellID];
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CommentHeaderCellID];
	[self.view addSubview:self.tableView];
	
	UIView *commentContainer = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 64 - 50, SCREEN_WIDTH, 50)];
	commentContainer.backgroundColor = RootBackgroundWhitelyColor;
	[self.view addSubview:commentContainer];
	
	self.commentButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 5, CGRectGetWidth(commentContainer.frame) - 60, 40)];
	self.commentButton.backgroundColor = [UIColor colorWithRed:1 green:144 / 255.0 blue:0 alpha:1];
	[self.commentButton setTitle:@"Add review" forState:UIControlStateNormal];
	[self.commentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	self.commentButton.titleLabel.font = FontNeveLightWithSize(18);
	[self.commentButton addTarget:self action:@selector(addComment) forControlEvents:UIControlEventTouchUpInside];
	[commentContainer addSubview:self.commentButton];
	[self requestMerchantDetails];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationController.navigationBar.translucent = YES;
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.hidesBottomBarWhenPushed = YES;
	CGRect tFrame = self.view.bounds;
	tFrame.size.height -= 50;
	self.tableView.frame = tFrame;
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

#pragma mark - Networking
#pragma mark 获取商户详情
- (void)requestMerchantDetails {
	NSString *merchantID = [NSString stringWithFormat:@"%ld", self.merchantInfo.mhi_id];
	NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[merchantID] forKeys:@[@"mhi_id"]];
	[HttpManager requestMerchantDetailWithParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"code"] integerValue] == 0) {
			NSDictionary *merchantInfo = responseObject[@"result"][@"merchantInfo"];
			self.merchantInfo = [Merchant objectWithKeyValues:merchantInfo];
			if (IsStringEmpty(self.merchantInfo.mhi_info)) {
				hasDiscount = NO;
			} else {
				hasDiscount = YES;
			}
			[self.tableView reloadData];
		}
		[self requestMerchantComments];
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
	}];
}

- (void)requestMerchantComments {
	NSString *merchantID = [NSString stringWithFormat:@"%ld", self.merchantInfo.mhi_id];
	NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[merchantID, @"5", @"1", @"1", @"3"]
														   forKeys:@[@"cmi_source_id", @"cmi_source_type", @"cmi_recursive_type", @"page", @"rows"]];
//	NSLog(@"request Merchant Comment List parameters = %@", parameters);
	[HttpManager requestCommentsByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"code"] integerValue] == 0) {
			[MerchantComment setupObjectClassInArray:^NSDictionary *{
				return @{
						 @"pictures" : @"Picture"
						 };
			}];
			NSArray *commentList = responseObject[@"result"][@"rows"];
			if (commentList.count > 0) {
				comments = [MerchantComment objectArrayWithKeyValuesArray:commentList];
				[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
			}
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
	}];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger numberOfRows = 0;
	
	switch (section) {
		case 0:
			numberOfRows = 2;
			break;
		case 1:
			numberOfRows = 1;
			break;
		case 2:
			numberOfRows = hasDiscount ? 2 : 1;
			break;
		case 3:
			numberOfRows = 1 + comments.count;
			break;
	}
	
	return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger row = indexPath.row;
	
	switch (indexPath.section) {
		case 0: {
			if (row == 0) {
				MHeaderCell *cell = (MHeaderCell *)[tableView dequeueReusableCellWithIdentifier:HeaderCellID];
				[cell configureCellWithMerchantInfo:self.merchantInfo];
				return cell;
			} else if (row == 1) {
				MLocationCell *cell = (MLocationCell *)[tableView dequeueReusableCellWithIdentifier:LocationCellID];
				[cell configureCellWithMerchantInfo:self.merchantInfo];
				cell.delegate = self;
				return cell;
			}
		}
		case 1: {
			MCommonCell *cell = (MCommonCell *)[tableView dequeueReusableCellWithIdentifier:CommonCellID];
			[cell configureCellWithIconName:@"time_icon" content:self.merchantInfo.mhi_business_time_info];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			return cell;
		}
		case 2: {
			MCommonCell *cell = (MCommonCell *)[tableView dequeueReusableCellWithIdentifier:CommonCellID];
			NSString *iconName = row == 0 ? @"icon_taxi" : @"icon_merchant_discount";
			NSString *content = row == 0 ? @"Taxi printout" : @"Merchant discount";
			[cell configureCellWithIconName:iconName content:content];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleDefault;
			return cell;
		}
		case 3: {
			if (row == 0) {
				UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CommentHeaderCellID];
				cell.textLabel.font = FontNeveLightWithSize(16);
				cell.textLabel.textColor = TextColor575757;
				cell.textLabel.text = @"User review";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				return cell;
			} else {
				MCommentCell *cell = (MCommentCell *)[tableView dequeueReusableCellWithIdentifier:CommentCellID];
				[cell configureCellWithMerchantComment:comments[indexPath.row - 1] commentContentType:MCommentContentTypeSummary];
				__weak typeof(self) weakSelf = self;
				cell.clickedUserIcon = ^(MerchantComment *comment) {
					[weakSelf lookUserInfoById:comment.ci_id userNickname:comment.ci_nikename];
				};
				return cell;
			}
		}
	}
	
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger row = indexPath.row;
	
	switch (indexPath.section) {
		case 0: {
			if (row == 0) {
				return 200;
			} else if (row == 1) {
				return [tableView fd_heightForCellWithIdentifier:LocationCellID configuration:^(MLocationCell *cell) {
					[cell configureCellWithMerchantInfo:self.merchantInfo];
				}];
			}
		}
		case 1: {
			return [tableView fd_heightForCellWithIdentifier:CommonCellID configuration:^(MCommonCell *cell) {
				[cell configureCellWithIconName:@"time_icon" content:self.merchantInfo.mhi_business_time_info];
			}];
		}
		case 2: {
			return 50;
		}
		case 3: {
			if (row == 0) {
				return 40;
			} else {
				return [tableView fd_heightForCellWithIdentifier:CommentCellID configuration:^(MCommentCell *cell) {
					[cell configureCellWithMerchantComment:comments[indexPath.row - 1] commentContentType:MCommentContentTypeSummary];
				}];
			}
		}
	}
	
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return 0;
	} else {
		return 15;
	}
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//  return 0;
//}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	NSInteger row = indexPath.row;
	
	switch (indexPath.section) {
		case 0:
			break;
		case 1:
			break;
		case 2: {
			if (row == 0) {
				TaxiViewController *taxiViewController = [[TaxiViewController alloc] init];
				taxiViewController.latitude = [self.merchantInfo.mhi_gpslat floatValue];
				taxiViewController.longitude = [self.merchantInfo.mhi_gpslong floatValue];
				taxiViewController.merchantTitle = self.merchantInfo.mhc_name;
				taxiViewController.merchantAddress = self.merchantInfo.mhi_address_cn;
				[self.navigationController pushViewController:taxiViewController animated:YES];
			} else if (row == 1) {
				MerchantDiscountViewController *merchantDiscountViewController = [[MerchantDiscountViewController alloc] init];
				merchantDiscountViewController.merchantID = self.merchantInfo.mhi_id;
				[self.navigationController pushViewController:merchantDiscountViewController animated:YES];
			}
		}
			break;
		case 3: {
			if (row == 0) {
				MUserReviewViewController *userReviewViewController = [[MUserReviewViewController alloc] init];
				userReviewViewController.merchantID = self.merchantInfo.mhi_id;
				[self.navigationController pushViewController:userReviewViewController animated:YES];
			} else {
			}
		}
			break;
	}
}

#pragma mark - Touch Events

- (void)addComment {
	AddMCommentViewController *addMCommentViewController = [[AddMCommentViewController alloc] init];
//	addMCommentViewController.merchantName = self.merchantInfo.mhi_name;
	addMCommentViewController.merchantID = [NSString stringWithFormat:@"%ld", self.merchantInfo.mhi_id];
	__weak typeof(self) weakSelf = self;
	addMCommentViewController.submitReviewSuccess = ^() {
		[weakSelf requestMerchantComments];
	};
	[self.navigationController pushViewController:addMCommentViewController animated:YES];
}

- (void)lookUserInfoById:(NSInteger)userId userNickname:(NSString *)nickname {
	UserInfoViewController *userInfoViewController = [[UserInfoViewController alloc] init];
	userInfoViewController.uid = userId;
	userInfoViewController.uname = nickname;
	[self.navigationController pushViewController:userInfoViewController animated:YES];
}

//#pragma mark - UIScrollViewDelegate
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//	if (scrollView == self.tableView) {
//		CGFloat scrollY = scrollView.contentOffset.y;
//		if (scrollY > 0) {
//			CGFloat alpha = scrollY / 136;
////			NSLog(@"scrollY = %lf, alpha = %lf", scrollY, alpha);
//			if (alpha < 0) {
//				alpha = 0;
//			} else if (alpha > 1) {
//				alpha = 1;
//			}
//			self.navigationController.navigationBarBackgroundAlpha = alpha;
//		}
//	}
//}

#pragma mark - MLocationCellDelegate

- (void)shouldCallMerchant {
	NSMutableArray *phones = [[NSMutableArray alloc] init];
	if (IsStringNotEmpty(self.merchantInfo.mhi_phone) && IsStringNotEmpty(self.merchantInfo.mhi_tel)) {
		[phones addObjectsFromArray:[self.merchantInfo.mhi_phone componentsSeparatedByString:@","]];
		[phones addObjectsFromArray:[self.merchantInfo.mhi_tel componentsSeparatedByString:@","]];
	} else if (IsStringNotEmpty(self.merchantInfo.mhi_phone)) {
		[phones addObjectsFromArray:[self.merchantInfo.mhi_phone componentsSeparatedByString:@","]];
	} else if (IsStringNotEmpty(self.merchantInfo.mhi_tel)) {
		[phones addObjectsFromArray:[self.merchantInfo.mhi_tel componentsSeparatedByString:@","]];
	}
	
	if (phones.count > 0) {
		CenterTableView *centerTableView = [[CenterTableView alloc] initWithFrame:self.view.bounds];
		centerTableView.delegate = self;
		[centerTableView configureViewWithDatas:phones];
		[centerTableView showInView:self.view];
	} else {
		//      [self showHUDWithText:@"No merchant Contact" delay:1.5];
	}
}

#pragma mark - CenterTableViewDelegate

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath withRowText:(NSString *)text {
	if (IsStringNotEmpty(text)) {
		//      text = @"057187632388";
		UIWebView *callWebview =[[UIWebView alloc] init];
		NSURL *telURL =[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", text]];
		[callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
		// 记得添加到view上
		[self.view addSubview:callWebview];
	}
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
