//
//  FindViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/22.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTFindViewController.h"
#import "WTSupplierViewController.h"
#import "WTInspiretionListViewController.h"
#import "WTWorksDetailViewController.h"
#import "WTFilterCityViewController.h"
#import "WTSearchViewController.h"
#import "FindTableViewCell.h"
#import "NetworkManager.h"
#import "UserInfoManager.h"
#import "LWUtil.h"
#import "SQLiteAssister.h"
#import "LWAssistUtil.h"
#import "GetService.h"
#import "MJRefresh.h"
#import "LocationManager.h"
#import "CellAnimation.h"
@interface WTFindViewController ()<UITableViewDataSource, UITableViewDelegate, FilterSelectDelegate, LocationManagerDelegate>

@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation WTFindViewController
{
    LocationManager *locationManager;
    NSString *city_id;
    BOOL ifUpDrag;
    int page;
    NSIndexPath *curIndex;
}

-(void)setNavWithHidden
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)searchWithKeyWord:(NSString*)key
{

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.array = [NSMutableArray array];

    city_id = [LWUtil getString:@([UserInfoManager instance].curCityId) andDefaultStr:@"141"];
    if (![UserInfoManager instance].curCityId) {
        city_id = @"0";
    } else {
        city_id = [NSString stringWithFormat:@"%d", [UserInfoManager instance].curCityId];
    }
    int64_t nowDate = [[NSDate date] timeIntervalSince1970];

    [self loadLocalDataWithCityId:city_id Time:nowDate limit:10];
    [self initView];
    [self reconcileDataWithBlock:nil footerTime:0];
    [self addTagButton];
    [self initRefresh];
    
	locationManager = [[LocationManager alloc] init];
	locationManager.delegate = self;
	[locationManager beginSearch];

}

- (void)initRefresh
{
    __weak UIScrollView *scrollView = self.tableView;
    scrollView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        int64_t nowDate = 0;
        if (_array.count > 0) {
            for (FindItemModel *find in _array) {
                if (nowDate == 0) {
                    nowDate = find.update_time;
                } else {
                    if (find.update_time < nowDate) {
                        nowDate = find.update_time;
                    }
                }
            }
        } else{
            nowDate = [[NSDate date] timeIntervalSince1970];
        }
        ifUpDrag = YES;
        [self loadLocalDataWithCityId:city_id Time:nowDate limit:10];
        [self reconcileDataWithBlock:nil footerTime:nowDate];
    }];
    
    scrollView.header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
        ifUpDrag = NO;
        page = 0;
        [self reconcileDataWithBlock:nil footerTime:0];
    }];
}


- (void)filterHasSelectWithInfo:(id)info index:(NSIndexPath *)index
{
    WS(ws);
    [NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];
    curIndex = index;
    city_id = info;
    self.array = [NSMutableArray array];
    int64_t nowDate = [[NSDate date] timeIntervalSince1970];
    [self loadLocalDataWithCityId:city_id Time:nowDate limit:10];
    [self reconcileDataWithBlock:^{
        if (ws.array.count > 0) {
            [ws.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]  atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        
    } footerTime:0];
}

- (void)addTagButton
{
    UIButton *filter = [UIButton new];
    [self.view addSubview:filter];
    filter.userInteractionEnabled = NO;
//    [filter addTarget:self action:@selector(filterAction) forControlEvents:UIControlEventTouchUpInside];
    [filter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(screenWidth - 15* Width_ato - 32 * 2);
        make.top.mas_equalTo(32 * Height_ato);
        make.size.mas_equalTo(CGSizeMake(32, 32));
    }];
    UIButton *filter_big = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 15* Width_ato - 32 * 2 - 20, 12 * Height_ato, 32 + 20, 32 + 40 * Height_ato)];
    [self.view addSubview:filter_big];
    [filter_big addTarget:self action:@selector(filterAction) forControlEvents:UIControlEventTouchUpInside];
    [filter setBackgroundImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
    [filter setBackgroundImage:[UIImage imageNamed:@"filter_select"] forState:UIControlStateHighlighted];
    UIButton *seachButton = [UIButton new];
    [self.view addSubview:seachButton];
    seachButton.userInteractionEnabled = NO;
//    [seachButton addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
    [seachButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(screenWidth - 10* Width_ato - 32);
        make.top.mas_equalTo(32 * Height_ato);
        make.size.mas_equalTo(CGSizeMake(32, 32));
    }];
    UIButton *searchButton_big = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 10* Width_ato - 32, 12 * Height_ato  , 32 + 10 * Width_ato, 32 +40 * Height_ato)];
    [searchButton_big addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchButton_big];
    [seachButton setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [seachButton setBackgroundImage:[UIImage imageNamed:@"search_select"] forState:UIControlStateHighlighted];
}

- (void)filterAction
{
    WTFilterCityViewController *filter = [[WTFilterCityViewController alloc] init];
    filter.type = 1;
    filter.delegate = self;
    filter.index = curIndex;
    [self presentViewController:filter animated:YES completion:nil];
}

- (void)searchAction
{
    WTSearchViewController *search = [[WTSearchViewController alloc] init];
    search.curSearchType  = SearchTypeSupplier;
    [self.navigationController pushViewController:search animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)loadLocalDataWithCityId:(NSString *)city Time:(int64_t)time limit:(int)limit
{
    SQLiteAssister *sqlite = [SQLiteAssister sharedInstance];
    WS(ws);
    void(^callback)(NSArray *array, NSError *error) = ^(NSArray *array, NSError *error) {
        if (ifUpDrag) {
            [ws.array addObjectsFromArray:array];
        } else{
            ws.array = [NSMutableArray arrayWithArray:array];
        }
        if (!city.intValue == 0) {
            [sqlite pullItemsForCityId:@"0" timestamp:time limit:limit callback:^(NSArray *array, NSError *error) {
                [ws.array addObjectsFromArray:array];
            }];
        }
        ws.array = [NSMutableArray arrayWithArray:[self bunbleSortWithArray:ws.array]];
    };
    if (city.intValue == 0) {
        [sqlite pullItemsForAllCityWithtimestamp:time limit:limit callback:^(NSArray *array, NSError *error) {
            if (ifUpDrag) {
                [ws.array addObjectsFromArray:array];
            } else{
                ws.array = [NSMutableArray arrayWithArray:array];
            }
        }];
    } else {
        [sqlite pullItemsForCityId:city timestamp:time limit:limit callback:callback];
    }
    
    [_tableView.footer endRefreshing];
    [_tableView.header endRefreshing];
}


-(void)swapWithData:(NSMutableArray *)aData index1:(NSInteger)index1 index2:(NSInteger)index2{
    NSNumber *tmp = [aData objectAtIndex:index1];
    [aData replaceObjectAtIndex:index1 withObject:[aData objectAtIndex:index2]];
    [aData replaceObjectAtIndex:index2 withObject:tmp];
}

-(NSArray *)bunbleSortWithArray:(NSArray *)aData{
    NSMutableArray *array = [[NSMutableArray alloc]initWithArray:aData];
    if (array.count == 0) {
        return array;
    }
    for (int i=0; i<[array count]-1; i++) {
        for (int j =0; j<[array count]-1-i; j++) {
            FindItemModel *listj = [array objectAtIndex:j];
            FindItemModel *listJ = [array objectAtIndex:j+1];
            if (listj.update_time < listJ.update_time) {
                [self swapWithData:array index1:j index2:j+1];
            }
        }
    }
    return array;
}

- (void)reconcileDataWithBlock:(void(^)())block footerTime:(int64_t)time
{
    WS(ws);
    FindItemModel *modle = [[FindItemModel alloc] init];
    
    if (time != 0) {
        modle.update_time = time;
    } else {
        modle.update_time = [NSDate date].timeIntervalSince1970;
    }
    if (_array.count == 0) {
        [GetService getFindListWithCount:0 CityId:city_id WithifUpDrag:ifUpDrag model:modle WithBlock:^(NSDictionary *result, NSError *error) {
            [ws manageTheResultWith:result Blcok:block];
        }];
    } else {
        
        FindItemModel *item;
        if (time!=0) {
            item = [_array lastObject];
        } else {
            item = _array[0];
        }
    [GetService getFindListWithCount:_array.count CityId:city_id WithifUpDrag:ifUpDrag model:item WithBlock:^(NSDictionary *result, NSError *error) {
        [ws manageTheResultWith:result Blcok:block];
    }];
    }
}
- (void)manageTheResultWith:(NSDictionary *)result Blcok:(void(^)())block
{
     WS(ws);
    [ws.tableView.header endRefreshing];
    [NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];
    NSArray *array = result[@"data"];
    int count = 0;
    if (array.count > 0) {
        for (NSDictionary *dic in array) {
            NSDictionary *content = dic[@"content"];
            FindItemModel *item = [[FindItemModel alloc] init];
            
            item.ID = [dic[@"id"] stringValue];
            item.city_id = [dic[@"city_id"] stringValue];
            if (item.city_id.length == 0 || !item.city_id) {
                item.city_id = @"0";
            }

			item.type = (FindItemType)[dic[@"discover_type"] integerValue];
			item.post_id = [LWUtil getString:content[@"post_id"] andDefaultStr:@""];
            item.update_time = [dic[@"update_time"] longLongValue];
            item.title = [LWUtil getString:content[@"title"] andDefaultStr:@""];
            item.path = [LWUtil getString:content[@"path"] andDefaultStr:@""];
            item.supplier_id = [LWUtil getString:content[@"supplier_id"] andDefaultStr:@""];
            item.tag = [LWUtil getString:content[@"tag"] andDefaultStr:@""];;
            item.content = [LWUtil getString:content[@"content"] andDefaultStr:@""];
            item.counts = [LWUtil getString:content[@"counts"] andDefaultStr:@""];
            item.content = [LWUtil getString:[NSString stringWithFormat:@"%@", content[@"content"]] andDefaultStr:@""];

			if ([dic[@"is_delete"] boolValue] == 1) {
				[[SQLiteAssister sharedInstance] deleteItem:item];
				continue;
			}

            if (![item.ID isNotEmptyCtg] || ![item.city_id isNotEmptyCtg] || !item.update_time) {
                continue ;
            }
            for (FindItemModel *SQLitem in _array) {
                if (SQLitem.ID.intValue != item.ID.intValue) {
                    count++;
                }
            }
            [[SQLiteAssister sharedInstance] pushItem:item];
            
        }
        int64_t nowDate;
        nowDate = [[NSDate date] timeIntervalSince1970];
        if (ifUpDrag) {
            if(_array.count > 0) {
            FindItemModel *model = [_array lastObject];
                nowDate = model.update_time;
            }
        }
        
        [self loadLocalDataWithCityId:city_id Time:nowDate limit:(10 + count)];
        if (self.array.count == 0) {
            [NetWorkingFailDoErr errWithView:self.tableView content:@"该城市暂时还没有发现哦" tapBlock:^{
                [NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];
                [self reconcileDataWithBlock:nil footerTime:0];
            }];
        }
        [_tableView reloadData];
        if (block != nil) {
            block();
        }
        
    } else {
        if (self.array.count == 0) {
            [NetWorkingFailDoErr errWithView:self.tableView content:@"该城市暂时还没有发现哦" tapBlock:^{
                [self loadData];
            }];
        }
        [_tableView reloadData];
        if (block != nil) {
            block();
        }
        return ;
    }

}

- (void)initView
{
    [self.view addSubview:[UIView new]];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - 47) style:UITableViewStylePlain ];
    [self.view addSubview:_tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
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
    FindItemModel *info = _array[indexPath.row];
    FindTableViewCell *cell = [tableView findCell];
    [cell setUIWithInfo:info];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell addOpacityAnitionFrom:0.2 to:1];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FindItemModel *info = _array[indexPath.row];
    if (info.type == FindItemTypeSupplier) {
        WTSupplierViewController *supplier = [[WTSupplierViewController alloc] init];
        int supplier_id = info.supplier_id.intValue;
        supplier.supplier_id = @(supplier_id);
        [self.navigationController pushViewController:supplier animated:YES];
    } else if(info.type == FindItemTypeInspiretion){
        WTInspiretionListViewController *ins = [[WTInspiretionListViewController alloc] init];
        ins.searchTag = info.tag;
        [self.navigationController pushViewController:ins animated:YES];
	}else if (info.type == FindItemTypePost){
		WTWorksDetailViewController *worksVC = [[WTWorksDetailViewController alloc] init];
		worksVC.works_id = @(info.post_id.integerValue);
		[self.navigationController pushViewController:worksVC animated:YES];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 325 * Height_ato;
}

- (void)didiFalidLocation
{
    [locationManager stopLocating];
}

- (void)didLocationSucceed:(BMKReverseGeoCodeResult *)result {
    [UserInfoManager instance].city_name = [NSString stringWithFormat:@"%@",result.addressDetail.city];
    [locationManager stopLocating];
    
    [GetService getCityidWithLon:result.location.longitude  andLat:result.location.latitude WithBlock:^(NSDictionary *result, NSError *error) {
        if (!error) {
            if ([result isKindOfClass:[NSDictionary class]]) {
                if (result[@"city_id"]) {
                    [UserInfoManager instance].curCityId = [result[@"city_id"] intValue];
                    [[UserInfoManager instance]saveToUserDefaults];
                }
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
