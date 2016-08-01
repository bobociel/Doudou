//
//  WorksDetailViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/29.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIImageView+WebCache.h>
#import <MediaPlayer/MediaPlayer.h>
#import "WTShopDetailViewController.h"
#import "WTSupplierViewController.h"
#import "WTWebViewViewController.h"
#import "WTSearchViewController.h"
#import "WTImageDetailCell.h"
#import "WTTopView.h"
#import "BottomSupplierView.h"
#import "SharePopView.h"
#import "CommPickView.h"
#import "GetService.h"
#import "WTProgressHUD.h"
#define ImageHeight    (360 * Height_ato)
#define ImageDiming    (220 * Height_ato)
#define kAvatarHeight  (54)
#define kCompanyHeight 14.0
#define kMaxHeight     100.0
@interface WTShopDetailViewController ()
<
    UITextViewDelegate,UITableViewDataSource, UITableViewDelegate,
    WTTopViewDelegate,BottomSupplierViewDelegate
>
@property (nonatomic, strong) WTSupplierPost *postDetail;
@property (nonatomic, strong) BottomSupplierView *bottomSupplier;
@property (nonatomic, strong) WTTopView   *topView;
@property (nonatomic, strong) SharePopView   *shareView;
@property (nonatomic, strong) CommPickView   *pickView;
@property (nonatomic, strong) UIImageView *headImageView;
@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) NSString *works_id;
@property (nonatomic, assign) BOOL isAdmin;
@property (nonatomic, assign) BOOL showAll;
@end

@implementation WTShopDetailViewController

+ (instancetype)instanceVCWithWrokID:(NSString *)workID
{
	WTShopDetailViewController *VC = [[WTShopDetailViewController alloc] init];
	VC.works_id = workID;
	return VC;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - kBottomViewHeight)];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.tableFooterView = [[UIView alloc] init];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];

	self.topView = [WTTopView topViewInView:self.view withType:@[@(WTTopViewTypeBack),@(WTTopViewTypeLike),@(WTTopViewTypeShare)]];
	self.topView.delegate = self;
	[self.view addSubview:_topView];

	self.bottomSupplier = [BottomSupplierView bootomViewInView:self.view];
	_bottomSupplier.mainDelegate = self;

	[self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)loadData
{
	[self showLoadingView];
	[GetService getShopDetailWithID:_works_id Block:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		if (error){
			[WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error defaultStr:@"" noresultStr:@""] showInView:self.view afterDelay:1];
		}else{
			_postDetail = [WTSupplierPost modelWithDictionary:result[@"data"]];
			NSMutableArray *originData = [NSMutableArray array];
			[originData addObject:@{@"name":@"案例价格",@"origin_user":_postDetail.price_range ? : @"暂无报价"}];
			if([_postDetail.hotel_name isNotEmptyCtg]){
				[originData addObject:@{@"name":@"婚宴酒店",@"origin_user":_postDetail.hotel_name}];
			}
			[originData addObjectsFromArray:_postDetail.origin_data];
			_postDetail.origin_data = originData;
			[self initBottomView];
			self.tableView.tableHeaderView = [self getHeaderView];
			self.tableView.tableFooterView = [self getFooterView];
			[self.tableView reloadData];
			[PostDataService postAccessLogWithServiceID:_postDetail.supplier_info.service_id andCityID:_postDetail.supplier_info.city_id andID:_postDetail.supplier_info.supplier_user_id andLogType:WTLogTypePost];
		}
	}];
}

- (void)initBottomView
{
	_isAdmin = _postDetail.supplier_info.level == WTSupplierLevelV;
	if(_isAdmin){

	}else{
		[_bottomSupplier setMinPrice:_postDetail.min_coupon andMaxPrice:_postDetail.max_coupon];
		_bottomSupplier.supplier_name = _postDetail.supplier_info.supplier_company;
		_bottomSupplier.supplier_avatar = _postDetail.supplier_info.supplier_avatar;
		_bottomSupplier.tel_num = [LWUtil getString:_postDetail.supplier_info.business_tel andDefaultStr:kServerPhone];
		[self.view addSubview:_bottomSupplier];
	}

	_topView.post_id = _postDetail.post_id;
	_topView.is_like = _postDetail.is_like;
	_topView.name = _postDetail.post_title;
}

#pragma mark - Action

- (void)goSupplier
{
	UIViewController *toVC ;
	for (UIViewController *VC in self.navigationController.viewControllers) {
		if([VC isKindOfClass:[WTSupplierViewController class]]){ toVC = VC; break ;}
	}

	if(toVC)
	{
		[self.navigationController popToViewController:toVC animated:YES];
	}
	else
	{
		WTSupplierViewController *supplierVC = [[WTSupplierViewController alloc] init];
		supplierVC.supplier_id = _postDetail.supplier_info.supplier_user_id ;
		[self.navigationController pushViewController:supplierVC animated:YES];
	}
}

- (void)showAction:(UIButton *)sender
{
	_showAll = !_showAll;
	self.tableView.tableHeaderView = [self getHeaderView];
}

- (void)searchHotelAction:(UIButton *)sender
{
	[self.navigationController pushViewController:[WTSearchViewController instanceSearchVCWithType:SearchTypeHotel andSearchKey:sender.titleLabel.text] animated:YES];
}

- (void)searchSupplierAction:(UIButton *)sender
{
	[self.navigationController pushViewController:[WTSearchViewController instanceSearchVCWithType:SearchTypeSupplier andSearchKey:sender.titleLabel.text] animated:YES];
}

#pragma mark - TopViewDelegate
- (void)topView:(WTTopView *)topView didSelectedBack:(UIControl *)backButton
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)topView:(WTTopView *)topView didSelectedLike:(UIControl *)likeButton
{
	_postDetail.is_like = likeButton.selected;
//	if(_likeBlock){ self.likeBlock(likeButton.selected); }
}

- (void)topView:(WTTopView *)topView didSelectedShare:(UIControl *)shareButton
{
	self.shareView = [SharePopView viewWithhareTypes:@[@(WTShareTypeWX),@(WTShareTypeQQ),@(WTShareTypeSina),@(WTShareTypeCopy)]];
	[self.shareView show];
	NSString *urlString = [NSString stringWithFormat:@"%@%@",kPostURL,_postDetail.post_id];
	NSMutableAttributedString *shareDesc = [LWUtil returnAttributedStringWithHtml:[LWUtil getString:_postDetail.post_description andDefaultStr:@""] ];
	_shareView.shareInfo = [SharePopViewInfo SharePopViewInfoWithTitle:_postDetail.post_title
														andDescription:shareDesc.string
															 andUrlStr:urlString
														   andImageURL:_postDetail.post_cover];
}

#pragma mark - BottomViewDelegate
- (void)bottomSupplierViewConversationSelected
{
	[self conversationSelectType:WTConversationTypePost
					 supplier_id:_postDetail.supplier_info.supplier_user_id
				   sendToAskData:[_postDetail modelToJSONObject]
							name:_postDetail.post_title
						   phone:self.bottomSupplier.tel_num
						  avatar:_postDetail.supplier_info.supplier_avatar];
}

- (void)bottomSupplierViewCheckSelectedWithDateString:(NSString *)string
{
	[self conversationSelectType:WTConversationTypePost
					 supplier_id:_postDetail.supplier_info.supplier_user_id
				   sendToAskData:string
							name:_postDetail.post_title
						   phone:self.bottomSupplier.tel_num
						  avatar:_postDetail.supplier_info.supplier_avatar];
}

- (void)bottomSupplierViewBaoSelected
{
	[self showLoadingView];
	[GetService getTicketListWithSID:_postDetail.supplier_info.supplier_user_id block:^(NSDictionary *result, NSError *error) {
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _postDetail.post_image.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	WTPostImage *postImage = _postDetail.post_image[indexPath.row];
	WTImageDetailCell *cell = [tableView WTImageDetailCell];
	[cell setCellWithPostImage:postImage andVideoPath:_postDetail.video];
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	WTPostImage *postImage = _postDetail.post_image[indexPath.row];
	return [WTImageDetailCell cellHeight:postImage];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	WTPostImage *postImage = _postDetail.post_image[indexPath.row];
	if(postImage.is_video && _postDetail.video && ![_postDetail.video hasPrefix:youku]){
		MPMoviePlayerViewController *videoVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:_postDetail.video]];
		[self.navigationController presentMoviePlayerViewControllerAnimated:videoVC];
	}
}

#pragma mark - TextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
	NSString *openURLStr = [textView.text substringWithRange:characterRange];
	if(![openURLStr hasPrefix:@"http://"] && ![openURLStr hasPrefix:@"https://"])
	{
		openURLStr = [NSString stringWithFormat:@"http://%@",openURLStr];
	}

	if(![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:openURLStr]])
	{
		[WTProgressHUD ShowTextHUD:@"网址不可用" showInView:self.view afterDelay:1];
	}
	else
	{
		[self.navigationController pushViewController:[WTWebViewViewController instanceViewControllerWithURL:[NSURL URLWithString:openURLStr]] animated:YES];
	}
	return NO;
}

#pragma mark - View

- (UIView *)getHeaderView
{
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, ImageHeight)];

	_headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, ImageHeight)];
	_headImageView.clipsToBounds = YES;
	_headImageView.contentMode = UIViewContentModeScaleAspectFill;
	[headerView addSubview:_headImageView];
	[_headImageView sd_setImageWithURL:[NSURL URLWithString:[_postDetail.post_cover stringByAppendingString:kSmall600]] placeholderImage:[UIImage imageNamed:@"placelolder_detail"]];

	CALayer *dimingLayer = [LWUtil gradientLayerWithFrame:CGRectMake(0,ImageHeight - ImageDiming, screenWidth, ImageDiming)];
	[headerView.layer addSublayer:dimingLayer];

	UIImageView *avatarImage = [[UIImageView alloc] initWithFrame:CGRectMake((screenWidth-kAvatarHeight)/2.0, _headImageView.bottom - 42, kAvatarHeight, kAvatarHeight)];
	avatarImage.userInteractionEnabled = YES;
	avatarImage.layer.borderColor = WHITE.CGColor;
	avatarImage.layer.borderWidth = 3.f;
	avatarImage.layer.cornerRadius = kAvatarHeight / 2.0;
	avatarImage.layer.masksToBounds = YES;
	[headerView addSubview:avatarImage];
	UITapGestureRecognizer *headerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goSupplier)];
	[avatarImage addGestureRecognizer:headerTap];
	[avatarImage sd_setImageWithURL:[NSURL URLWithString:[_postDetail.supplier_info.supplier_avatar stringByAppendingString:kSmall600]]
				   placeholderImage:[UIImage imageNamed:@"supplier"]];

	UIImageView *VIPImageView = [[UIImageView alloc] initWithFrame:CGRectMake(avatarImage.right-17, avatarImage.bottom-17, 20, 20)];
	VIPImageView.hidden = _postDetail.supplier_info.level == WTSupplierLevelV0;
	VIPImageView.image = [LWUtil getVIPImageWithSupplierLevel:_postDetail.supplier_info.level];
	[headerView addSubview:VIPImageView];

	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(36, avatarImage.bottom+20, screenWidth-36*2, 0)];
	titleLabel.font = DefaultFont16;
	titleLabel.textColor = [UIColor blackColor];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.numberOfLines = 0;
	[headerView addSubview:titleLabel];
	NSString *titleStr = [LWUtil getString:_postDetail.post_title andDefaultStr:@""];
	titleLabel.text = titleStr;

	CGSize titleSize = [titleStr sizeForFont:DefaultFont16 size:CGSizeMake(screenWidth - 36 * 2 , MAXFLOAT) mode:NSLineBreakByWordWrapping];
	titleLabel.height = ceil(titleSize.height);

	UILabel *companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, titleLabel.bottom+10, screenWidth, kCompanyHeight)];
	companyLabel.font = DefaultFont12;
	companyLabel.textColor = rgba(100, 100, 100, 1);
	companyLabel.textAlignment = NSTextAlignmentCenter;
	[headerView addSubview:companyLabel];
	companyLabel.text =  [LWUtil stringWithCompany:_postDetail.supplier_info.supplier_company andCity:_postDetail.supplier_info.city andPrice:_postDetail.supplier_info.lowest_price];

	UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, companyLabel.bottom+30, screenWidth, 4)];
	lineView.backgroundColor = rgba(247, 247, 247, 1);
	[headerView addSubview:lineView];

	UITextView *detailLabel = [[UITextView alloc] initWithFrame:CGRectMake(20, lineView.bottom+25, screenWidth - 20*2, 0)];
	detailLabel.textColor = rgba(153, 153, 153, 1);
	detailLabel.tintColor = WeddingTimeBaseColor;
	detailLabel.font = DefaultFont12;
	detailLabel.delegate = self;
	detailLabel.scrollEnabled = NO;
	detailLabel.editable = NO;
	detailLabel.textAlignment = NSTextAlignmentLeft;
	detailLabel.dataDetectorTypes = UIDataDetectorTypeLink;
	[headerView addSubview:detailLabel];

	NSString *descContent = _postDetail.post_description;
	detailLabel.text = descContent;

	CGSize descSize = [LWUtil textViewSizeWithTextView:detailLabel andWidth:(screenWidth - 20 * 2)];
	CGFloat descHeight = [descContent isNotEmptyCtg] ? ceil(descSize.height) : 0;
	[UIView animateWithDuration:0.1 animations:^{
		detailLabel.height = _showAll ? descHeight : MIN(kMaxHeight, descHeight) ;
	}];

	UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	moreBtn.frame = CGRectMake(0, detailLabel.bottom + 25, screenWidth, descHeight > kMaxHeight ? kTabBarHeight : 0);
	moreBtn.clipsToBounds = YES;
	moreBtn.titleLabel.font = DefaultFont14;
	moreBtn.layer.borderWidth = 1.f;
	moreBtn.layer.borderColor = rgba(247, 247, 247, 1).CGColor;
	[moreBtn setTitleColor:rgba(170, 170, 170, 1) forState:UIControlStateNormal];
	[moreBtn setTitle:!_showAll ? @"展开全部" : @"收回全部" forState:UIControlStateNormal];
	[headerView addSubview:moreBtn];
	[moreBtn addTarget:self action:@selector(showAction:) forControlEvents:UIControlEventTouchUpInside];

	UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, moreBtn.bottom, screenWidth, 4)];
	lineView2.backgroundColor = rgba(247, 247, 247, 1);
	[headerView addSubview:lineView2];

	lineView2.hidden = ![descContent isNotEmptyCtg];
	headerView.height = [descContent isNotEmptyCtg] ? lineView2.bottom : lineView.bottom;
	return headerView;
}

- (UIView *)getFooterView
{
	NSArray *destArray = _postDetail.origin_data;
	UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0.1)];
	footerView.backgroundColor = [UIColor whiteColor];

	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(20, 30, screenWidth-40, 40*destArray.count)];
	[footerView addSubview:contentView];
	for (int i = 0; i < destArray.count; i++) {
		NSDictionary *dic = destArray[i];
		UILabel *leftlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40*i, 76, 40)];
		leftlabel.font = DefaultFont14;
		leftlabel.textColor = rgba(200, 200, 200, 1);
		[contentView addSubview:leftlabel];
		leftlabel.text = [LWUtil getString:dic[@"name"] andDefaultStr:@""];

		UIButton *rightlabel = [UIButton buttonWithType:UIButtonTypeCustom];
		rightlabel.frame = CGRectMake(76, 40*i, contentView.width-80, 40);
		rightlabel.titleLabel.font = DefaultFont14;
		rightlabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		[rightlabel setTitleColor:rgba(153, 153, 153, 1) forState:UIControlStateNormal];
		[contentView addSubview:rightlabel];

		NSString *title = [LWUtil getString:dic[@"origin_user"] andDefaultStr:@""];
		[rightlabel setTitle:title forState:UIControlStateNormal];
		if(i == 0){
			[rightlabel setTitleColor:WeddingTimeBaseColor forState:UIControlStateNormal];
		}else if([_postDetail.hotel_name isNotEmptyCtg] && i == 1){
			[rightlabel addTarget:self action:@selector(searchHotelAction:) forControlEvents:UIControlEventTouchUpInside];
		}else{
			[rightlabel addTarget:self action:@selector(searchSupplierAction:) forControlEvents:UIControlEventTouchUpInside];
		}
	}

	UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	moreBtn.frame = CGRectMake(0, contentView.bottom + 25, screenWidth, kTabBarHeight);
	moreBtn.titleLabel.font = DefaultFont14;
	moreBtn.layer.borderWidth = 1.f;
	moreBtn.layer.borderColor = rgba(247, 247, 247, 1).CGColor;
	[moreBtn setTitleColor:rgba(170, 170, 170, 1) forState:UIControlStateNormal];
	[moreBtn setTitle:@"全部作品" forState:UIControlStateNormal];
	[footerView addSubview:moreBtn];
	[moreBtn addTarget:self action:@selector(goSupplier) forControlEvents:UIControlEventTouchUpInside];

	footerView.height = MAX(moreBtn.bottom, 0.1);
	return footerView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	CGFloat yOffset   = self.tableView.contentOffset.y;
	if (yOffset < 0)
	{
		CGFloat factor = ((ABS(yOffset)+ImageHeight) * screenWidth)/ImageHeight;
		CGRect f = CGRectMake(-(factor- screenWidth)/2, yOffset, factor, ImageHeight+ABS(yOffset));
		_headImageView.frame = f;
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
