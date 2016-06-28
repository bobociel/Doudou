//
//  WTCardListViewController.m
//  weddingTime
//
//  Created by wangxiaobo on 16/3/11.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTCardListViewController.h"
#import "WTCardDetailViewController.h"
#import "WTHomeViewController.h"
#import "PSCollectionView.h"
#import "WTWeddingCardCell.h"
#import "MJRefresh.h"
#import "GetService.h"
#define kPageSize 12
@interface WTCardListViewController () <PSCollectionViewDataSource,PSCollectionViewDelegate,WTWeddingCardCellDelegate>
@property (nonatomic,strong) PSCollectionView *dataCollectionView;
@property (nonatomic,strong) NSMutableArray *cards;
@end

@implementation WTCardListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"请柬商店";
	self.cards = [NSMutableArray array];

	self.dataCollectionView = [[PSCollectionView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - kNavBarHeight)];
	self.dataCollectionView.backgroundColor = [UIColor clearColor];
	self.dataCollectionView.collectionViewDelegate = self;
	self.dataCollectionView.collectionViewDataSource = self;
	self.dataCollectionView.margin = 0;
	self.dataCollectionView.numColsPortrait = 2;
	self.dataCollectionView.numColsLandscape = 3;
	[self.view addSubview:_dataCollectionView];
	[self.dataCollectionView reloadData];

	[self setRightBtnWithTitle:@"电子请柬"];

	[self loadData];
	self.dataTableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
		[self loadData];
	}];
}

- (void)loadData
{
	__block NSUInteger page = ceil(self.cards.count / kPageSize * 1.0) + 1;
	if(page == 1) { [self showLoadingView]; }
	[GetService getCardListWithPage:page callback:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		[NetWorkingFailDoErr removeAllErrorViewAtView:_dataCollectionView];
		if(!error){
			if(page == 0) { _cards = [NSMutableArray array]; }
			NSArray *cardArray = [NSArray modelArrayWithClass:[WTWeddingCard class] json:result[@"data"]];
			[_cards addObjectsFromArray:cardArray];
			[self.dataCollectionView reloadData];

			if (_cards.count == 0) {
				[NetWorkingFailDoErr errWithView:_dataCollectionView content:@"暂时没有数据哦" tapBlock:^{
					[self loadData];
				}];
			}
		}
		else
		{
			NSString * errorContent=[LWAssistUtil getCodeMessage:error defaultStr:nil noresultStr:nil];
			[WTProgressHUD ShowTextHUD:errorContent showInView:self.view];
			[NetWorkingFailDoErr errWithView:_dataCollectionView content:errorContent tapBlock:^{
				[self loadData];
			}];
		}
	}];
}

#pragma mark - Action
- (void)rightNavBtnEvent
{
	if([LWAssistUtil isLogin]){
		[self.navigationController pushViewController:[WTHomeViewController new] animated:YES];
	}
}

#pragma mark - PSCollectionView
- (NSInteger)numberOfViewsInCollectionView:(PSCollectionView *)collectionView {
	return self.cards.count ;
}

- (PSCollectionViewCell *)collectionView:(PSCollectionView *)collectionView viewAtIndex:(NSInteger)index
{
	WTWeddingCardCell *cell = [self.dataCollectionView WTWeddingCardCell];
	cell.delegate = self;
	cell.card = _cards[index];
	return cell;
}

- (CGFloat)heightForViewAtIndex:(NSInteger)index
{
	WTWeddingCard *card = self.cards[index];
	return [WTWeddingCardCell cellHeightWithCard:card];
}

-(void)cardCell:(WTWeddingCardCell *)cell didClick:(UIControl *)control
{
	WTWeddingCard *card = cell.card;
	[self.navigationController pushViewController:[WTCardDetailViewController instanceWithCardId:card.ID] animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

@end
