//
//  SHViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/29.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTSHViewController.h"
#import "GetService.h"
#import "CommonTableViewCell.h"
#import "WTSupplierViewController.h"
#import "WTHotelViewController.h"
#import "MJRefresh.h"
#import "WTProgressHUD.h"
#import "WTFilterCityViewController.h"
#import "WTFilterHotelViewController.h"
#import "CommAnimationPresent.h"
#import "NetWorkingFailDoErr.h"
#import "BottomView.h"
#import "UserInfoManager.h"
#import "WTSearchViewController.h"
@interface WTSHViewController ()<UITableViewDataSource, UITableViewDelegate, FilterSelectDelegate, SynFilterSelectDelegate, SearchScreeningContentViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) HotelOrSupplierListFilters *filters;
@end

@implementation WTSHViewController
{
    int loadType;
    int page;
    NSNumber *city_id;
    NSString *syn_id;
    NSIndexPath *curIndex;
    NSIndexPath *cityIndex;
    NSArray *synArray;

    //以下search专用
    NSString *qStr;
    BOOL ifBottom;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

-(void)setNavWithHidden
{
    if (!self.isFromSearch) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    page = 1;
    city_id = @([UserInfoManager instance].curCityId);
    syn_id  = syn_id  ? : (_supplier_type == WTWeddingTypeHotel) ? @"normal" : @"score";

    self.filters = [HotelOrSupplierListFilters defaultFilters];
    self.filters.city_id = city_id.intValue;
    self.filters.isFromFilters = YES;
	self.array = [NSMutableArray array];
    [self initView];
    [self initsynArray];
    [self initRefresh];
    
    if (!self.isFromSearch) {
        [self loadDataWithBlock:nil];
    }
}

- (void)initsynArray
{
	synArray = [@[@{@"id" : @"score",   @"name" : @"综合排序"},
				  @{@"id" : @"like_num",@"name" : @"按喜欢"},
				  @{@"id" : @"score",   @"name" : @"按评价"},
				  @{@"id" : @"post_num",@"name" : @"按作品"}] mutableCopy];
}

-(void)beginSearchWithKwyWord:(NSString*)key
{
    qStr=key;
    [self resetAll];
    [self loadDataWithBlock:^{
    }];
}

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

-(void)doFinishLoadData:(NSDictionary*)result error:(NSError *)error ontopblcok:(void(^)())ontopblcok
{
    if(error)
    {
        NSString *errorContent=[LWAssistUtil getCodeMessage:error andDefaultStr:@""];
        [self errWithView:self.tableView content:errorContent tapBlock:^{
             [self loadDataWithBlock:nil];
        }];
    }
    else
    {
        [NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];
        NSArray *dataArray = [NSArray modelArrayWithClass:_supplier_type == WTWeddingTypeHotel ? [WTHotel class] : [WTSupplier class] json:result[@"data"]];
        [self.array addObjectsFromArray:dataArray];
        [self.tableView reloadData];
		if(self.array.count == 0 && page == 1)
		{
			[self errWithView:self.tableView content:@"没有结果哦" tapBlock:nil];
		}
        page ++;
    }
    if(ontopblcok ) { ontopblcok(); }
}

- (void)loadSearchData:(void(^)())ontopblcok {
    WS(ws);
    if (![qStr isNotEmptyCtg]) {
        return;
    }
    if (page <= 1) {
        if ([self.array count]==0) {
            [NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];
            [self errWithView:self.tableView content:@"搜索中..." tapBlock:^{
            }];
        }
    }
    if (self.supplier_type == WTWeddingTypeHotel){
        [GetService getSearchHotelWithPage:page andQ:qStr WithBlock:^(NSDictionary *result, NSError *error) {
            [NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];
            [self.tableView.footer endRefreshing];
            [self.tableView.header endRefreshing];
            [ws doFinishLoadData:result error:error ontopblcok:ontopblcok];
        }];
    }else {
        [GetService getSearchSupplierWithPage:page andQ:qStr WithBlock:^(NSDictionary *result, NSError *error) {
            [NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];
            [self.tableView.footer endRefreshing];
            [self.tableView.header endRefreshing];
            [ws doFinishLoadData:result error:error ontopblcok:ontopblcok];
        }];
        
    }
}

- (void)resetAll {
    [self.array removeAllObjects];
    [self.tableView reloadData];
    page          = 1;
}

- (void)didChooseScreening:(HotelOrSupplierListFilters *)filters
{
    page = 1;
    self.array = [NSMutableArray array];
    
    self.filters = filters;
    self.filters.isFromFilters = YES;
    [self loadDataWithBlock:^{
        if (_array.count > 0) {
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]  atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }];
}

- (void)filterHasSelectWithInfo:(id)info index:(NSIndexPath *)index
{
    WS(ws);
    cityIndex = index;
    city_id = info;
    self.array = [NSMutableArray array];
    self.filters.isFromFilters = YES;
    self.filters.city_id = city_id.intValue;
    page = 1;
    [self loadDataWithBlock:^{
        if (ws.array.count > 0) {
            [ws.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]  atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        
    }];
}

- (void)synFilterHasSelectWithInfo:(id)info index:(NSIndexPath *)index
{
    WS(ws);
    syn_id = info;
    page = 1;
    NSDictionary *dic = synArray[index.row];
    curIndex = index;
    syn_id = dic[@"id"];
    page = 0;
    self.array = [NSMutableArray array];
    curIndex = index;
    syn_id = dic[@"id"];
    page = 1;
    [self loadDataWithBlock:^{
        if (ws.array.count > 0) {
            [ws.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]  atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        
    }];
    
}

- (void)initView
{
    [self.view addSubview:[[UIView alloc] initWithFrame:CGRectZero]];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.keyboardDismissMode=UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:_tableView];
    
    if (!self.isFromSearch) {
        [self addTapButton];
    }
}

- (void)addTapButton
{
    [super addTapButton];
    UIButton *synFilter = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 20* Width_ato - 32  * 3, 32 * Height_ato, 32 * Width_ato, 32 * Width_ato)];
    [synFilter setBackgroundImage:[UIImage imageNamed:@"synFilter"] forState:UIControlStateNormal];
    [synFilter setBackgroundImage:[UIImage imageNamed:@"synFilter_select"] forState:UIControlStateHighlighted];

	
    [self.view addSubview:synFilter];
    UIButton *synFilter_big = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth -60 * Width_ato - 32  * 3, 12 * Height_ato, 72  , 72 * Height_ato)];
    [synFilter_big addTarget:self action:@selector(synFilterAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:synFilter_big];
    
    UIButton *filter = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 15* Width_ato - 32 * 2, 32 * Height_ato, 32 * Width_ato, 32 * Width_ato)];
    [filter setBackgroundImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
    [filter setBackgroundImage:[UIImage imageNamed:@"filter_select"] forState:UIControlStateHighlighted];
    [self.view addSubview:filter];
    
    UIButton *filter_big= [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 15 * Width_ato - 32 * 2, 12 * Height_ato, 32 , 72 * Height_ato)];
    [self.view addSubview:filter_big];
    [filter_big addTarget:self action:@selector(filterAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *search = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 10* Width_ato - 32 * Width_ato, 32 * Height_ato, 32 * Width_ato , 32 * Width_ato)];
    [search setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [search setBackgroundImage:[UIImage imageNamed:@"search_select"] forState:UIControlStateHighlighted];
    [self.view addSubview:search];
    
    
    UIButton *search_big = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 10* Width_ato - 32 * Width_ato, 12 * Height_ato, 32 , 72 * Width_ato)];
    [self.view addSubview:search_big];
    [search_big addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)filterAction
{
    WTFilterCityViewController *filter = [[WTFilterCityViewController alloc] init];
    filter.delegate = self;
    filter.type = 1;
    filter.index = cityIndex;
    [self.navigationController presentViewController:filter animated:YES completion:nil];
}

- (void)synFilterAction
{
    if (self.supplier_type == WTWeddingTypeHotel) {
        WTFilterHotelViewController *hotelFilter = [[WTFilterHotelViewController alloc] init];
        hotelFilter.delegate = self;
        hotelFilter.filters = self.filters;
        [self.navigationController presentViewController:hotelFilter animated:YES completion:nil];
    } else {
        WTFilterCityViewController *synFilter = [[WTFilterCityViewController alloc] init];
        synFilter.synDelegate = self;
        synFilter.type = 2;
        synFilter.index = curIndex;
        [self.navigationController presentViewController:synFilter animated:YES completion:nil];
    }
}

- (void)searchAction
{
    WTSearchViewController *search = [[WTSearchViewController alloc] init];
    search.curSearchType =  (self.supplier_type == WTWeddingTypeHotel) ? SearchTypeHotel : SearchTypeSupplier;
    [self.navigationController pushViewController:search animated:YES];
}

- (void)initRefresh
{
    WS(ws);
    __weak UIScrollView *scrollView = self.tableView;
    scrollView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [ws loadDataWithBlock:nil];
    }];
    
    scrollView.header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
        page = 1;
		_array = [NSMutableArray array];
        [ws loadDataWithBlock:nil];
    }];
}

- (void)loadDataWithBlock:(void(^)())ontopblcok
{
    if(self.isFromSearch)
    {
        [self loadSearchData:ontopblcok];
        return;
    }
    
    city_id = city_id ? : @(0);
    syn_id  = syn_id  ? : (_supplier_type == WTWeddingTypeHotel) ? @"normal" : @"score";
    
    if (page<=1) {
        if ([self.array count] == 0) {
            [self showLoadingView];
        }
    }
    if (self.supplier_type == WTWeddingTypeHotel) {
        [GetService getHotelListWithPage:page andHotelListFilters:self.filters WithBlock:^(NSDictionary *result, NSError *error) {
            [self hideLoadingView];
            [self.tableView.footer endRefreshing];
            [self.tableView.header endRefreshing];
            [self doFinishLoadData:result error:error ontopblcok:ontopblcok];
        }];
    } else {
        [GetService getSupplierListWithSupplier_type:_supplier_type page_no:page city_id:city_id syn_id:syn_id Block:^(NSDictionary *result, NSError *error) {
            [self hideLoadingView];
            [self.tableView.footer endRefreshing];
            [self.tableView.header endRefreshing];
            [self doFinishLoadData:result error:error ontopblcok:ontopblcok];
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.row >= _array.count) { return nil; }
    
    if(WTWeddingTypeHotel == _supplier_type)
    {
        WTHotel *hotel = _array[indexPath.row];
        CommonTableViewCell *cell = [tableView commonCell];
        cell.supplier_type = self.supplier_type;
        [cell setHotel:hotel];
        return cell;
    }
    else
    {
        WTSupplier *supplier = _array[indexPath.row];
        CommonTableViewCell *cell = [tableView commonCell];
        cell.supplier_type = self.supplier_type;
        [cell setSupplier:supplier];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 415 * Height_ato;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.row >= _array.count) {return ;};
    
    if (_supplier_type == WTWeddingTypeHotel) {
        __block WTHotel *hotel = _array[indexPath.row];
        WTHotelViewController *hotelVC = [[WTHotelViewController alloc] init];
        hotelVC.hotel_id = hotel.ID;
		[hotelVC setLikeBlock:^(BOOL isLike){
			hotel.is_like = isLike;
			hotel.likeCount += isLike ? 1 : -1 ;
			[self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
		}];
        [self.navigationController pushViewController:hotelVC animated:YES];
    } else {
        WTSupplier *supplier = _array[indexPath.row];
        WTSupplierViewController *supplierVC = [[WTSupplierViewController alloc] init];
        supplierVC.supplier_id = supplier.supplier_user_id;
		[supplierVC setLikeBlock:^(BOOL isLike){
			supplier.is_like = isLike;
			supplier.likeCount += isLike ? 1 : -1 ;
			[self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
		}];
        [self.navigationController pushViewController:supplierVC animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

@end
