//
//  LikeChildViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/19.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTLikeChildViewController.h"
#import "CommonTableViewCell.h"
#import "NetworkManager.h"
#import "WTProgressHUD.h"
#import "UserInfoManager.h"
#import "GetService.h"
#import "MJRefresh.h"
#import "WTHotelViewController.h"
#import "WTSupplierViewController.h"
#import "NetworkManager.h"
#import "BottomView.h"
@interface WTLikeChildViewController ()<UITableViewDataSource, UITableViewDelegate, CancelLikeDelegate>

@end

@implementation WTLikeChildViewController

{
    loadType load;
    int page;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    page = 0;
    load = firstLoad;
    [self initView];
    [self loadData];
    [self addNotify];
    
}

- (void)addNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bottomViewSelect) name:BOTTOMVIEWNOTIFY object:nil];
}

- (void)bottomViewSelect
{
    page--;
    [self loadData];
}

- (void)cancelLikeNum:(NSInteger)num
{
	dispatch_async(dispatch_get_main_queue(), ^{
		page--;
		[self loadData];
	});
}

- (void)initRefresh
{
    __weak UIScrollView *scrollView = self.tableView;
    scrollView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self loadData];
    }];
    
//    scrollView.header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
//        page = 0;
//        [self loadData];
//    }];
}

- (void)loadData
{
    if (self.type == 0) {
        [self loadDataWithType:1];
    } else {
        [self loadDataWithType:2];
    }
}
#pragma mark - 加载数据
- (void)loadDataWithType:(int)type
{
    page++;
    [GetService getLikeListWithTypeId:type andPage:page WithBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        if(page == 1) {
            self.array = [NSMutableArray array];
            [self.array addObjectsFromArray:result[@"data"]];
        } else {
            [self.array addObjectsFromArray:result[@"data"]];
        }
        load = reLoad;
        if (page == 1) {
            [self.tableView.header endRefreshing];
        }
        if (self.array.count == 0) {
            NSString *content;
            if (type == 1) {
                content = @"您还没有喜欢过服务商哦";
            } else {
                content = @"您还没有喜欢过酒店哦";
            }
            [NetWorkingFailDoErr errWithView:self.tableView content:content tapBlock:^{
                [self loadDataWithType:type];
            }];
        }
        [self.tableView.footer endRefreshing];
        [self.tableView reloadData];
    }];
}

- (void)initView
{
    [self.view addSubview:[UIView new]];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, self.view.frame.size.height - 111) style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    [self initRefresh];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self showLoadingView];
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
//    if (_array.count > 0 || load == firstLoad) {
        NSDictionary *info = _array[indexPath.row];
        CommonTableViewCell *cell = [tableView commonCell];
        cell.alpha = 1.0f;
        cell.type = self.type;
        cell.delegate = self;
        if (indexPath.row == _array.count - 1) {
            cell.shadowSign = NO;
        } else {
            cell.shadowSign = YES;
        }
        if (_type == 0) {
             cell.service_id = info[@"user_id"];
        } else {
            cell.service_id = info[@"id"];
        }
       
        [cell setUIWithInfo:info];
        return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_array.count > 0 || load == firstLoad) {
        return 415 * screenHeight / 736.0;
    } else {
        return self.view.frame.size.height;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id info = _array[indexPath.row];
    if (_type == 0) {
        WTSupplierViewController *supploer = [[WTSupplierViewController alloc] init];
        supploer.supplier_id = info[@"user_id"];
        supploer.is_like = YES;
        [self.navigationController pushViewController:supploer animated:YES];
    } else {
        WTHotelViewController *hotel = [[WTHotelViewController alloc] init];
        hotel.hotel_id = info[@"id"];
        hotel.is_like = YES;
        [self.navigationController pushViewController:hotel animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
