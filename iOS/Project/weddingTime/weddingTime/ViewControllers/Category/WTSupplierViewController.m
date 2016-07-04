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
#import "WTBookingnViewController.h"
#import "NetworkManager.h"
#import "SupplierDetailCell.h"
#import "GetService.h"
#import "CircleImage.h"
#import "MJRefresh.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"
#import "BottomView.h"
#import "SharePopView.h"
#import "WTProgressHUD.h"
#import "NetWorkingFailDoErr.h"
#import "UIImage+YYAdd.h"
#define kPageSize 5
#define ImageHeight (368 * Height_ato)
#define ImageWidth  screenWidth
#define kBgImageURLSuffix @"?imageView2/0/w/1104/h/1104"
@interface WTSupplierViewController ()<UITableViewDataSource, UITableViewDelegate,  BottomViewDelegate>
{
	UIImageView *tempheader;
	UIImageView *imageView;
	UIImageView *blurImage;
	UIImage *tempImage;
}
@property (nonatomic, strong) NSMutableArray *posts;
@property (nonatomic, strong) WTSupplier     *supplierDetail;
@property (nonatomic, strong) UITableView    *tableView;
@property (nonatomic, strong) BottomView     *bottom;
@property (nonatomic, strong) SharePopView   *shareView;
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
	self.view.backgroundColor = WHITE;
    self.navigationController.navigationBar.translucent = YES;
    [self.view addSubview:[[UIView alloc] initWithFrame:CGRectZero]];
	self.posts = [NSMutableArray array];
	[self initView];
	[self loadData];
}

- (void)initView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];

    [self initRefresh];
    [self showLoadingView];
    [self addTapButton];
}

- (void)initRefresh
{
	self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
		[self loadLocalData];
	}];
}

- (void)initBottomView
{
    self.bottom = [[BottomView alloc] initWithFrame:CGRectMake(0, screenHeight - 60 * Height_ato, screenWidth, 60 * Height_ato)];
    _bottom.mainDelegate = self;
	_bottom.is_like = _supplierDetail.is_like;
	_bottom.supplier_id = _supplier_id;
	_bottom.name = _supplierDetail.supplier_name;
	_bottom.supplier_avatar = _supplierDetail.supplier_avatar;
	_bottom.tel_num = [LWUtil getString:_supplierDetail.phone andDefaultStr:kServerPhone];
    [self.bottom showFourButtons];
    [self.view addSubview:_bottom];
}

- (void)addTapButton
{
	[super addTapButton];
	UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	shareButton.frame = CGRectMake(screenWidth - 50, 10, 30, 30);
	[shareButton setBackgroundImage:[UIImage imageNamed:@"homepage_invitecustom_white"] forState:UIControlStateNormal];
	[self.view addSubview:shareButton];
	[shareButton addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)loadData
{
	if (!_supplier_id) { _supplier_id = @"0"; }

	[GetService getSupplierDetailWithId:_supplier_id WithBlock:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
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
			tempheader = nil;
			_tableView.tableHeaderView = [self getHeaderView];
			[self loadLocalData];
			[self initBottomView];
		}
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
- (void)shareAction
{
	self.shareView = [[SharePopView alloc] init];
	[self.shareView show];
	NSString *urlString = [NSString stringWithFormat:@"%@%@",kSupplierURL,_supplier_id];
	_shareView.shareInfo = [SharePopViewInfo SharePopViewInfoWithTitle:_supplierDetail.supplier_name
														andDescription:_supplierDetail.supplier_description
															 andUrlStr:urlString
														   andImageURL:_supplierDetail.supplier_avatar];
}

#pragma mark - BottomViewDelegate
- (void)bottomViewConversationSelected
{
    [self conversationSelectType:WTConversationTypeSupplier
					 supplier_id:_supplier_id
				   sendToAskData:[_supplierDetail modelToJSONObject]
							name:_supplierDetail.supplier_name
						   phone:self.bottom.tel_num
						  avatar:_supplierDetail.supplier_avatar];
}

- (void)bottomViewLikeSelected:(BOOL)isLike
{
	_supplierDetail.is_like = isLike;
	if(_likeBlock) { self.likeBlock(isLike); }
}

- (void)bottomViewOrderSelected:(BottomView *)bottomView
{
	WTBookingnViewController *book = [[WTBookingnViewController alloc] init];
	book.supplier_id = _supplier_id;
	book.image_url = _supplierDetail.supplier_avatar;
	book.name = _supplierDetail.supplier_name;
	book.location = _supplierDetail.city;
	book.cate = _supplierDetail.service_type;
	[self.navigationController pushViewController:book animated:YES];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SupplierDetailCell *cell = [tableView supplerDetailCell];
    WTSupplierPost *post = _posts[indexPath.row];
	cell.post = post;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WTSupplierPost *post = _posts[indexPath.row];
    CGRect rect = [post.post_name boundingRectWithSize:CGSizeMake(screenWidth - 50, 10000)
										options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
									 attributes:@{NSFontAttributeName:[WeddingTimeAppInfoManager fontWithSize:18]}
										context:nil];
    return  (screenWidth / post.width * post.heigth)+37*Height_ato + rect.size.height + 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WTSupplierPost *post = _posts[indexPath.row];
    WTWorksDetailViewController *ban = [[WTWorksDetailViewController alloc] init];
    ban.works_id = post.post_id;
	[ban setLikeBlock:^(BOOL isLike){
		_supplierDetail.is_like = isLike;
		_bottom.is_like = isLike;
		if(_likeBlock){ self.likeBlock(isLike); }
	}];
    [self.navigationController pushViewController:ban animated:YES];
}

- (UIView *)getHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 490 * Height_ato)];
    
    blurImage = [UIImageView new];
	blurImage.clipsToBounds = YES;
	blurImage.contentMode = UIViewContentModeScaleAspectFill;
    [headerView addSubview:blurImage];
    
    NSString *backgroundStr = _supplierDetail.supplier_banner;
    if (![backgroundStr isNotEmptyCtg]) {
        backgroundStr = _supplierDetail.supplier_avatar;
    }
	backgroundStr = [backgroundStr stringByAppendingString:kBgImageURLSuffix];

    [blurImage sd_setImageWithURL:[NSURL URLWithString:backgroundStr] placeholderImage:[UIImage imageNamed:@""] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        tempImage = image;
        UIImage *blImage = [image imageByBlurRadius:13 tintColor:nil tintMode:0 saturation:1 maskImage:nil];
        blurImage.image = blImage;
    }];
    
    [blurImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0 * Height_ato);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(368 * Height_ato);
    }];

    CircleImage *avatarImage = [CircleImage new];
    [avatarImage.centerImage sd_setImageWithURL:[NSURL URLWithString:_supplierDetail.supplier_avatar] placeholderImage:[UIImage imageNamed:@"supplier"]];
    [headerView addSubview:avatarImage];
    [avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(120 * Height_ato);
        make.centerX.mas_equalTo(headerView);
        make.size.mas_equalTo(CGSizeMake(80 * Height_ato, 80 * Height_ato));
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = [LWUtil getString:_supplierDetail.supplier_name andDefaultStr:@""];
    titleLabel.textColor = WHITE;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:24];
    [headerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(240 * Height_ato);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(28 * Height_ato);
    }];
    UILabel *detailLabel = [UILabel new];
    detailLabel.textColor = WHITE;
    
    detailLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];
    detailLabel.textAlignment = NSTextAlignmentCenter;
    detailLabel.text = [NSString stringWithFormat:@"%@·%@·%.f人喜欢",  _supplierDetail.city, _supplierDetail.service_type, _supplierDetail.like_num];
    [headerView addSubview:detailLabel];
    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(284 * Height_ato);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(16);
    }];
    
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 368 * Height_ato, screenWidth, 122 * Height_ato)];
    whiteView.backgroundColor = WHITE;
    [headerView addSubview:whiteView];
    UILabel *worksLabel = [UILabel new];
    worksLabel.text = @"作品";
    worksLabel.textColor = rgba(102, 102, 102, 1);
    worksLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];
    [headerView addSubview:worksLabel];
    [worksLabel sizeToFit];
    worksLabel.textAlignment = NSTextAlignmentCenter;
    [worksLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(391 * Height_ato);
        make.left.mas_equalTo(70 * Width_ato);
        make.size.mas_equalTo(CGSizeMake(42 * Width_ato, 16));
    }];
    
    UILabel *commentLabel = [UILabel new];
    commentLabel.text = @"评论";
    commentLabel.textColor = rgba(102, 102, 102, 1);
    [headerView addSubview:commentLabel];
    commentLabel.textAlignment = NSTextAlignmentCenter;
    commentLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];
    
    [commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(391 * Height_ato);
        make.centerX.mas_equalTo(headerView);
        make.size.mas_equalTo(CGSizeMake(42 * Width_ato, 16 ));
    }];
    
    UILabel *priceLabel = [UILabel new];
    priceLabel.text = @"报价";
    priceLabel.textColor = rgba(102, 102, 102, 1);
    [headerView addSubview:priceLabel];
    priceLabel.textAlignment = NSTextAlignmentCenter;
    priceLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];
    
    [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(391 * Height_ato);
        make.right.mas_equalTo(-72 * Width_ato);
        make.size.mas_equalTo(CGSizeMake(42 * Width_ato, 16 ));
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(workButtonAction)];
    UILabel *workNum = [UILabel new];
    workNum.userInteractionEnabled = YES;
    [workNum addGestureRecognizer:tap];
    workNum.textColor = [[WeddingTimeAppInfoManager instance] baseColor];
    workNum.font = [UIFont systemFontOfSize:26];
    workNum.textAlignment = NSTextAlignmentCenter;
    workNum.text = [NSString stringWithFormat:@"%.f",_supplierDetail.supplier_post_num];
    [headerView addSubview:workNum];
    [workNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(417 * Height_ato);
        make.left.mas_equalTo(50 * Width_ato);
        make.size.mas_equalTo(CGSizeMake(84 * Width_ato, 34 * Width_ato));
    }];

    UILabel *commentNum = [UILabel new];
    commentNum.textColor = [[WeddingTimeAppInfoManager instance] baseColor];
    commentNum.font = [UIFont systemFontOfSize:26];
    commentNum.textAlignment = NSTextAlignmentCenter;
    commentNum.text = [NSString stringWithFormat:@"%.f",_supplierDetail.comment_num];
    [headerView addSubview:commentNum];
    [commentNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(417 * Height_ato);
        make.centerX.mas_equalTo(headerView);
        make.size.mas_equalTo(CGSizeMake(70 * Width_ato, 34 * Height_ato));
    }];

    UILabel *priceNum = [UILabel new];
	priceNum.textColor = [[WeddingTimeAppInfoManager instance] baseColor];
	priceNum.font = [UIFont systemFontOfSize:26];
    priceNum.textAlignment = NSTextAlignmentRight;

	NSString *price_num = [LWUtil getString:_supplierDetail.start_price andDefaultStr:@"0"];
	priceNum.text = price_num;
    int width = 100;
    int rightWidth = 53;
    if (price_num.intValue < 10000) {
        rightWidth = 64;
    }
    if (price_num.intValue < 1000) {
        priceNum.textAlignment = NSTextAlignmentCenter;
        width = 44;
        rightWidth = 67;
    }
	[headerView addSubview:priceNum];
    [priceNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(417 * Height_ato);
        make.right.mas_equalTo(-rightWidth * Width_ato);
        make.size.mas_equalTo(CGSizeMake(width * Width_ato + 10, 34 * Height_ato));
    }];
    UILabel *qiLabel = [UILabel new];
    qiLabel.text = @"起";
    qiLabel.font = [WeddingTimeAppInfoManager fontWithSize:12];
    qiLabel.textColor = rgba(153, 153, 153, 1);
    [headerView addSubview:qiLabel];
    [qiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(432 * Height_ato);
        make.right.mas_equalTo(-(rightWidth - 18) * Width_ato);
        make.size.mas_equalTo(CGSizeMake(14,14));
    }];
    
    UIView *shadowView = [UIView new];
    shadowView.backgroundColor = rgba(230, 230, 230, 1);
    [headerView addSubview:shadowView];
    [shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(490 * Height_ato);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(5 * Height_ato);
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
