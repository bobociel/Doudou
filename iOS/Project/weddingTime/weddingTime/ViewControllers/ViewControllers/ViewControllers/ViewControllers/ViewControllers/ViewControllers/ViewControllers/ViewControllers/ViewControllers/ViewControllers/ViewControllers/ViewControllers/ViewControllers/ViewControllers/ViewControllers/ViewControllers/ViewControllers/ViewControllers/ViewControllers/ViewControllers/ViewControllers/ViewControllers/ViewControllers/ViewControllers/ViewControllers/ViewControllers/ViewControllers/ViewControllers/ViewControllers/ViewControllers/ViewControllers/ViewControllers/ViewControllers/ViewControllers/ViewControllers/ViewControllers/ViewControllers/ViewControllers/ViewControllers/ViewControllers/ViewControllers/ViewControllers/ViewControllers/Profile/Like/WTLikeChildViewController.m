//
//  LikeChildViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/19.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTLikeChildViewController.h"
#import "WTHotelViewController.h"
#import "WTSupplierViewController.h"
#import "WTWorksDetailViewController.h"
#import "CommonTableViewCell.h"
#import "NetworkManager.h"
#import "WTProgressHUD.h"
#import "UserInfoManager.h"
#import "GetService.h"
#import "MJRefresh.h"
#import "NetworkManager.h"
#define kPageSize 10
@interface WTLikeChildViewController ()<UITableViewDataSource, UITableViewDelegate, CommonTableViewCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *array;
@end

@implementation WTLikeChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.array = [NSMutableArray array];
    [self initView];
    [self loadData];
}

- (void)initView
{
	[self.view addSubview:[UIView new]];
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, self.view.frame.size.height - 111) style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:_tableView];
	[self initRefresh];
	[self showLoadingView];
}

- (void)initRefresh
{
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self loadData];
    }];
}

#pragma mark - 加载数据
- (void)loadData
{
	NSUInteger page = self.array.count / kPageSize + 1;
    [GetService getLikeListWithTypeId:_type andPage:page WithBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
		[self.tableView.footer endRefreshing];
		[LWAssistUtil getCodeMessage:error defaultStr:@"" noresultStr:@""];
		if(page == 1) { _array = [NSMutableArray array]; }

		Class dataClass = _type == LikeTypeSupplier ? [WTSupplier class] : [WTHotel class] ;
		dataClass = _type == LikeTypePost ? [WTSupplierPost class] : dataClass ;
        NSArray *dataArray = [NSArray modelArrayWithClass:dataClass json:result[@"data"]];
        [self.array addObjectsFromArray:dataArray];
		[self.tableView reloadData];

        self.tableView.footer.hidden = dataArray.count < kPageSize;
        
        if (self.array.count == 0)
        {
            NSString *content = (_type == LikeTypeSupplier) ?  @"您还没有喜欢过服务商哦" :  @"您还没有喜欢过酒店哦" ;
			content = _type == LikeTypePost ? @"您还没有喜欢过作品哦" : content ;
            [NetWorkingFailDoErr errWithView:self.tableView content:content tapBlock:^{
                [self loadData];
            }];
        }
    }];
}

- (void)commonCell:(CommonTableViewCell *)cell isLike:(BOOL)isLike
{
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	if(!isLike){
		[_array removeObjectAtIndex:indexPath.row];
		(_array.count  < kPageSize) ? [self loadData] : [self.tableView reloadData];
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id info = _array[indexPath.row];
    if(_type == LikeTypeSupplier)
    {
        WTSupplier *supplier = (WTSupplier *)info;
        CommonTableViewCell *cell = [tableView CommonTableViewCell];
        cell.alpha = 1.0f;
        cell.delegate = self;
        cell.shadowSign = !(indexPath.row == _array.count - 1);
        [cell setSupplier:supplier];
        return cell;
    }
    else if(_type == LikeTypeHotel)
    {
        WTHotel *hotel = (WTHotel *)info;
        CommonTableViewCell *cell = [tableView CommonTableViewCell];
        cell.alpha = 1.0f;
        cell.delegate = self;
        cell.shadowSign = !(indexPath.row == _array.count - 1);
        [cell setHotel:hotel];
        return cell;
    }
	else if(_type == LikeTypePost)
	{
		WTSupplierPost *post = (WTSupplierPost *)info;
		CommonTableViewCell *cell = [tableView CommonTableViewCell];
		cell.alpha = 1.0f;
		cell.delegate = self;
		cell.shadowSign = !(indexPath.row == _array.count - 1);
		[cell setPost:post];
		return cell;
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_array.count > 0 ) {
        return 300 * Height_ato + 105;
    } else {
        return self.view.frame.size.height;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id info = _array[indexPath.row];
    if(_type == LikeTypeSupplier)
    {
        __block WTSupplier *supplier = (WTSupplier *)info;
        WTSupplierViewController *supplierVC = [[WTSupplierViewController alloc] init];
        supplierVC.supplier_id = supplier.user_id;
		[supplierVC setLikeBlock:^(BOOL isLike){
			isLike ? [_array insertObject:supplier atIndex:indexPath.row]: [_array removeObjectAtIndex:indexPath.row];
            (_array.count  < kPageSize) ? [self loadData] : [self.tableView reloadData];
		}];
        [self.navigationController pushViewController:supplierVC animated:YES];
    }
    else if(_type == LikeTypeHotel)
    {
        __block WTHotel *hotel = (WTHotel *)info;
        WTHotelViewController *hotelVC = [[WTHotelViewController alloc] init];
        hotelVC.hotel_id = hotel.ID;
		[hotelVC setLikeBlock:^(BOOL isLike){
			isLike ? [_array insertObject:hotel atIndex:indexPath.row] : [_array removeObjectAtIndex:indexPath.row];
			(_array.count  < kPageSize) ? [self loadData] : [self.tableView reloadData];
		}];
		[self.navigationController pushViewController:hotelVC animated:YES];
    }
	else if(_type == LikeTypePost)
	{
		__block WTSupplierPost *post = (WTSupplierPost *)info;
		WTWorksDetailViewController *workVC = [WTWorksDetailViewController instanceWTWorksDetailVCWithWrokID:post.ID];
		[workVC setLikeBlock:^(BOOL isLike){
			isLike ? [_array insertObject:post atIndex:indexPath.row] : [_array removeObjectAtIndex:indexPath.row];
			(_array.count  < kPageSize) ? [self loadData] : [self.tableView reloadData];
		}];
		[self.navigationController pushViewController:workVC animated:YES];
	 }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
