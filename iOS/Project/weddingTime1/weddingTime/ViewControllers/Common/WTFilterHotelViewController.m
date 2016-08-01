//
//  FilterHotelViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/10/8.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTFilterHotelViewController.h"
#import "SearchItemCell.h"
#import "SearchSliderBarCell.h"
#import "FilterCityTableViewCell.h"
#define buttomBtnHeigh 44.f
@interface WTFilterHotelViewController ()<UITableViewDataSource, UITableViewDelegate, SearchItemCellDelegate, SearchSliderBarCellDelegate>

@property (nonatomic, strong) NSArray *array;
@end

@implementation WTFilterHotelViewController
{
    UITableView *dataTableView;
    UIButton *resetBtn;
    UIButton *doneBtn;
    NSMutableDictionary *cellCash;
    NSArray *data;
    CGRect selfFrame;
    HotelOrSupplierListFilters *hotelfilters;
    NSIndexPath *index;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self loadData];
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
    [conformView addTarget:self action:@selector(doneBtnEvent) forControlEvents:UIControlEventTouchUpInside];
}

- (void)cancelAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)initView
{
    
    if (_filters.index) {
        index = _filters.index;
    } else {
        index = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    
    self.view.backgroundColor = WHITE;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(10, 38.27, 32, 16);
    button.titleLabel.font = [WeddingTimeAppInfoManager fontWithSize:15];
    [button addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button setTitleColor:[WeddingTimeAppInfoManager instance].baseColor forState:UIControlStateNormal];
    [self.view addSubview:button];
    self.view.backgroundColor = WHITE;

    UIButton *reSetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    reSetButton.frame = CGRectMake(screenWidth - 42, 38.27, 32, 16);
    reSetButton.titleLabel.font = [WeddingTimeAppInfoManager fontWithSize:15];
    [reSetButton addTarget:self action:@selector(reset) forControlEvents:UIControlEventTouchUpInside];
    [reSetButton setTitle:@"重置" forState:UIControlStateNormal];
    [reSetButton setTitleColor:[WeddingTimeAppInfoManager instance].baseColor forState:UIControlStateNormal];
    [self.view addSubview:reSetButton];
    
    
    [self addConformView];
    
    dataTableView                                = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, screenWidth,screenHeight  - 51 * Height_ato - 64)];
    dataTableView.backgroundColor                = [UIColor clearColor];
    dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    dataTableView.backgroundView.backgroundColor = [UIColor clearColor];
    dataTableView.delegate                       = self;
    dataTableView.dataSource                     = self;
    [self.view addSubview:dataTableView];
   

}

- (void)loadData
{
    hotelfilters = [HotelOrSupplierListFilters defaultFilters];
    data = @[@(SearchCellKeySynNormal),
             @(SearchCellKeySynLike),
             @(SearchCellKeySynComment),
             @(SearchCellKeyTable),
             @(SearchCellKeyPrice),
             @(SearchCellKeyType),
             @(SearchCellKeyItem)];
    cellCash = [[NSMutableDictionary alloc] initWithCapacity:5];
    NSDictionary *dic1 = @{@"id" : @"normal",
                           @"name" : @"综合排序",
                           };
    NSDictionary *dic2 = @{@"id" : @"like_num",
                           @"name" : @"按喜欢",
                           };
    NSDictionary *dic3 = @{@"id" : @"comment_num",
                           @"name" : @"按评价",
                           };
    
    
    
    self.array = [NSArray arrayWithObjects:dic1, dic2, dic3, nil];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([data[indexPath.row] intValue]) {
        case SearchCellKeySynNormal:
        case SearchCellKeySynLike:
        case SearchCellKeySynComment:
            return 60 * Height_ato;
            break;
        case SearchCellKeyTable:
        case SearchCellKeyPrice:
            return SearchSliderBarCellHeigh;
            break;
        case SearchCellKeyItem:
            return [SearchItemCell getHeightWithStyle:SearchItemCellStyleItem];
        case SearchCellKeyType:
            return [SearchItemCell getHeightWithStyle:SearchItemCellStyleType];
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch ([data[indexPath.row] intValue]) {
            
        case SearchCellKeySynNormal: {
            FilterCityTableViewCell *cell;
            if (cellCash[@(SearchCellKeySynNormal)]) {
                cell = cellCash[@(SearchCellKeySynNormal)];
            } else {
                cell = [tableView filterCityCell];
                [cell setInfo:_array[indexPath.row]];
                if (index == indexPath) {
                    [cell setSelectedColor];
                }
                cellCash[@(SearchCellKeySynNormal)]=cell;
            }
            return cell;
        }
        case SearchCellKeySynLike: {
            FilterCityTableViewCell *cell;
            if (cellCash[@(SearchCellKeySynLike)]) {
                cell = cellCash[@(SearchCellKeySynLike)];
            } else {
                cell = [tableView filterCityCell];
                [cell setInfo:_array[indexPath.row]];
                if (index == indexPath) {
                    [cell setSelectedColor];
                }
                cellCash[@(SearchCellKeySynLike)]=cell;
            }
            return cell;
        }
        case SearchCellKeySynComment: {
            FilterCityTableViewCell *cell;
            if (cellCash[@(SearchCellKeySynComment)]) {
                cell = cellCash[@(SearchCellKeySynComment)];
            } else {
                cell = [tableView filterCityCell];
                [cell setInfo:_array[indexPath.row]];
                if (index == indexPath) {
                    [cell setSelectedColor];
                }
                cellCash[@(SearchCellKeySynComment)]=cell;
            }
            return cell;
        }
        case SearchCellKeyTable: {
            SearchSliderBarCell *cell ;
            
            if (cellCash[@(SearchCellKeyTable)]) {
                cell = cellCash[@(SearchCellKeyTable)];
            }else {
                cell = [tableView SearchSliderBarCell];
                cell.slideDelegate = self;
                cell.height=SearchSliderBarCellHeigh;
                cell.width=self.view.width;
                [cell startWithStyle:SearchSliderBarCellStyleTable];
                cellCash[@(SearchCellKeyTable)]=cell;
                [cell setLower:_filters.desk_start Upper:_filters.desk_end];
            }
            return cell;
        }
        case SearchCellKeyPrice: {
            SearchSliderBarCell *cell ;
            
            if (cellCash[@(SearchCellKeyPrice)]) {
                cell = cellCash[@(SearchCellKeyPrice)];
            }else {
                cell = [tableView SearchSliderBarCell];
                cell.slideDelegate = self;
                cell.height=SearchSliderBarCellHeigh;
                cell.width=self.view.width;
                [cell startWithStyle:SearchSliderBarCellStylePrice];
                cellCash[@(SearchCellKeyPrice)]=cell;
                [cell setLower:_filters.price_start Upper:_filters.price_end];
            }
            return cell;
        }
        case SearchCellKeyType: {
            SearchItemCell *cell ;
            
            if (cellCash[@(SearchCellKeyType)]) {
                cell = cellCash[@(SearchCellKeyType)];
            }else {
                cell = [tableView SearchItemCell];
                cell.itemDelegate = self;
                cell.width=self.view.width;
                [cell startWithStyle:SearchItemCellStyleType];
                cellCash[@(SearchCellKeyType)]=cell;
                
            }
            return cell;
        }
        case SearchCellKeyItem: {
            SearchItemCell *cell ;
            
            if (cellCash[@(SearchCellKeyItem)]) {
                cell = cellCash[@(SearchCellKeyItem)];
            }else {
                cell = [tableView SearchItemCell];
                cell.itemDelegate = self;
                cell.width=self.view.width;
                [cell startWithStyle:SearchItemCellStyleItem];
                cellCash[@(SearchCellKeyItem)]=cell;
                
            }
            return cell;
        }
            
            
        default:
            break;
    }
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < 3) {
        if (index) {
            FilterCityTableViewCell *cell = (FilterCityTableViewCell *)[tableView cellForRowAtIndexPath:index];
            [cell restoreTitleColor];
        }
        FilterCityTableViewCell *cell = (FilterCityTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell setSelectedColor];
        index = indexPath;
    } else {
        return;
    }
}
- (void)slideVauleDidChanged:(SearchSliderBarCellStyle)aStyle andleftValue:(int)lValue adnRightValue:(int)rValue {
    if (aStyle ==SearchSliderBarCellStyleTable) {
        hotelfilters.desk_start = lValue;
        hotelfilters.desk_end   = rValue;
    }else {
        hotelfilters.price_start=lValue;
        hotelfilters.price_end=rValue;
    }
}

- (void)SearchItemCellDidChangedIndexs:(NSArray *)indexs andFromStyle:(SearchItemCellStyle)aStyle {
    if (indexs.count==0) {
        return;
    }
    if (aStyle ==SearchItemCellStyleType) {
        hotelfilters.hotel_type = [indexs[0] intValue];
        [hotelfilters.hotel_types addObject:@([indexs[0] intValue])];
    }else {
        hotelfilters.key_word = indexs[0];
        [hotelfilters.key_words addObject:indexs[0]];
    }
}


- (void)reset {
    
    hotelfilters.key_word = @"normal";
    hotelfilters.hotel_type=-1;
    
    FilterCityTableViewCell *cell_1 = (FilterCityTableViewCell *)[dataTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    index = [NSIndexPath indexPathForRow:0 inSection:0];
    [cell_1 setSelectedColor];
    FilterCityTableViewCell *cell_2 = (FilterCityTableViewCell *)[dataTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [cell_2 restoreTitleColor];
    FilterCityTableViewCell *cell_3 = (FilterCityTableViewCell *)[dataTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    [cell_3 restoreTitleColor];

    if (cellCash[@(SearchCellKeyPrice)]) {
        SearchSliderBarCell *cell = cellCash[@(SearchCellKeyPrice)];
        [cell reset];
    }
    if (cellCash[@(SearchCellKeyTable)]) {
        SearchSliderBarCell *cell = cellCash[@(SearchCellKeyTable)];
        [cell reset];
    }
    if (cellCash[@(SearchCellKeyType)]) {
        SearchItemCell *cell = cellCash[@(SearchCellKeyType)];
        [cell reset];
    }
    if (cellCash[@(SearchCellKeyItem)]) {
        SearchItemCell *cell = cellCash[@(SearchCellKeyItem)];
        [cell reset];
    }
    
}

- (void)doneBtnEvent {
    NSDictionary *dic = _array[index.row];
    hotelfilters.order_field = dic[@"id"];
    hotelfilters.index = index;
    if ([self.delegate respondsToSelector:@selector(didChooseScreening:)]) {
        [self.delegate didChooseScreening:hotelfilters];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidLayoutSubviews
{
    if ([dataTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [dataTableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([dataTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [dataTableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
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
