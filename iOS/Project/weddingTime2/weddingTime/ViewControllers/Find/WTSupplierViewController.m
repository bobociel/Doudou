//
//  SupplierViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/24.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIImageView+WebCache.h>
#import "WTSupplierViewController.h"
#import "WTWorksDetailViewController.h"
#import "NetworkManager.h"
#import "SupplierDetailCell.h"
#import "WTSKUCell.h"
#import "GetService.h"
#import "CircleImage.h"
#import "MJRefresh.h"
#import "WTTopView.h"
#import "BottomServiceView.h"
#import "BottomSupplierView.h"
#import "CommPickView.h"
#import "SharePopView.h"
#import "WTProgressHUD.h"
#import "NetWorkingFailDoErr.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"
#import "UIImage+YYAdd.h"
#define kPageSize 5
#define ImageHeight (350 * Width_ato)
#define ImageWidth  screenWidth
#define kSKUCellHeight 108.0
@interface WTSupplierViewController ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, WTTopViewDelegate,BottomServiceViewDelegate,BottomSupplierViewDelegate>
{
	UIImageView *imageView;
	UIImageView *blurImage;
	UIImage *tempImage;
}
@property (nonatomic, strong) WTSupplier     *supplierDetail;
@property (nonatomic, strong) WTTopView      *topView;
@property (nonatomic, strong) BottomServiceView   *bottomService;
@property (nonatomic, strong) BottomSupplierView  *bottomSupplier;
@property (nonatomic, strong) CommPickView   *pickView;
@property (nonatomic, strong) SharePopView   *shareView;
@property (nonatomic, strong) UITableView    *tableView;
@property (nonatomic, strong) NSMutableArray *posts;
@property (nonatomic, assign) BOOL   isAdmin;
@end

@implementation WTSupplierViewController

- (void)setNavWithHidden
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationController.navigationBar.translucent = YES;
	self.posts = [NSMutableArray array];
	[self initView];
	[self loadData];

	self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
		[self loadLocalData];
	}];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)initView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - kBottomViewHeight) style:UITableViewStyleGrouped];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, ImageHeight)];
	_tableView.tableFooterView = [[UIView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];

	self.topView = [WTTopView topViewInView:self.view withType:@[@(WTTopViewTypeBack),@(WTTopViewTypeShare),@(WTTopViewTypeLike)]];
	self.topView.delegate = self;
	[self.view addSubview:_topView];

	self.bottomService = [BottomServiceView bootomViewInView:self.view];
	_bottomService.mainDelegate = self;
    self.bottomSupplier = [BottomSupplierView bootomViewInView:self.view];
    _bottomSupplier.mainDelegate = self;
}

- (void)initBottomView
{
	_isAdmin = _supplierDetail.level == WTSupplierLevelV;
	if(_isAdmin){
        [self.view addSubview:_bottomService];
	}else{
        [_bottomSupplier setMinPrice:_supplierDetail.min_coupon andMaxPrice:_supplierDetail.max_coupon];
        [self.view addSubview:_bottomSupplier];
	}

	_bottomService.supplier_avatar = _supplierDetail.supplier_avatar;
	_bottomService.tel_num = [LWUtil getString:_supplierDetail.phone andDefaultStr:kServerPhone];

	_bottomSupplier.supplier_name = _supplierDetail.supplier_name;
    _bottomSupplier.supplier_avatar = _supplierDetail.supplier_avatar;
    _bottomSupplier.tel_num = [LWUtil getString:_supplierDetail.phone andDefaultStr:kServerPhone];
    
	_topView.is_like = _supplierDetail.is_like;
	_topView.supplier_id = _supplier_id;
	_topView.name = _supplierDetail.supplier_name;
}

- (void)loadData
{
	if (!_supplier_id) { _supplier_id = @"0"; }
	[self showLoadingView];
	[GetService getSupplierDetailWithId:_supplier_id WithBlock:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		[NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];
		if (error)
		{
			NSString *errorContent=[LWAssistUtil getCodeMessage:error andDefaultStr:@""];
			[NetWorkingFailDoErr errWithView:self.tableView content:errorContent tapBlock:^{
				[self loadData];
			}];
		}
		else
		{
			_supplierDetail = [WTSupplier modelWithDictionary:result];
			_tableView.tableHeaderView = [self getHeaderView];
			[self loadLocalData];
			[self initBottomView];
		}
		[PostDataService postAccessLogWithServiceID:_supplierDetail.service_id andCityID:_supplierDetail.city_id andID:_supplier_id andLogType:WTLogTypeSupplier];
	}];
}

- (void)loadLocalData
{
	NSInteger currentCount = _posts.count;
	for (NSUInteger i = currentCount; i < kPageSize + currentCount ; i++)
	{
		if(i < _supplierDetail.supplier_post.count){
			[_posts addObject:_supplierDetail.supplier_post[i]];
		}
	}
	[self.tableView.footer endRefreshing];
	[self.tableView reloadData];
	self.tableView.footer.hidden = _posts.count == _supplierDetail.supplier_post.count;
}

#pragma mark - Action
- (void)topView:(WTTopView *)topView didSelectedBack:(UIControl *)backButton
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)topView:(WTTopView *)topView didSelectedLike:(UIControl *)likeButton
{
	_supplierDetail.is_like = likeButton.selected;
	if(_likeBlock) { self.likeBlock(likeButton.selected); }
}

- (void)topView:(WTTopView *)topView didSelectedShare:(UIControl *)shareButton
{
	self.shareView = [SharePopView viewWithhareTypes:@[@(WTShareTypeWX),@(WTShareTypeQQ),@(WTShareTypeSina),@(WTShareTypeCopy)]];
	[self.shareView show];
	NSString *urlString = [NSString stringWithFormat:@"%@%@",kSupplierURL,_supplier_id];
	_shareView.shareInfo = [SharePopViewInfo SharePopViewInfoWithTitle:_supplierDetail.supplier_name
														andDescription:_supplierDetail.supplier_description
															 andUrlStr:urlString
														   andImageURL:_supplierDetail.supplier_avatar];
}

#pragma mark - BottomViewDelegate

- (void)bottomServiceViewCheckSelectedWithDateString:(NSString *)string
{
	[self conversationSelectType:WTConversationTypeHotelOrCustomer
					 supplier_id:kServerID
				   sendToAskData:string
							name:kServerName
						   phone:kServerPhone
                          avatar:kServerAvatar ];
}

- (void)bottomSupplierViewConversationSelected
{
    [self conversationSelectType:WTConversationTypeSupplier
                     supplier_id:_supplier_id
                   sendToAskData:[_supplierDetail modelToJSONObject]
                            name:_supplierDetail.supplier_name
                           phone:self.bottomSupplier.tel_num
                          avatar:_supplierDetail.supplier_avatar];
}

- (void)bottomSupplierViewCheckSelectedWithDateString:(NSString *)string
{
    [self conversationSelectType:WTConversationTypeSupplier
                     supplier_id:_supplier_id
                   sendToAskData:string
                            name:_supplierDetail.supplier_name
                           phone:self.bottomSupplier.tel_num
                          avatar:_supplierDetail.supplier_avatar];
}

- (void)bottomSupplierViewBaoSelected
{
	[self showLoadingView];
	[GetService getTicketListWithSID:_supplier_id block:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		if(!error){
			NSArray *ticketArray = [NSArray modelArrayWithClass:[WTTicket class] json:result[@"data"]];
			if(ticketArray.count > 0){
				_pickView = [CommPickView instanceWithStyle:PickViewStyleTable andTag:0 andArray:ticketArray];
				[_pickView show];
			}else{
				[WTProgressHUD ShowTextHUD:@"该商家暂时没有补贴" showInView:self.view];
			}
		}else{
			[WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error andDefaultStr:@"出问题啦,稍后再试"] showInView:self.view];
		}
	}];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return (section == WTSuCellTypeSKU) ? 1 : _posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section == WTSuCellTypeSKU)
	{
		WTSKUCell *cell = [tableView WTSKUCell];
        cell.cardSKUView.hidden = YES;
		cell.likeLabel.text = @(_supplierDetail.likeCount).stringValue;
		cell.workLabel.text = @(_supplierDetail.supplier_post_num).stringValue;
		return cell;
	}
	else
	{
		WTSupplierPost *post = _posts[indexPath.row];
		SupplierDetailCell *cell = [tableView supplerDetailCell];
		cell.post = post;
		return cell;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section == WTSuCellTypeSKU)
	{
		return kSKUCellHeight ;
	}
	else
	{
		WTSupplierPost *post = _posts[indexPath.row];
		CGRect rect = [post.post_name boundingRectWithSize:CGSizeMake(screenWidth - 50, 10000)
												   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
												attributes:@{NSFontAttributeName:DefaultFont18}
												   context:nil];
		return (screenWidth / post.width * post.heigth) + ceil(rect.size.height) + 35;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WTSupplierPost *post = _posts[indexPath.row];
    WTWorksDetailViewController *ban = [WTWorksDetailViewController instanceWTWorksDetailVCWithWrokID:post.post_id];
    [self.navigationController pushViewController:ban animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 0.1;
}

- (UIView *)getHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, ImageHeight)];
    
    blurImage = [UIImageView new];
	blurImage.clipsToBounds = YES;
	blurImage.contentMode = UIViewContentModeScaleAspectFill;
    [headerView addSubview:blurImage];
    
    NSString *backgroundStr = _supplierDetail.supplier_banner;
    if (![backgroundStr isNotEmptyCtg]) {
        backgroundStr = _supplierDetail.supplier_avatar;
    }

    [blurImage sd_setImageWithURL:[NSURL URLWithString:[backgroundStr stringByAppendingString:kSmall600]]
				 placeholderImage:[UIImage imageNamed:@""] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        tempImage = image;
        UIImage *blImage = [image imageByBlurRadius:13 tintColor:nil tintMode:0 saturation:1 maskImage:nil];
        blurImage.image = blImage;
    }];
    
    [blurImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(ImageHeight);
    }];

    CircleImage *avatarImage = [CircleImage new];
    [avatarImage.centerImage sd_setImageWithURL:[NSURL URLWithString:_supplierDetail.supplier_avatar]
							   placeholderImage:[UIImage imageNamed:@"supplier"]];
    [headerView addSubview:avatarImage];
    [avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(140 * Width_ato);
        make.centerX.mas_equalTo(headerView);
        make.size.mas_equalTo(CGSizeMake(64 * Width_ato, 64 * Width_ato));
    }];

	UIImageView *VIPImageView = [UIImageView new];
	VIPImageView.hidden = _supplierDetail.level == WTSupplierLevelV0;
	VIPImageView.image = [LWUtil getVIPImageWithSupplierLevel:_supplierDetail.level];
	[avatarImage addSubview:VIPImageView];
	[VIPImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.mas_equalTo(5.0);
		make.right.mas_equalTo(5.0);
		make.size.mas_equalTo(CGSizeMake(20, 20));
	}];

    UILabel *titleLabel = [UILabel new];
    titleLabel.text = [LWUtil getString:_supplierDetail.supplier_name andDefaultStr:@""];
    titleLabel.textColor = WHITE;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:24];
    [headerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(avatarImage.mas_bottom).offset(35.0 * Width_ato);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(24);
    }];

    UILabel *detailLabel = [UILabel new];
    detailLabel.textColor = WHITE;
    detailLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];
    detailLabel.textAlignment = NSTextAlignmentCenter;
	detailLabel.text = [LWUtil getVIPComDetailWithSupplierLeve:_supplierDetail.level andTypeName:_supplierDetail.service_type];
    [headerView addSubview:detailLabel];
    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(titleLabel.mas_bottom).offset(15.0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(17);
    }];

    return headerView;
}

- (void)workButtonAction
{
    if (self.posts.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat yOffset = self.tableView.contentOffset.y;
    
    if (yOffset < 0)
    {
        CGFloat factor = ((ABS(yOffset)+ImageHeight)*ImageWidth)/ImageHeight;
        CGRect f = CGRectMake(-(factor-ImageWidth)/2, yOffset, factor, ImageHeight+ABS(yOffset));
        blurImage.frame = f;
        
        UIImage *blImage = [tempImage imageByBlurRadius:(140 + yOffset) / 140 * 13 tintColor:nil tintMode:0 saturation:1 maskImage:nil];
        blurImage.image = blImage;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
