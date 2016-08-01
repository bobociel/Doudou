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
@interface WTSHViewController ()<UITableViewDataSource, UITableViewDelegate, FilterSelectDelegate, SynFilterSelectDelegate, SearchScreeningContentViewDelegate, CancelLikeDelegate>

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

- (void)bottomViewAction
{
    page--;
    ifBottom = YES;
    [self loadDataWithBlock:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    page = 1;
    city_id = @([UserInfoManager instance].curCityId);
    if (_listType == supplier_type) {
        syn_id = @"score";
    } else {
        syn_id = @"normal";
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bottomViewAction) name:BOTTOMVIEWNOTIFY object:nil];
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
        UIFont *font=defaultFont16;
        [NetWorkingFailDoErr errWithView:view frame:CGRectMake(0, 0, screenWidth, 160) backColor:defaultLineColor font:font textColor:[UIColor whiteColor] content:content tapBlock:block];
    }
    else
    {
        [NetWorkingFailDoErr errWithView:view content:content tapBlock:block];
    }
}

-(void)doFinishLoadData:(NSDictionary*)result error:(NSError *)error ontopblcok:(void(^)())ontopblcok
{
    if (error) {
        NSString *errorContent=[LWAssistUtil getCodeMessage:error andDefaultStr:@""];
        [self errWithView:self.tableView content:errorContent tapBlock:^{
             [self loadDataWithBlock:nil];
        }];
    }
    else
    {
        [NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];

        [self.array addObjectsFromArray:[result[@"data"] mutableCopy] ];
        if (self.array.count == 0) {
            if (page == 1) {
                [self errWithView:self.tableView content:@"没有结果哦" tapBlock:^{
                }];
            }
        }
        
        [self.tableView reloadData];
        page++;
    }
    if(ontopblcok!=nil) {
        ontopblcok();
    }
}

- (void)loadSearchData:(void(^)())ontopblcok {
    WS(ws);
    if (![qStr isNotEmptyCtg]) {
        return;
    }
    if (page<=1) {
        if ([self.array count]==0) {
            [NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];
            [self errWithView:self.tableView content:@"搜索中..." tapBlock:^{
            }];
        }
    }
    if (self.listType==hotel_type) {
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
    // NSDictionary *dic = synArray[index.row];
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
    [self.view addSubview:[UIView new]];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.keyboardDismissMode=UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:_tableView];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
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
    //    [filter addTarget:self action:@selector(filterAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:filter];
    
    UIButton *filter_big= [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 15 * Width_ato - 32 * 2, 12 * Height_ato, 32 , 72 * Height_ato)];
    [self.view addSubview:filter_big];
    [filter_big addTarget:self action:@selector(filterAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *search = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 10* Width_ato - 32 * Width_ato, 32 * Height_ato, 32 * Width_ato , 32 * Width_ato)];
    [search setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [search setBackgroundImage:[UIImage imageNamed:@"search_select"] forState:UIControlStateHighlighted];
    //    [search addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
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
    if (self.listType == hotel_type) {
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
    if (self.listType == supplier_type) {
        search.curSearchType = SearchTypeSupplier;
    } else {
        search.curSearchType = SearchTypeHotel;
    }
    
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
    
    if (!city_id) {
        city_id = @(0);
    }
    if (!syn_id) {
        if (_listType == supplier_type) {
            syn_id = @"score";
        } else {
            syn_id = @"normal";
        }
    }
    if (page<=1) {
        if ([self.array count]==0) {
            [self showLoadingView];
        }
    }
    if (self.listType == supplier_type) {
        [GetService getSupplierListWithSupplier_id:_supplier_type page_no:page city_id:city_id syn_id:syn_id Block:^(NSDictionary *result, NSError *error) {
            [self hideLoadingView];
            [self.tableView.footer endRefreshing];
            [self.tableView.header endRefreshing];
            [self doFinishLoadData:result error:error ontopblcok:ontopblcok];
        }];
    } else {
        [GetService getHotelListWithPage:page andHotelListFilters:self.filters WithBlock:^(NSDictionary *result, NSError *error) {
            [self hideLoadingView];
            [self.tableView.footer endRefreshing];
            [self.tableView.header endRefreshing];
            [self doFinishLoadData:result error:error ontopblcok:ontopblcok];
        }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id info = _array[indexPath.row];
    BOOL is_like;
    NSNumber *isLike = info[@"is_like"];
    if (isLike.intValue == 0) {
        is_like = NO;
    } else {
        is_like = YES;
    }
    CommonTableViewCell *cell = [tableView commonCell];
	cell.supplier_type = self.supplier_type;
    cell.type = self.listType;
    cell.isLike = is_like;
    cell.ifSH = YES;
    cell.delegate = self;
    NSNumber *service_id;
    if (_listType == supplier_type) {
        service_id = info[@"supplier_user_id"];
    } else {
        service_id = info[@"id"];
    }
    
    cell.row = indexPath.row;
    cell.service_id = service_id;
    [cell setUIWithInfo:info];
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 415 * Height_ato;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    id info = _array[indexPath.row];
    CommonTableViewCell *cell = (CommonTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (_listType == supplier_type) {
        NSNumber *service_id = info[@"supplier_user_id"];
        WTSupplierViewController *supplier = [[WTSupplierViewController alloc] init];
        supplier.supplier_id = service_id;
        supplier.user_id = info[@"id"]; // supplier_id
        NSNumber *num = info[@"is_like"];
        if (num.intValue == 1) {
            supplier.is_like = YES;
        } else {
            supplier.is_like = NO;
        }
        supplier.is_like = cell.isLike;
        [self.navigationController pushViewController:supplier animated:YES];
    } else {
        NSNumber *hotel_id = info[@"id"];
        WTHotelViewController *hotel = [[WTHotelViewController alloc] init];
        hotel.hotel_id = hotel_id;
        NSNumber *num = info[@"is_like"];
        if (num.intValue == 1) {
            hotel.is_like = YES;
        } else {
            hotel.is_like = NO;
        }
        hotel.is_like = cell.isLike;
        [self.navigationController pushViewController:hotel animated:YES];
    }
}

- (void)refreshArrayWithRow:(NSInteger)row isLike:(NSNumber *)is_like
{
    NSDictionary *info = _array[row];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:info];
    [dic setObject:is_like forKey:@"is_like"];
    [_array replaceObjectAtIndex:row withObject:dic];
}

@end
