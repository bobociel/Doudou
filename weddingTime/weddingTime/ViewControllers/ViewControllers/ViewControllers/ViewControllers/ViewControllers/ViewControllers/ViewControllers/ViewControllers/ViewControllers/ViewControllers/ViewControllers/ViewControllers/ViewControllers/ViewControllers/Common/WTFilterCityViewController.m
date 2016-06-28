//
//  FilterCityViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/10/2.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTFilterCityViewController.h"
#import "FilterCityTableViewCell.h"
#import "GetService.h"
#import "UserInfoManager.h"
#import "LWUtil.h"
@interface WTFilterCityViewController ()<UITableViewDataSource, UITableViewDelegate>
{
	NSIndexPath *theIndex;
}
@property (nonatomic, strong) NSArray *array;
@end

@implementation WTFilterCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.type == 1) {
        self.array = [LWAssistUtil defaultSearchCitys];
    }
    
    [self getIndex];
    [self setupView];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

#pragma mark - Action
- (void)conformAction
{
    NSDictionary *info1 = _array[theIndex.row];
    id info = info1[@"id"];
    if (self.type == WTFliterTypeCity) {
        [self.delegate cityFilterHasSelectWithInfo:info index:theIndex];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.delegate synFilterHasSelectWithInfo:info index:theIndex];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void)cancelAction
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - View

- (void)setupView
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(10, 38.27, 100, 16);
    button.titleLabel.font = [WeddingTimeAppInfoManager fontWithSize:15];
    [button addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button setTitleColor:[WeddingTimeAppInfoManager instance].baseColor forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.contentEdgeInsets = UIEdgeInsetsMake(0,10, 0, 0);
    [self.view addSubview:button];
    
    [self setDataTableViewAsDefault:CGRectMake(0, kNavBarHeight, screenWidth, screenHeight - kTabBarHeight - kNavBarHeight)];
	self.dataTableView.delegate = self;
	self.dataTableView.dataSource = self;
    [self.view addSubview:self.dataTableView];

	UIButton *conformView = [UIButton buttonWithType:UIButtonTypeSystem];
	conformView.frame = CGRectMake(0, screenHeight - kTabBarHeight, screenWidth, kTabBarHeight);
	conformView.backgroundColor = [WeddingTimeAppInfoManager instance].baseColor;
	conformView.titleLabel.font = [UIFont systemFontOfSize:17];
	[conformView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[conformView setTitle:@"确定" forState:UIControlStateNormal];
	[self.view addSubview:conformView];
	[conformView addTarget:self action:@selector(conformAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)getIndex
{
	for (int i = 0; i<_array.count; i++)
	{
		NSDictionary *dic = _array[i];
		if([dic[@"id"] isKindOfClass:[NSNumber class]] && _synOrCityID.integerValue == [dic[@"id"] integerValue])
		{
			theIndex = [NSIndexPath indexPathForRow:i inSection:0];
		}
		else if ([dic[@"id"] isKindOfClass:[NSString class]] && [_synOrCityID isEqualToString:dic[@"id"]])
		{
			theIndex = [NSIndexPath indexPathForRow:i inSection:0];
		}
	}
}

- (void)loadData
{
	theIndex = theIndex ? : [NSIndexPath indexPathForRow:0 inSection:0];
    if (_type == WTFliterTypeCity) {
        [GetService getCityListWithBlock:^(NSDictionary *result, NSError *error) {
            NSArray *array = result[@"data"];
            if (!error && array.count > 0) { self.array = [NSArray arrayWithArray:array]; }
            [self getIndex];
            [self.dataTableView reloadData];
        }];
    }
	else if(_type == WTFliterTypeSupplier)
    {
		self.array = @[ @{@"id" : @"score",@"name" : @"综合排序"},
						@{@"id" : @"like_num",@"name" : @"按喜欢"},
						@{@"id" : @"comment_num",@"name" : @"按评价"},
						@{@"id" : @"post_num",@"name" : @"按作品",},
						@{@"id" : @"lowest_price",@"name" : @"按价格"} ];
		[self getIndex];
        [self.dataTableView reloadData];
    }
	else if(_type == WTFliterTypePost)
	{
		self.array = @[ @{@"id" : @"score",@"name" : @"综合排序"},
						@{@"id" : @"lowest_price",@"name" : @"按价格"} ];
		[self getIndex];
		[self.dataTableView reloadData];
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id info = _array[indexPath.row];
    FilterCityTableViewCell *cell = [tableView filterCityCell];
    [cell setInfo:info];
    
    if (indexPath.row == 0) {
        if (!theIndex) {
            [cell setSelectedColor];
            theIndex = indexPath;
        }
        
    } else {
        [cell restoreTitleColor];
    }
    if (theIndex.row == indexPath.row) {
        [cell setSelectedColor];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 53 * Height_ato;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (theIndex) {
        FilterCityTableViewCell *cell = (FilterCityTableViewCell *)[tableView cellForRowAtIndexPath:theIndex];
        [cell restoreTitleColor];
    }
    FilterCityTableViewCell *cell = (FilterCityTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectedColor];
    theIndex = indexPath;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
