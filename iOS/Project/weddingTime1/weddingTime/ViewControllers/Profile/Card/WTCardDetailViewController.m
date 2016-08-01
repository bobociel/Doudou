//
//  WTCardDetailViewController.m
//  weddingTime
//
//  Created by wangxiaobo on 16/3/11.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTCardDetailViewController.h"
#import "WTShopView.h"
#import "WTTopView.h"
#import "WTIntroduceCell.h"
#import "WTSKUCell.h"
#import "WTMenuCell.h"
#import "WTImageDetailCell.h"
#import "GetService.h"
#import "WTWeddingCard.h"
#define ImageWidth screenWidth
#define ImageHeight (350 * Height_ato)
#define kSKUCellHeight   125.0
#define kMenuHeadHeight  57.0
#define kMenuCellheight  40.0
@interface WTCardDetailViewController ()
<
    UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,
    WTTopViewDelegate,WTShopViewDelegate,WTIntroduceCellDelegate
>
@property (nonatomic,strong) WTShopView *shopView;
@property (nonatomic,strong) WTTopView *topView;
@property (nonatomic,strong) WTWeddingCard *card;
@property (nonatomic,strong) UIImageView *headImageView;
@property (nonatomic,copy) NSString *card_id;
@property (nonatomic,assign) BOOL isShowAll;
@end

@implementation WTCardDetailViewController

+ (instancetype)instanceWithCardId:(NSString *)cardID
{
	WTCardDetailViewController *VC = [[WTCardDetailViewController alloc] init];
	VC.card_id = cardID;
	return VC;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationController.navigationBar.translucent = YES;

	self.dataTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - kTabBarHeight) style:UITableViewStyleGrouped];
	self.dataTableView.backgroundColor = [UIColor clearColor];
	self.dataTableView.delegate = self;
	self.dataTableView.dataSource = self;
	self.dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:self.dataTableView];

	self.topView = [WTTopView topViewInView:self.view withType:@[@(WTTopViewTypeBack)]];
	self.topView.delegate = self;
	[self.view addSubview:self.topView];

	[self loadData];
}

- (void)loadData
{
	[self showLoadingView];
	[GetService getCardDetailWithCardID:_card_id callback:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		if(!error){
			_card = [WTWeddingCard modelWithJSON:result[@"data"]];
			[self.dataTableView reloadData];
			[self setupShopView];
		}else{
			[NetWorkingFailDoErr errWithView:self.dataTableView content:[LWAssistUtil getCodeMessage:error andDefaultStr:@""] tapBlock:^{
				[self loadData];
			}];
		}
	}];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)setupShopView
{
	[self.shopView removeFromSuperview];
	self.shopView = [WTShopView shopView:self.view];
	self.shopView.delegate = self;
	[self.shopView setPrice:_card.goods_price];
	[self.view addSubview:_shopView];
}

#pragma mark - ViewDelegate
- (void)topView:(WTTopView *)topView didSelectedBack:(UIControl *)backButton
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)shopView:(WTShopView *)shopView didSelectedBuy:(UIControl *)control
{
	TBURIParam *tbUriParam = [[TBURIParam alloc] initWithURI:kTaobaoURL(_card.taobao_id)];
	[[TBAppLinkSDK sharedInstance] jumpTBURI:tbUriParam];
}

- (void)WTIntroduceCell:(WTIntroduceCell *)cell didSelectedMore:(UIButton *)sender
{
	_isShowAll = !_isShowAll;
	[self.dataTableView reloadData];
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(section == WTCardCellTypeMenu){
		return _card.goods_package.count;
	}else if (section == WTCardCellTypeImage){
		return _card.goods_img.count;
	}
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section == WTCardCellTypeIntro)
	{
		WTIntroduceCell *cell = [tableView WTIntroduceCell];
		cell.delegate = self;
		cell.showAll = self.isShowAll;
		cell.card = _card;
		return cell;
	}
	else if(indexPath.section == WTCardCellTypeSKU)
	{
		WTSKUCell *cell = [tableView WTSKUCell];
		cell.card = _card;
		return cell;
	}
	else if(indexPath.section == WTCardCellTypeMenu)
	{
		WTMenuCell *cell = [tableView WTMenuCell];
		cell.cardExt = _card.goods_package[indexPath.row];
		return cell;
	}
	else if (indexPath.section == WTCardCellTypeImage)
	{
		WTImageDetailCell *cell = [tableView WTImageDetailCell];
		cell.cardImage = _card.goods_img[indexPath.row];
		return cell;
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section == WTCardCellTypeIntro){
		return [WTIntroduceCell getHeightWith:_card isShowAll:_isShowAll];
	}else if (indexPath.section == WTCardCellTypeSKU){
		return kSKUCellHeight;
	}else if (indexPath.section == WTCardCellTypeMenu){
		return kMenuCellheight;
	}else if(indexPath.section == WTCardCellTypeImage){
		return [WTImageDetailCell cellHeight:_card.goods_img[indexPath.row]];
	}
	return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0)];
	bgView.backgroundColor = WHITE;
	if(section == WTCardCellTypeIntro){
		self.headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, ImageHeight)];
		[self.headImageView setImageWithURL:[NSURL URLWithString:_card.main_pic] placeholder:nil];
		self.headImageView.clipsToBounds = YES;
		[bgView addSubview:_headImageView];
		bgView.frame = CGRectMake(0, 0, screenWidth, ImageHeight);
	}
	if (section == WTCardCellTypeMenu){
		UILabel *menuLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 33)];
		menuLabel.font = DefaultFont14;
		menuLabel.textColor = rgba(170, 170, 170, 1);
		menuLabel.text = @"套餐详情";
		UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - 20 - 100, 20, 100, 33)];
		priceLabel.textAlignment = NSTextAlignmentRight;
		priceLabel.font = DefaultFont14;
		priceLabel.textColor = rgba(170, 170, 170, 1);
		priceLabel.text = @"每套单价";
		[bgView addSubview:menuLabel];
		[bgView addSubview:priceLabel];
		bgView.clipsToBounds = YES;
		bgView.frame = CGRectMake(0, 0, screenWidth,  _card.goods_package.count > 0 ? kMenuHeadHeight : 0);
	}

	return bgView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if(section == WTCardCellTypeIntro){
		return ImageHeight;
	}
	if (section == WTCardCellTypeMenu){
		CGFloat cellHeight = _card.goods_package.count ? kMenuHeadHeight : 0.1;
		return cellHeight ;
	}
	return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 0.1;
}

#pragma mark - ScrollViewDelagte
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGFloat yOffset = self.dataTableView.contentOffset.y;
	if (yOffset < 0)
	{
		CGFloat factor = ((ABS(yOffset)+ImageHeight)*ImageWidth)/ImageHeight;
		CGRect f = CGRectMake(-(factor-ImageWidth)/2, yOffset, factor, ImageHeight+ABS(yOffset));
		self.headImageView.frame = f;
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
