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
@property (nonatomic, strong) WTHotelFilters *filters;
@end

@implementation WTFilterHotelViewController
{
    UITableView *dataTableView;
    UIButton *resetBtn;
    UIButton *doneBtn;
    NSMutableDictionary *cellCash;
    NSArray *data;
    CGRect selfFrame;
    NSIndexPath *selectedIndex;
}

+ (instancetype)instanceVCWithFilters:(WTHotelFilters *)filters
{
	WTFilterHotelViewController *VC = [WTFilterHotelViewController new];
	VC.filters = filters ? : [[WTHotelFilters alloc] init] ;
	return VC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.array = @[@{@"id" : @"score",@"name" : @"综合排序"},
				   @{@"id" : @"collect_num",@"name" : @"按喜欢"},
				   @{@"id" : @"comment_num",@"name" : @"按评价"} ];
	data = @[@(SearchCellKeySynNormal),@(SearchCellKeySynLike),@(SearchCellKeySynComment),
			 @(SearchCellKeyTable),@(SearchCellKeyPrice),@(SearchCellKeyType),@(SearchCellKeyItem)];
	cellCash = [[NSMutableDictionary alloc] initWithCapacity:5];
	[self getSelectedIndex];
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)cancelAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)getSelectedIndex
{
	for (NSInteger i=0; i < _array.count; i++) {
		if([_array[i][@"id"] isEqualToString:_filters.order_field]){
			selectedIndex = [NSIndexPath indexPathForRow:i inSection:0];
			return ;
		}
	}
	selectedIndex = [NSIndexPath indexPathForRow:0 inSection:0];
}

- (void)initView
{
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
    
    dataTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, screenWidth,screenHeight - kNavBarHeight - kTabBarHeight)];
    dataTableView.backgroundColor = [UIColor clearColor];
    dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    dataTableView.backgroundView.backgroundColor = [UIColor clearColor];
    dataTableView.delegate = self;
    dataTableView.dataSource = self;
    [self.view addSubview:dataTableView];

	UIButton *conformView = [UIButton buttonWithType:UIButtonTypeSystem];
	conformView.frame = CGRectMake(0, screenHeight - kTabBarHeight, screenWidth, kTabBarHeight);
	conformView.backgroundColor = [WeddingTimeAppInfoManager instance].baseColor;
	[self.view addSubview:conformView];
	[conformView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	conformView.titleLabel.font = [UIFont systemFontOfSize:17];
	[conformView setTitle:@"确定" forState:UIControlStateNormal];
	[conformView addTarget:self action:@selector(doneBtnEvent) forControlEvents:UIControlEventTouchUpInside];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([data[indexPath.row] intValue]) {
        case SearchCellKeySynNormal:
        case SearchCellKeySynLike:
        case SearchCellKeySynComment: return 60 * Height_ato; break;
        case SearchCellKeyTable:
        case SearchCellKeyPrice: return SearchSliderBarCellHeigh; break;
        case SearchCellKeyItem: return [SearchItemCell getHeightWithStyle:SearchItemCellStyleItem];
        case SearchCellKeyType: return [SearchItemCell getHeightWithStyle:SearchItemCellStyleType];
        default:  break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch ([data[indexPath.row] intValue]) {
        case SearchCellKeySynNormal:{
            FilterCityTableViewCell *cell;
            if (cellCash[@(SearchCellKeySynNormal)]) {
                cell = cellCash[@(SearchCellKeySynNormal)];
            } else {
                cell = [tableView filterCityCell];
                [cell setInfo:_array[indexPath.row]];
                if (selectedIndex.row == indexPath.row) {
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
			}
			else {
                cell = [tableView filterCityCell];
                [cell setInfo:_array[indexPath.row]];
                if (selectedIndex.row == indexPath.row) {
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
                if (selectedIndex.row == indexPath.row) {
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
                [cell setLower:[_filters.desk_start floatValue] Upper:[_filters.desk_end floatValue]];
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
                [cell setLower:[_filters.price_start floatValue] Upper:[_filters.price_end floatValue]];
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

        default: break;
    }
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < 3) {
        if (selectedIndex) {
            FilterCityTableViewCell *cell = (FilterCityTableViewCell *)[tableView cellForRowAtIndexPath:selectedIndex];
            [cell restoreTitleColor];
        }
        FilterCityTableViewCell *cell = (FilterCityTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell setSelectedColor];
        selectedIndex = indexPath;
    } else {
        return;
    }
}
- (void)slideVauleDidChanged:(SearchSliderBarCellStyle)aStyle andleftValue:(int)lValue adnRightValue:(int)rValue {
    if (aStyle ==SearchSliderBarCellStyleTable) {
        _filters.desk_start = @(lValue);
        _filters.desk_end   = @(rValue);
    }else {
        _filters.price_start = @(lValue);
        _filters.price_end = @(rValue);
    }
}

- (void)SearchItemCellDidChangedIndexs:(NSArray *)indexs andFromStyle:(SearchItemCellStyle)aStyle {
    if (indexs.count==0) {
        return;
    }
    if (aStyle ==SearchItemCellStyleType) {
        _filters.hotel_type = indexs[0];
    }else {
        _filters.key_word = indexs[0];
    }
}

- (void)reset {

	_filters = [[WTHotelFilters alloc] init];

    FilterCityTableViewCell *cell_1 = (FilterCityTableViewCell *)[dataTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    selectedIndex = [NSIndexPath indexPathForRow:0 inSection:0];
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
    NSDictionary *dic = _array[selectedIndex.row];
    _filters.order_field = dic[@"id"];
    if ([self.delegate respondsToSelector:@selector(didChooseScreening:)]) {
        [self.delegate didChooseScreening:_filters];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

@implementation WTHotelFilters
- (instancetype)init
{
	self = [super init];
	if(self)
	{
		self.hotel_type = @(0);
		self.price_start = @(0);
		self.price_end = @(0);
		self.desk_start = @(0);
		self.desk_end = @(0);
		self.order_field = @"score";
		self.order = @"DESC";
		self.key_word = @"";
	}
	return self;
}
@end