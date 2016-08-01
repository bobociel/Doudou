//
//  WorksDetailViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/29.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIImageView+WebCache.h>
#import "WTWorksDetailViewController.h"
#import "WTSupplierViewController.h"
#import "WTWebViewViewController.h"
#import "webViewCellTableViewCell.h"
#import "WTTopView.h"
#import "SharePopView.h"
#import "GetService.h"
#import "WorksDetailCell.h"
#import "WTProgressHUD.h"
#define ImageHeight  (350 * Width_ato)
#define kAvatarHeight (50.0 * Width_ato)
#define kItemSpaces  (20.0 * 2 + 25 * 3)
#define kMainBtnHeight 32.0
#define kMainBtnWidth 86.0
#define kPriceHeight  16.0
@interface WTWorksDetailViewController ()
<
    UITextViewDelegate,UITableViewDataSource, UITableViewDelegate,WTTopViewDelegate,BottomViewDelegate
>
@property (nonatomic, strong) WTTopView *topView;
@property (nonatomic, strong) BottomView *bottom;
@property (nonatomic, strong) WTSupplierPost *postDetail;
@property (nonatomic, strong) SharePopView   *shareView;
@property (nonatomic, strong) UIImageView *headImageView;
@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) NSString *works_id;
@property (nonatomic, assign) BOOL isAdmin;
@end

@implementation WTWorksDetailViewController

+ (instancetype)instanceWTWorksDetailVCWithWrokID:(NSString *)workID
{
	WTWorksDetailViewController *VC = [[WTWorksDetailViewController alloc] init];
	VC.works_id = workID;
	return VC;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) style:UITableViewStylePlain];
	self.tableView.tableFooterView = [[UIView alloc] init];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];

	[self showLoadingView];
    [self loadData];

	self.topView = [WTTopView topViewInView:self.view withType:@[@(WTTopViewTypeBack),@(WTTopViewTypeShare),@(WTTopViewTypeLike)]];
	self.topView.delegate = self;
	[self.view addSubview:_topView];

	self.bottom = [BottomView bootomViewInView:self.view];
	_bottom.mainDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)initBottomView
{
	_tableView.height = screenHeight - kBottomViewHeight;
	[self.view addSubview:_bottom];
	_isAdmin = _postDetail.is_admin;
	if(_postDetail.is_admin){
		[_bottom setCompany];
	}else{
		[_bottom setCompany:_postDetail.supplier_company andPrice:_postDetail.price];
	}
	_bottom.supplier_avatar = _postDetail.supplier_avatar;
	_bottom.tel_num = [LWUtil getString:_postDetail.tel andDefaultStr:kServerPhone] ;

	_topView.is_like = _postDetail.is_like;
	_topView.supplier_id = _postDetail.supplier_user_id;
	_topView.name = _postDetail.supplier_company ;
	_topView.supplier_avatar = _postDetail.supplier_avatar;
}

- (void)loadData
{
	[GetService getWorkDetailWithPostId:_works_id Block:^(NSDictionary *dic, NSError *error) {
		[self hideLoadingView];
		if (error){
			[WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error defaultStr:@"" noresultStr:@""] showInView:self.view afterDelay:1];
		}
		_postDetail = [WTSupplierPost modelWithDictionary:dic];
		if([LWUtil getString:_postDetail.video andDefaultStr:@""].length > 0)
		{
			[_postDetail.post_image insertObject:_postDetail.video atIndex:0];
		}
		[self initBottomView];
		self.tableView.tableHeaderView = [self getHeaderView];
		self.tableView.tableFooterView = [self getFooterView];
		[self.tableView reloadData];
		[PostDataService postAccessLogWithServiceID:_postDetail.service_id andCityID:_postDetail.city_id andSUID:_postDetail.supplier_user_id andSOP:WTLogTypePost];
	}];
}

#pragma mark - Action
- (void)topView:(WTTopView *)topView didSelectedBack:(UIControl *)backButton
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)topView:(WTTopView *)topView didSelectedLike:(UIControl *)likeButton
{
	_postDetail.is_like = likeButton.selected;
	if(_likeBlock){ self.likeBlock(likeButton.selected); }
}

- (void)topView:(WTTopView *)topView didSelectedShare:(UIControl *)shareButton
{
	self.shareView = [SharePopView viewWithhareTypes:@[@(WTShareTypeWX),@(WTShareTypeCopy)]];
	[self.shareView show];
	NSString *urlString = [NSString stringWithFormat:@"%@%@",kPostURL,_postDetail.post_id];
	NSMutableAttributedString *shareDesc = [LWUtil returnAttributedStringWithHtml:[LWUtil getString:_postDetail.post_description andDefaultStr:@""] ];
	_shareView.shareInfo = [SharePopViewInfo SharePopViewInfoWithTitle:_postDetail.post_title
														andDescription:shareDesc.string
															 andUrlStr:urlString
														   andImageURL:_postDetail.post_avatar];
}

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
		supplierVC.supplier_id = _postDetail.supplier_user_id ;
		[self.navigationController pushViewController:supplierVC animated:YES];
	}
}

#pragma mark - BottomViewDelegate
- (void)bottomViewConversationSelected
{
	[self conversationSelectType:_isAdmin ? WTConversationTypeHotelOrCustomer : WTConversationTypePost
					 supplier_id:_isAdmin ? kServerID : _postDetail.supplier_user_id
				   sendToAskData:_isAdmin ? nil : [_postDetail modelToJSONObject]
							name:_isAdmin ? kServerName: _postDetail.post_title
						   phone:_isAdmin ? kServerPhone: self.bottom.tel_num
						  avatar:_isAdmin ? kServerAvatar: _postDetail.supplier_avatar];
}

- (void)bottomViewCheckSelectedWithDateString:(NSString *)string
{
	[self conversationSelectType:WTConversationTypePost
					 supplier_id:_postDetail.supplier_user_id
				   sendToAskData:string
							name:_postDetail.post_title
						   phone:self.bottom.tel_num
						  avatar:_postDetail.supplier_avatar];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _postDetail.post_image.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id info = _postDetail.post_image[indexPath.row];
    if ([info isKindOfClass:[NSString class]]) {
        webViewCellTableViewCell *cell = [tableView webViewCell];
        [cell setInfo:info];
        return cell;
    }
    WorksDetailCell *cell = [tableView WorksDetailCell];
    [cell setInfo:info];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id info = _postDetail.post_image[indexPath.row];
    if([info isKindOfClass:[NSString class]]) {
        return 350;
    }
    NSString *height = info[@"height"];
    NSString *width = info[@"width"];
    return screenWidth / width.intValue * height.intValue + 10;
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
	_headImageView.contentMode = UIViewContentModeScaleAspectFill;
	[headerView addSubview:_headImageView];

	[_headImageView sd_setImageWithURL:[NSURL URLWithString:[_postDetail.post_avatar stringByAppendingString:kSmall600]]
					  placeholderImage:[UIImage imageNamed:@"placelolder_detail"]];
	_headImageView.clipsToBounds = YES;

	UIImageView *avatarImage = [UIImageView new];
	avatarImage.userInteractionEnabled = YES;
	avatarImage.layer.borderColor = WHITE.CGColor;
	avatarImage.layer.borderWidth = 3.f;
	avatarImage.layer.cornerRadius = kAvatarHeight / 2.0;
	avatarImage.layer.masksToBounds = YES;
	[headerView addSubview:avatarImage];
	UITapGestureRecognizer *headerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goSupplier)];
	[avatarImage addGestureRecognizer:headerTap];
	[avatarImage sd_setImageWithURL:[NSURL URLWithString:[_postDetail.supplier_avatar stringByAppendingString:kSmall600]]
				   placeholderImage:[UIImage imageNamed:@"supplier"]];

	[avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_headImageView.mas_bottom).offset(-25 * Width_ato);
		make.centerX.equalTo(headerView);
		make.size.mas_equalTo(CGSizeMake( kAvatarHeight, kAvatarHeight));
	}];

	UILabel *titleLabel = [UILabel new];
	titleLabel.font = DefaultFont20;
	titleLabel.textColor = [UIColor blackColor];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.numberOfLines = 0;
	[headerView addSubview:titleLabel];
	NSString *titleStr = [LWUtil getString:_postDetail.post_title andDefaultStr:@""];
	titleLabel.text = titleStr;

	CGSize titleSize = [titleStr sizeForFont:DefaultFont20 size:CGSizeMake(screenWidth - 36 * 2 , MAXFLOAT) mode:NSLineBreakByWordWrapping];
	[titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(avatarImage.mas_bottom).offset(20.0);
		make.left.mas_equalTo(36.0);
		make.right.mas_equalTo(-36.0);
		make.height.mas_equalTo(ceil(titleSize.height));
	}];

	UITextView *detailLabel = [UITextView new];
	detailLabel.textColor = rgba(177, 177, 177, 1);
	detailLabel.tintColor = WeddingTimeBaseColor;
	detailLabel.font = DefaultFont12;
	detailLabel.delegate = self;
	detailLabel.scrollEnabled = NO;
	detailLabel.editable = NO;
	detailLabel.textAlignment = NSTextAlignmentLeft;
	detailLabel.dataDetectorTypes = UIDataDetectorTypeLink;
	[headerView addSubview:detailLabel];
	NSAttributedString *detail = [LWUtil returnAttributedStringWithHtml:[LWUtil getString:_postDetail.post_description andDefaultStr:@""]];
	detailLabel.text = detail.string ;

	CGSize descSize = [LWUtil textViewSizeWithTextView:detailLabel andWidth:(screenWidth - 30 * 2 - 16)];
	[detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(titleLabel.mas_bottom).offset(20.0);
		make.left.mas_equalTo(30.0);
		make.right.mas_equalTo(-30.0);
		make.height.mas_equalTo(ceil(descSize.height));
	}];

	UILabel *pricelabel = [UILabel new];
	pricelabel.font = DefaultFont14;
	pricelabel.textColor = WeddingTimeBaseColor;
	pricelabel.textAlignment = NSTextAlignmentCenter;
	[headerView addSubview:pricelabel];
	pricelabel.text = [LWUtil getString:_postDetail.price_range andDefaultStr:@""] ;
	pricelabel.hidden = _postDetail.is_admin;

	[pricelabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(detailLabel.mas_bottom).offset( _postDetail.is_admin ? 0 : 25.0);
		make.left.mas_equalTo(20.0);
		make.right.mas_equalTo(-20.0);
		make.height.mas_equalTo( _postDetail.is_admin ? 0 : kPriceHeight);
	}];

	UIButton *goMianBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	goMianBtn.titleLabel.font = DefaultFont14;
	goMianBtn.layer.borderWidth = 1.0;
	goMianBtn.layer.borderColor = rgba(170, 170, 170, 1).CGColor;
	[goMianBtn setTitleColor:rgba(153, 153, 153, 1) forState:UIControlStateNormal];
	[goMianBtn setTitle:@"查看主页" forState:UIControlStateNormal];
	[headerView addSubview:goMianBtn];
	[goMianBtn addTarget:self action:@selector(goSupplier) forControlEvents:UIControlEventTouchUpInside];
	[goMianBtn mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(pricelabel.mas_bottom).offset(25.0);
		make.centerX.equalTo(headerView);
		make.size.mas_equalTo(CGSizeMake(kMainBtnWidth, kMainBtnHeight));
	}];

	headerView.height = ceil(titleSize.height) + ceil(descSize.height) + ImageHeight + kPriceHeight + kMainBtnHeight + kAvatarHeight / 2.0 + kItemSpaces - (_postDetail.is_admin ? (kPriceHeight + 25) : 0) ;
	return headerView;
}

- (UIView *)getFooterView
{
    NSArray *destArray = _postDetail.sku;
    UIView *footerView;
    if (destArray.count > 0) {
        footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenHeight, (76 + 28 * destArray.count + 28) * Height_ato)];
    } else {
        footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
    
    for (int i = 0; i < destArray.count; i++) {
        NSDictionary *dic = destArray[i];
        UILabel *label = [UILabel new];
        label.font = [WeddingTimeAppInfoManager fontWithSize:14];
        [footerView addSubview:label];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = rgba(102, 102, 102, 1);
        NSString *str = [NSString stringWithFormat:@"%@: %@", dic[@"name"], dic[@"value"]];
        label.text = str;
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo((38 + 28 * i) * Height_ato);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(28 * Height_ato);
        }];
    }
	footerView.backgroundColor = [UIColor whiteColor];
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
