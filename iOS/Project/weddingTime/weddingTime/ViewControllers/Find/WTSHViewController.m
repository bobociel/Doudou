//
//  SHViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/29.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTSHViewController.h"
#import "WTSupplierViewController.h"
#import "WTHotelViewController.h"
#import "WTWorksDetailViewController.h"
#import "WTBudgetViewController.h"
#import "WTSHTableViewCell.h"
#import "WTWeddingShopCell.h"
#import "CommAnimationPresent.h"
#import "NetWorkingFailDoErr.h"
#import "WTTopView.h"
#import "BottomBudgetView.h"
#import "GetService.h"
#import "MJRefresh.h"
#import "WTProgressHUD.h"
#import "UserInfoManager.h"
@interface WTSHViewController ()
<
    UITableViewDataSource, UITableViewDelegate,UIScrollViewDelegate,
    WTTopViewDelegate,BottomBudgetViewDelegate
>
@property (nonatomic, strong) WTTopView *topView;
@property (nonatomic, strong) BottomBudgetView *bottomView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger subPage;

@property (nonatomic, strong) WTHotelFilters *filters;
@property (nonatomic, copy) NSString *syn_id;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, assign) BOOL isFromSearch;
@property (nonatomic, assign) BOOL isFilter;
@property (nonatomic, assign) CGFloat preContentOffsetY;
@end

@implementation WTSHViewController
{
    NSNumber *city_id;
    //以下search专用
    NSString *qStr;
    BOOL ifBottom;
}
@synthesize page;

- (void)viewDidLoad {
    [super viewDidLoad];
    page = 1;
    city_id = @([UserInfoManager instance].curCityId);

	self.array = [NSMutableArray array];
    [self initView];

    if (!self.isFromSearch && !_isFilter) {
        [self loadDataWithBlock:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[self.navigationController setNavigationBarHidden:!self.isFromSearch animated:YES];
	[_bottomView setCate:_supplier_type];
}

- (void)bottomBudgetViewBudgetSelected
{
	WTBudgetViewController *budgetVC = [WTBudgetViewController new];
	[budgetVC setRefreshBlock:^(BOOL refresh) {
		page = 1;
		self.array = [NSMutableArray array];
		[self loadDataWithBlock:nil];
	}];
	[self.navigationController pushViewController:budgetVC animated:YES];
}

- (void)loadDataWithBlock:(void(^)())ontopblcok
{
    if(self.isFromSearch){ [self loadSearchData:ontopblcok]; return;}

	_price = [UserInfoManager instance].budgetInfo[@(_supplier_type).stringValue] ? : @"0";
    city_id = city_id ? : @(0);
    
    if (page<=1) {
        if ([self.array count] == 0) {
            [self showLoadingView];
        }
    }
    if (WTWeddingTypeHotel == _supplier_type && _segmentType == WTSegmentTypeSupplier) {
        [GetService getHotelListWithPage:page andHotelListFilters:self.filters WithBlock:^(NSDictionary *result, NSError *error) {
            [self hideLoadingView];
            [self.tableView.footer endRefreshing];
            [self.tableView.header endRefreshing];
            [self doFinishLoadData:result error:error ontopblcok:ontopblcok];
			[PostDataService postAccessLogWithServiceID:_supplier_type andCityID:nil andID:nil andLogType:WTLogTypeNone];
        }];
    } else if(WTWeddingTypeHotel != _supplier_type && _segmentType == WTSegmentTypeSupplier) {
		[GetService getSupplierListWithSupplierType:_supplier_type page:page subpage:_subPage cityID:city_id synID:_syn_id Block:^(NSDictionary *result, NSError *error) {
            [self hideLoadingView];
            [self.tableView.footer endRefreshing];
            [self.tableView.header endRefreshing];
            [self doFinishLoadData:result error:error ontopblcok:ontopblcok];
			[PostDataService postAccessLogWithServiceID:_supplier_type andCityID:nil andID:nil andLogType:WTLogTypeNone];
        }];
    }else{
		[GetService getPostListWithSupplierType:_supplier_type page:page subpage:_subPage cityID:city_id synID:_syn_id price:_price Block:^(NSDictionary *result, NSError *error) {
			[self hideLoadingView];
			[self.tableView.footer endRefreshing];
			[self.tableView.header endRefreshing];
			[self doFinishLoadData:result error:error ontopblcok:ontopblcok];
		}];
    }
}

- (void)loadSearchData:(void(^)())ontopblcok {
    WS(ws);
    if (![qStr isNotEmptyCtg]) {
        return;
    }

    if (page <= 1) {
        if ([self.array count] == 0) {
            [NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];
            [self errWithView:self.tableView content:@"搜索中..." tapBlock:^{
            }];
        }
    }
    if (WTWeddingTypeHotel == _supplier_type && _segmentType == WTSegmentTypeSupplier){
        [GetService getSearchHotelWithPage:page andQ:qStr WithBlock:^(NSDictionary *result, NSError *error) {
            [NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];
            [self.tableView.footer endRefreshing];
            [self.tableView.header endRefreshing];
            [ws doSearchData:result error:error ontopblcok:ontopblcok];
        }];
    }else if(WTWeddingTypeHotel != _supplier_type && _segmentType == WTSegmentTypeSupplier) {
        [GetService getSearchSupplierWithPage:page andQ:qStr WithBlock:^(NSDictionary *result, NSError *error) {
            [NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];
            [self.tableView.footer endRefreshing];
            [self.tableView.header endRefreshing];
            [ws doSearchData:result error:error ontopblcok:ontopblcok];
        }];
    }else{

    }
}

-(void)beginSearchWithKwyWord:(NSString*)key
{
    qStr=key;
    _isFromSearch = YES;
	[self.array removeAllObjects];
	[self.tableView reloadData];
	page = 1;
    [self loadDataWithBlock:^{
    }];
}

- (void)filterDataWithSType:(WTWeddingType)type
					segType:(WTSegmentType)segType
                      synID:(NSString *)synID
                    filters:(WTHotelFilters *)filters
{
	_segmentType = segType;
	_supplier_type = type;
    page = 1;
    _isFilter = YES;
    _filters = filters;
    _syn_id = synID;
    self.array = [NSMutableArray array];
    [self loadDataWithBlock:nil];
}

-(void)doFinishLoadData:(NSDictionary*)result error:(NSError *)error ontopblcok:(void(^)())ontopblcok
{
	[NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];
    if(error)
    {
        NSString *errorContent=[LWAssistUtil getCodeMessage:error andDefaultStr:@""];
        [self errWithView:self.tableView content:errorContent tapBlock:^{
             [self loadDataWithBlock:nil];
        }];
    }
    else
    {
		Class dataClass = [NSObject class];
		NSArray *resultArray;
		if(_segmentType != WTSegmentTypePost){
			dataClass = _supplier_type == WTWeddingTypeHotel ? [WTHotel class] : [WTSupplier class];
				resultArray = _supplier_type == WTWeddingTypeHotel ? result[@"data"] : result[@"data"][@"supplier_list"];
		}else{
			dataClass = [WTSupplierPost class];
			resultArray = result[@"data"][@"post_list"];
		}

        NSArray *dataArray = [NSArray modelArrayWithClass:dataClass json:resultArray];
        [self.array addObjectsFromArray:dataArray];
        [self.tableView reloadData];
		if(self.array.count == 0 && page == 1){
			[self errWithView:self.tableView content:@"没有结果哦" tapBlock:nil];
		}

		if(_supplier_type == WTWeddingTypeHotel){
			page ++;
		}else{
			page = [result[@"data"][@"page"] integerValue];
			_subPage = [result[@"data"][@"sub_page"] integerValue];
			NSInteger count = [result[@"data"][@"count"] integerValue];

			BOOL isEnd = _subPage != 0 && count<(_segmentType == WTSegmentTypePost ? 12 : 15);
			self.tableView.footer.hidden = isEnd;
		}
    }
    if(ontopblcok ) { ontopblcok(); }
}

-(void)doSearchData:(NSDictionary*)result error:(NSError *)error ontopblcok:(void(^)())ontopblcok
{
	[NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];
	if(!error)
	{
		Class dataClass = [NSObject class];
		NSArray *resultArray = result[@"data"];
		if(_segmentType != WTSegmentTypePost){
			dataClass = _supplier_type == WTWeddingTypeHotel ? [WTHotel class] : [WTSupplier class];
		}else{
			dataClass = [WTSupplierPost class];
		}

		NSArray *dataArray = [NSArray modelArrayWithClass:dataClass json:resultArray];
		[self.array addObjectsFromArray:dataArray];
		[self.tableView reloadData];
		if(self.array.count == 0 && page == 1){
			[self errWithView:self.tableView content:@"没有结果哦" tapBlock:nil];
		}

		page ++;
	}

	if(ontopblcok ) { ontopblcok(); }
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.row >= _array.count) { return nil; }

	if(WTWeddingTypeHotel == _supplier_type && _segmentType == WTSegmentTypeSupplier)
	{
		WTHotel *hotel = _array[indexPath.row];
		WTSHTableViewCell *cell = [tableView WTSHTableViewCell];
		cell.supplier_type = self.supplier_type;
		[cell setHotel:hotel];
		return cell;
	}
	else if((WTWeddingTypeHotel != _supplier_type && _segmentType == WTSegmentTypeSupplier))
	{
		WTSupplier *supplier = _array[indexPath.row];
		WTSHTableViewCell *cell = [tableView WTSHTableViewCell];
		cell.supplier_type = self.supplier_type;
		[cell setSupplier:supplier];
		return cell;
	}
	else
	{
		WTSupplierPost *post = _array[indexPath.row];
		WTWeddingShopCell *cell = [tableView WTWeddingShopCell];
		cell.post = post;
		return cell;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 300 * Height_ato  + (_segmentType == WTSegmentTypePost ? 125 : 98);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.row >= _array.count) {return ;};

	if (_supplier_type == WTWeddingTypeHotel && _segmentType == WTSegmentTypeSupplier) {
		__block WTHotel *hotel = _array[indexPath.row];
		WTHotelViewController *hotelVC = [[WTHotelViewController alloc] init];
		hotelVC.hotel_id = hotel.ID;
		[hotelVC setLikeBlock:^(BOOL isLike){
			hotel.is_like = isLike;
			hotel.likeCount += isLike ? 1 : -1 ;
			[self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
		}];
		[self.navigationController pushViewController:hotelVC animated:YES];
	} else if((_supplier_type != WTWeddingTypeHotel && _segmentType == WTSegmentTypeSupplier)){
		WTSupplier *supplier = _array[indexPath.row];
		WTSupplierViewController *supplierVC = [[WTSupplierViewController alloc] init];
		supplierVC.supplier_id = supplier.supplier_user_id;
		[supplierVC setLikeBlock:^(BOOL isLike){
			supplier.is_like = isLike;
			supplier.likeCount += isLike ? 1 : -1 ;
			[self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
		}];
		[self.navigationController pushViewController:supplierVC animated:YES];
	}else{
		WTSupplierPost *post = _array[indexPath.row];
		[self.navigationController pushViewController:[WTWorksDetailViewController instanceWTWorksDetailVCWithWrokID:post.ID] animated:YES];
	}
}

#pragma mark - View
-(void)errWithView:(UIView*)view content:(NSString*)content tapBlock:(NetWorkingFailDoErrTouchBlock)block
{
	if (self.isFromSearch) {
		UIFont *font = DefaultFont16;
		[NetWorkingFailDoErr errWithView:view frame:CGRectMake(0, 0, screenWidth, 160) backColor:defaultLineColor font:font textColor:[UIColor whiteColor] content:content tapBlock:block];
	}
	else
	{
		[NetWorkingFailDoErr errWithView:view content:content tapBlock:block];
	}
}

- (void)initView
{
	CGFloat tableViewHeight = _isFromSearch ? (screenHeight - kNavBarHeight) : screenHeight;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, tableViewHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.keyboardDismissMode=UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:_tableView];

	_bottomView = [BottomBudgetView bootomViewInView:self.view];
	_bottomView.mainDelegate = self;
	if(!_isFromSearch){
		[self.view addSubview:_bottomView];
	}

	self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
		[self loadDataWithBlock:nil];
	}];

	self.tableView.header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
		page = 1;
		_subPage = 0;
		_array = [NSMutableArray array];
		[self loadDataWithBlock:nil];
	}];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGFloat bottomViewY = _isFromSearch ? screenHeight : (screenHeight - kBottomViewHeight);
	if([scrollView isEqual:_tableView]){
		CGFloat offset = scrollView.contentOffset.y - _preContentOffsetY;
		CGRect bottomViewFrame = _bottomView.frame;
		if(scrollView.contentOffset.y < 0){ return; }

		bottomViewFrame.origin.y += offset;
		bottomViewFrame.origin.y = MIN(bottomViewFrame.origin.y, screenHeight);
		bottomViewFrame.origin.y = MAX(bottomViewFrame.origin.y, bottomViewY);
		_bottomView.frame = bottomViewFrame;

		_preContentOffsetY = scrollView.contentOffset.y;
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	CGFloat bottomViewY = _isFromSearch ? screenHeight : (screenHeight - kBottomViewHeight);
	[UIView animateWithDuration:0.35 animations:^{
		_bottomView.frame = CGRectMake(0, bottomViewY, screenWidth, kBottomViewHeight);
	}];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

@end
