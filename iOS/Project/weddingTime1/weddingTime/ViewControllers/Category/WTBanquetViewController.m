//
//  BanquetViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/10/3.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTBanquetViewController.h"
#import "GetService.h"
#import "WorksDetailCell.h"
#import <UIImageView+WebCache.h>
@interface WTBanquetViewController ()<UITableViewDataSource, UITableViewDelegate, BottomViewDelegate>

@end

@implementation WTBanquetViewController
{
    NSArray *array;
    NSDictionary *result;
    int ImageHeight;
    int ImageWidth;
    UIImageView *topImage;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    ImageWidth = screenWidth;
    ImageHeight = 360 * Height_ato;
    [self initView];
    [self loadData];
//    [self addBottom];
}

- (void)addBottom
{
    [_bottom showThreeButtons];
    _bottom.mainDelegate = self;
    [self.view addSubview:_bottom];
}

- (void)conversationButtonHasSelectType:(NSInteger)type
{
    [self conversationSelectType:type supplier_id:self.hotel_id hotelDic:self.hotel_result name:_hotel_name phone:self.bottom.tel_num avatar:self.bottom.supplier_avatar];
}

- (void)initView
{
    self.view.backgroundColor = WHITE;
    [self showLoadingView];
    [self setDataTableViewAsDefault:CGRectMake(0, 0, screenWidth, screenHeight)];
    self.dataTableView.delegate = self;
    self.dataTableView.dataSource = self;
    self.dataTableView.tableHeaderView = [self getHeader];
    [self.view addSubview:self.dataTableView];
    [self addTapButton];
}

- (UIView *)getHeader
{
    NSArray *destArray = result[@"ballroom_info"];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, (76 + 360 + 28 * destArray.count) * Height_ato)];
    topImage = [UIImageView new];
    [view addSubview:topImage];
    //todo
    [topImage sd_setImageWithURL:[NSURL URLWithString:result[@"ballroom_avatar"]] placeholderImage:[UIImage imageNamed:result[@"placelolder_detail"]]];//todo;
    topImage.frame = CGRectMake(0, 0, screenWidth, 360 * Height_ato);
    UIImageView *avatarImage = [UIImageView new];
    [view addSubview:avatarImage];
    //todo
    [avatarImage sd_setImageWithURL:[NSURL URLWithString:result[@"hotel_avatar"]] placeholderImage:[UIImage imageNamed:result[@"suppplier"]]];
    avatarImage.layer.borderColor = WHITE.CGColor;
    avatarImage.layer.borderWidth = 3;
    avatarImage.layer.cornerRadius = 65 * Width_ato / 2.0;
    avatarImage.layer.masksToBounds = YES;
    [avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(327 * Height_ato);
        make.centerX.equalTo(view);
        make.size.mas_equalTo(CGSizeMake(65 * Width_ato, 65 * Width_ato));
    }];
    
    for (int i = 0; i < destArray.count; i++) {
        NSDictionary *dic = destArray[i];
        UILabel *label = [UILabel new];
        [view addSubview:label];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = rgba(102, 102, 102, 1);
        
        NSString *str = [NSString stringWithFormat:@"%@: %@", [LWUtil getString:dic[@"name"] andDefaultStr:@""], [LWUtil getString:dic[@"value"] andDefaultStr:@""]];
        label.text = str;
        label.font = [WeddingTimeAppInfoManager fontWithSize:13];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo((38 + 360+ 28 * i) * Height_ato);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(28 * Height_ato);
        }];
    }
    return view;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat yOffset   = self.dataTableView.contentOffset.y;
    
    if (yOffset < 0) {
        
       
//        CGRect f = CGRectMake(-(factor-ImageWidth)/2.0, yOffset, factor, ImageHeight+ABS(yOffset));
//        topImage.frame = f;
        CGFloat factor = ((ABS(yOffset)+ImageHeight)*ImageWidth)/ImageHeight;
        CGRect f = CGRectMake(-(factor-ImageWidth)/2, yOffset, factor, ImageHeight+ABS(yOffset));
        topImage.frame = f;
    } else {
//        CGRect f = topImage.frame;
//        f.origin.y = -yOffset;
//        topImage.frame = f;
    }
}



- (void)loadData
{
    [GetService getBanquetWithballroomId:_ballroom_id Block:^(NSDictionary *dic, NSError *error) {
        [self hideLoadingView];
        result = dic;
        array = dic[@"attach_path"];
        self.dataTableView.tableHeaderView = [self getHeader];
        [self.dataTableView reloadData];
    }];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id info = array[indexPath.row];
    WorksDetailCell *cell = [tableView WorksDetailCell];
    cell.type = 1;
    [cell setInfo:info];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    id info = array[indexPath.row];
//    NSString *height = info[@"height"];
//    NSString *width = info[@"width"];
    return 350 * Height_ato;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    NSArray *destArray = result[@"ballroom_info"];
//    return (76 + 360 + 28 * destArray.count) * Height_ato;
//    
//}


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
