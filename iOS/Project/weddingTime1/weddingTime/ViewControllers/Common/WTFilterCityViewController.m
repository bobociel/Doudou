//
//  FilterCityViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/10/2.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTFilterCityViewController.h"
#import "GetService.h"
#import "FilterCityTableViewCell.h"
#import "LWUtil.h"
#import "UserInfoManager.h"
@interface WTFilterCityViewController ()<UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, strong) NSArray *array;

@end

@implementation WTFilterCityViewController

{
    NSIndexPath *theIndex;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.type == 1) {
        self.array = [LWAssistUtil defaultSearchCitys];
    }
    
    [self getIndex];
    [self initView];
    [self loadData];
    [self addConformView];
    // Do any additional setup after loading the view.
}


- (void)addConformView
{
    UIButton *conformView = [UIButton buttonWithType:UIButtonTypeSystem];
    conformView.frame = CGRectMake(0, screenHeight - 51 * Height_ato, screenWidth, 51 * Height_ato);
    conformView.backgroundColor = [WeddingTimeAppInfoManager instance].baseColor;
    [self.view addSubview:conformView];
    [conformView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    conformView.titleLabel.font = [UIFont systemFontOfSize:17];
    [conformView setTitle:@"确定" forState:UIControlStateNormal];
    [conformView addTarget:self action:@selector(conformAction) forControlEvents:UIControlEventTouchUpInside];
}
- (void)conformAction
{
    NSDictionary *info1 = _array[theIndex.row];
    id info = info1[@"id"];
    if (self.type == 1) {
        [self.delegate filterHasSelectWithInfo:info index:theIndex];
        [self dismissViewControllerAnimated:YES completion:nil];

    } else {
        [self.synDelegate synFilterHasSelectWithInfo:info index:theIndex];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void)initView
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(10, 38.27, 100, 16);
    button.titleLabel.font = [WeddingTimeAppInfoManager fontWithSize:15];
    [button addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button setTitleColor:[WeddingTimeAppInfoManager instance].baseColor forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.contentEdgeInsets = UIEdgeInsetsMake(0,10, 0, 0);
//    UIImageView *levelImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 63.7, screenWidth, 0.3)];
//    levelImage.image = [LWUtil imageWithColor:[UIColor grayColor] frame:CGRectMake(0, 0, screenWidth, 0.3)];
//    [self.view addSubview:levelImage];
    [self.view addSubview:button];
    self.view.backgroundColor = WHITE;
    
    [self setDataTableViewAsDefault:CGRectMake(0, 64, screenWidth, screenHeight - 51 * Height_ato - 64)];
    
    [self.view addSubview:self.dataTableView];
    
    self.dataTableView.delegate = self;
    self.dataTableView.dataSource = self;
}

- (void)cancelAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//-(void)viewDidLayoutSubviews
//{
//    if ([self.dataTableView respondsToSelector:@selector(setSeparatorInset:)]) {
//        [self.dataTableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
//    }
//    
//    if ([self.dataTableView respondsToSelector:@selector(setLayoutMargins:)]) {
//        [self.dataTableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
//    }
//}
//
//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
//        [cell setSeparatorInset:UIEdgeInsetsZero];
//    }
//    
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
//}


- (void)getIndex
{
    if ([UserInfoManager instance].curCityId) {
        if (_array.count == 0) {
            return;
        }
        for (int i = 0; i<_array.count; i++) {
            NSDictionary *dic = _array[i];
            NSNumber *number = dic[@"id"];
            if (number.intValue == [UserInfoManager instance].curCityId) {
                theIndex = [NSIndexPath indexPathForRow:i inSection:0];
            }
        }
    }
    if (_index) {
        theIndex = _index;
    }
}

- (void)loadData
{
    if (_type == 1) {
        [GetService getCityListWithBlock:^(NSDictionary *result, NSError *error) {
            
            NSArray *array = result[@"data"];
            if (array.count == 0 || error) {
                return ;
            } else {
                self.array = [NSArray arrayWithArray:array];
            }
            
            
            [self getIndex];
            [self.dataTableView reloadData];
        }];
    } else {
        NSDictionary *dic1 = @{@"id" : @"normal",
                               @"name" : @"综合排序",
                               };
        NSDictionary *dic2 = @{@"id" : @"like_num",
                               @"name" : @"按喜欢",
                               };
        NSDictionary *dic3 = @{@"id" : @"comment_num",
                               @"name" : @"按评价",
                               };
        NSDictionary *dic4 = @{@"id" : @"work_num",
                               @"name" : @"按作品",
                               };
        theIndex = [NSIndexPath indexPathForRow:0 inSection:0];
        
        if (_index) {
            theIndex = _index;
        }

        self.array = [NSArray arrayWithObjects:dic1, dic2, dic3, dic4, nil];
        [self.dataTableView reloadData];
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
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
