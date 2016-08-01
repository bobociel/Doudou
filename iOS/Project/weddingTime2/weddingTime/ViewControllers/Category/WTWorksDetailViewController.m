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
#import "WTBookingnViewController.h"
#import "WTWebViewViewController.h"
#import "webViewCellTableViewCell.h"
#import "SharePopView.h"
#import "GetService.h"
#import "WorksDetailCell.h"
#import "WTProgressHUD.h"
#import "YYTextView.h"
#define kTextViewGap 8.0
#define ImageHeight  (360 * Height_ato)
#define ImageWidth   screenWidth
@interface WTWorksDetailViewController ()
<
    UITableViewDataSource, UITableViewDelegate,BottomViewDelegate, YYTextViewDelegate
>
{
	UIImageView *tempImage;
	UIImageView *topImage;
}
@property (nonatomic, strong) BottomView *bottom;
@property (nonatomic, strong) WTSupplierPost *postDetail;
@property (nonatomic, strong) SharePopView   *shareView;
@end

@implementation WTWorksDetailViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationController.navigationBar.translucent = NO;
    [self initView];
    [self loadData];
}

- (void)initView
{
    self.view.backgroundColor = WHITE;
    self.dataTableView  =[[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) style:UITableViewStylePlain];
    self.dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.dataTableView.delegate = self;
    self.dataTableView.dataSource = self;
    [self.view addSubview:self.dataTableView];
    
    tempImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 571 * Height_ato)];
    tempImage.image = [UIImage imageNamed:@""];
    self.dataTableView.tableHeaderView = tempImage;
    [self showLoadingView];
    [self addTapButton];
}

- (void)initBottomView
{
	self.bottom = [[BottomView alloc] initWithFrame:CGRectMake(0, screenHeight - 60 * Height_ato, screenWidth, 60 * Height_ato)];
	_bottom.mainDelegate = self;
	[_bottom showFourButtons];
	self.bottom.is_like = _postDetail.is_like;
	self.bottom.supplier_id = _postDetail.supplier_user_id;
	self.bottom.name = _postDetail.supplier_company ;
	self.bottom.supplier_avatar = _postDetail.supplier_avatar;
	self.bottom.tel_num = [LWUtil getString:_postDetail.tel andDefaultStr:kServerPhone] ;
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
	[GetService getWorkDetailWithPostId:_works_id Block:^(NSDictionary *dic, NSError *error) {
		[self hideLoadingView];
		if (error) {
			[WTProgressHUD ShowTextHUD:@"服务器出现问题，请稍候再试" showInView:self.view afterDelay:1];
		}
		_postDetail = [WTSupplierPost modelWithDictionary:dic];
		if([LWUtil getString:_postDetail.video andDefaultStr:@""].length > 0)
		{
			[_postDetail.post_image insertObject:_postDetail.video atIndex:0];
		}
		[self initBottomView];
		self.dataTableView.tableHeaderView = [self getHeaderView];
		self.dataTableView.tableFooterView = [self getFooterView];
		[self.dataTableView reloadData];
	}];
}

#pragma mark - Action
- (void)tapButtonAction
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)shareAction
{
	self.shareView = [[SharePopView alloc] init];
	[self.shareView show];
	NSString *urlString = [NSString stringWithFormat:@"%@%@",kPostURL,_postDetail.post_id];
	_shareView.shareInfo = [SharePopViewInfo SharePopViewInfoWithTitle:_postDetail.post_title
														andDescription:_postDetail.post_description
															 andUrlStr:urlString
														   andImageURL:_postDetail.post_avatar];
}

- (void)goSupplier
{
	NSArray *VCS = self.navigationController.viewControllers;
	if(VCS.count > 1 && [VCS[VCS.count-2] isKindOfClass:[WTSupplierViewController class]]){
		[self.navigationController popViewControllerAnimated:YES];
	}else{
		WTSupplierViewController *supplierVC = [[WTSupplierViewController alloc] init];
		supplierVC.supplier_id = _postDetail.supplier_user_id ;
		[self.navigationController pushViewController:supplierVC animated:YES];
	}
}

#pragma mark - BottomViewDelegate
- (void)bottomViewConversationSelected
{
	[self conversationSelectType:WTConversationTypePost
					 supplier_id:_postDetail.supplier_user_id
				   sendToAskData:[_postDetail modelToJSONObject]
							name:_postDetail.post_title
						   phone:self.bottom.tel_num
						  avatar:_postDetail.supplier_avatar];
}

- (void)bottomViewLikeSelected:(BOOL)isLike
{
	_postDetail.is_like = isLike;
	if(_likeBlock){ self.likeBlock(isLike); }
}

- (void)bottomViewOrderSelected:(BottomView *)bottomView
{
	WTBookingnViewController *book = [[WTBookingnViewController alloc] init];
	book.supplier_id = _postDetail.supplier_user_id;
	book.work_id = self.works_id;
	book.image_url = _postDetail.supplier_avatar;
	book.name = _postDetail.supplier_company;
	book.location = _postDetail.city;
	book.cate = _postDetail.cate;
	[self.navigationController pushViewController:book animated:YES];
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

#pragma mark - YYTextViewDelegate
- (void)textView:(YYTextView *)textView didTapHighlight:(YYTextHighlight *)highlight inRange:(NSRange)characterRange rect:(CGRect)rect
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
}

#pragma mark - View
- (UIView *)getHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 571 * Height_ato)];
    topImage = [UIImageView new];
    [headerView addSubview:topImage];
    
    [topImage sd_setImageWithURL:[NSURL URLWithString:_postDetail.post_avatar] placeholderImage:[UIImage imageNamed:@"placelolder_detail"]];
    topImage.clipsToBounds = YES;
	[topImage setContentScaleFactor:[[UIScreen mainScreen] scale]];
    topImage.contentMode =  UIViewContentModeScaleAspectFill;
    topImage.frame = CGRectMake(0, 0, screenWidth, 360 * Height_ato);
    
    UIImageView *avatarImage = [UIImageView new];
	avatarImage.userInteractionEnabled = YES;
    [headerView addSubview:avatarImage];
    avatarImage.layer.borderColor = WHITE.CGColor;
    avatarImage.layer.borderWidth = 2;
    avatarImage.image = [UIImage imageNamed:_postDetail.supplier_avatar];
    [avatarImage sd_setImageWithURL:[NSURL URLWithString:_postDetail.supplier_avatar] placeholderImage:[UIImage imageNamed:@"supplier"]];
    avatarImage.layer.cornerRadius = 65 * Width_ato / 2.0;
    avatarImage.layer.masksToBounds = YES;
    [avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(327 * Height_ato);
        make.centerX.equalTo(headerView);
        make.size.mas_equalTo(CGSizeMake(65 * Width_ato, 65 * Width_ato));
    }];

	UITapGestureRecognizer *headerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goSupplier)];
	[avatarImage addGestureRecognizer:headerTap];

    UILabel *nameLabel = [UILabel new];
    nameLabel.numberOfLines = 0;
    nameLabel.font = [WeddingTimeAppInfoManager fontWithSize:16];
    nameLabel.textColor = rgba(60, 60, 60, 1);
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:nameLabel];
    NSString *str = [LWUtil getString:_postDetail.post_title andDefaultStr:@""];
    nameLabel.text = str;
    CGRect rect = [str boundingRectWithSize:CGSizeMake(screenWidth - 200 * Width_ato, 10000)
                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                 attributes:@{NSFontAttributeName:[WeddingTimeAppInfoManager fontWithSize:16]}
                                    context:nil];
    nameLabel.frame = CGRectMake(100 * Width_ato, 412 * Height_ato, screenWidth - 200 * Width_ato, ceil(rect.size.height) );

    UILabel *priceLabel = [UILabel new];
    priceLabel.textAlignment = NSTextAlignmentCenter;
    priceLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];
    NSString *price_str = [LWUtil getString:_postDetail.post_price andDefaultStr:@""];
    if (price_str.length > 0) {
        priceLabel.text = [NSString stringWithFormat:@"￥%@", price_str];
    } else {
        priceLabel.text = @"报价详询商家";
    }
    priceLabel.frame = CGRectMake(0, 422 * Height_ato + rect.size.height, screenWidth, 15);
    priceLabel.textColor = rgba(170, 170, 170, 1);
    [headerView addSubview:priceLabel];

    YYTextView *detailLabel = [YYTextView new];
    detailLabel.textColor = rgba(153, 153, 153, 1);
	detailLabel.tintColor = WeddingTimeBaseColor;
    detailLabel.font = [WeddingTimeAppInfoManager fontWithSize:14];
	detailLabel.delegate = self;
	detailLabel.scrollEnabled = NO;
	detailLabel.selectable = NO;
	detailLabel.editable = NO;
	detailLabel.dataDetectorTypes = UIDataDetectorTypeLink;

    NSAttributedString *detail = [LWUtil returnAttributedStringWithHtml:[LWUtil getString:_postDetail.post_description andDefaultStr:@""] ];
    NSString *tempStr = detail.string;
    CGFloat height;
    if ([tempStr isNotEmptyCtg])
	{
        detailLabel.text = tempStr;
		float textWidth = screenWidth - 32 * Width_ato - kTextViewGap * 2;
        CGRect rect1 = [tempStr boundingRectWithSize:CGSizeMake(textWidth, 10000)
											 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
										  attributes:@{NSFontAttributeName:[WeddingTimeAppInfoManager fontWithSize:14]}
											 context:nil];
        [headerView addSubview:detailLabel];
        detailLabel.frame = CGRectMake(16 * Width_ato, 422 * Height_ato + 15 + rect.size.height + 45 * Height_ato, screenWidth - 32 * Width_ato, ceil(rect1.size.height + kTextViewGap) );
        height = ( 422 + 50 +45) * Height_ato + 15 + ceil(rect.size.height) + ceil(rect1.size.height + kTextViewGap);
    }
    else
	{
		height = 15 + (422 + 50)* Height_ato +rect.size.height;
    }
    headerView.frame = CGRectMake(0, 0, screenWidth, height);
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
    return footerView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	CGFloat yOffset   = self.dataTableView.contentOffset.y;
	if (yOffset < 0)
	{
		CGFloat factor = ((ABS(yOffset)+ImageHeight)*ImageWidth)/ImageHeight;
		CGRect f = CGRectMake(-(factor-ImageWidth)/2, yOffset, factor, ImageHeight+ABS(yOffset));
		topImage.frame = f;
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
