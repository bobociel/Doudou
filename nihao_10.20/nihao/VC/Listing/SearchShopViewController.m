//
//  SearchShopViewController.m
//  nihao
//
//  Created by 刘志 on 15/5/29.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "SearchShopViewController.h"
#import "MerchantCell.h"
#import "HttpManager.h"
#import "ListingLoadingStatusView.h"
#import "MyMerchantListFilter.h"
#import "BaseFunction.h"
#import <MJRefresh.h>
#import "GTMNSString+URLArguments.h"
#import "MerchantDetailsViewController.h"
#import "Merchant.h"
#import <MJExtension/MJExtension.h>

@interface SearchShopViewController () <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate> {
    ListingLoadingStatusView *_loadingStatus;
    UITextField *_search;
    NSMutableArray *_data;
    NSInteger _total;
    NSInteger _page;
}

@property (weak, nonatomic) IBOutlet UITableView *table;

@end

@implementation SearchShopViewController

static NSString *identifier = @"merchantcellidentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self dontShowBackButtonTitle];
    [self initSearch];
    [self initTable];
    [self initLoadingStatus];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    self.hidesBottomBarWhenPushed = YES;
}

- (void) initSearch {
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 8, SCREEN_WIDTH - 80, 27)];
    searchView.backgroundColor = [UIColor whiteColor];
    //搜索图标
    UIImageView *searchImage = [[UIImageView alloc] initWithImage:ImageNamed(@"common_icon_search_blue")];
    searchImage.frame = CGRectMake(10, 5, 16, 16);
    [searchView addSubview:searchImage];
    //搜索框
    _search = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(searchImage.frame) + 8, 0, CGRectGetWidth(searchView.frame) - 20, 27)];
    _search.font = FontNeveLightWithSize(14.0);
    _search.delegate = self;
    _search.returnKeyType = UIReturnKeySearch;
    //如果搜索框内容为空，则不显示
    _search.enablesReturnKeyAutomatically = YES;
    _search.keyboardType = UIKeyboardTypeASCIICapable;
    //第一响应者为搜索框
    [_search becomeFirstResponder];
    [searchView addSubview:_search];
    self.navigationItem.titleView = searchView;
}

- (void) initLoadingStatus {
    _loadingStatus = [[ListingLoadingStatusView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    __weak SearchShopViewController *weakSelf = self;
    __weak UITextField *weakSearch = _search;
    _loadingStatus.refresh = ^() {
        [weakSelf reqdataWithKeyword:weakSearch.text];
    };
    [self.view addSubview:_loadingStatus];
}

- (void) initTable {
    [_table registerNib:[UINib nibWithNibName:@"MerchantCell" bundle:nil] forCellReuseIdentifier:identifier];
    _table.tableFooterView = [[UIView alloc] init];
    _table.tableHeaderView = [[UIView alloc] init];
    _data = [NSMutableArray array];
    [BaseFunction addRefreshHeaderAndFooter:_table refreshAction:@selector(refresh) loadMoreAction:@selector(loadMore) target:self];
    _table.footer.hidden = YES;
    _table.header.hidden = YES;
    _page = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - uitableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MerchantCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    Merchant *merchant = _data[indexPath.row];
    [cell initCellWithMerchantData:merchant];
    return cell;
}

#pragma mark - uitableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MerchantDetailsViewController *controller = [[MerchantDetailsViewController alloc] init];
    controller.merchantInfo = _data[indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [_loadingStatus showWithStatus:Loading];
    [self reqdataWithKeyword:textField.text];
    return YES;
}

#pragma mark - reqdata
/**
 *  搜索关键字
 *
 *  @param keyword
 */
- (void) reqdataWithKeyword : (NSString *) keyword {
    MyMerchantListFilter *filter = [[MyMerchantListFilter alloc] initWithLatitude:0 longitude:0 distance:0 oneLevelMhcID:0 twoLevelMhcID:0 threeLevelMhcID:0 mhiCityName:_cityName mhiDistrictName:@"" mhiBidId:0 keyWord:[keyword lowercaseString]];
    [filter setPage:_page andRows:10];
    [HttpManager requestMerchantListByFilter:filter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([responseObject[@"code"] integerValue] == 0) {
			NSArray *merchantArray = [Merchant objectArrayWithKeyValuesArray:responseObject[@"result"][@"rows"]];
            _total = merchantArray.count;
            NSLog(@"%ld",_total);
            if(_total == 0) {
				if (_data.count == 0) {
					[_loadingStatus showWithStatus:Empty];
				}
                _table.footer.hidden = YES;
            } else {
                [_loadingStatus showWithStatus:Done];
				[_data removeAllObjects];
				
				[_data addObjectsFromArray:merchantArray];
                //是否正在上拉刷新
                if(_table.footer.isRefreshing) {
                    [_table.footer endRefreshing];
                }
                //上拉刷新是否显示
                if(_total >= DEFAULT_REQUEST_DATA_ROWS_INT) {
                    _table.footer.hidden = NO;
                    _page++;
                } else {
                    _table.footer.hidden = YES;
                }
                [_table reloadData];
            }
        }
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_loadingStatus showWithStatus:NetErr];
    }];
}

//上拉加载更多
- (void) loadMore {
    [self reqdataWithKeyword:_search.text];
}

@end
