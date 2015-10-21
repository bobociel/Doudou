//
//  LiveCitiesViewController.m
//  nihao
//
//  Created by 刘志 on 15/6/10.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "LiveCitiesViewController.h"
#import "ListingLoadingStatusView.h"
#import "City.h"
#import "HttpManager.h"
#import <MJExtension.h>
#import "BATableView.h"

@interface LiveCitiesViewController ()<UISearchBarDelegate,UISearchDisplayDelegate,BATableViewDelegate> {
    NSArray *_data;
    NSMutableArray *_filteredData;
    ListingLoadingStatusView *_statusView;
    NSMutableDictionary *_dic;
    BATableView *_baTable;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation LiveCitiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self queryCities];
}

/**
 *  控件初始化
 */
- (void) initViews {
	if (self.selectCityType == SelectCityTypeLiveCity) {
		self.title = @"City of Residence";
	} else if (self.selectCityType == SelectCityTypeAsk) {
		self.title = @"Select City";
		UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
		self.navigationItem.leftBarButtonItem = cancelItem;
	}
	
    _baTable = [[BATableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_searchBar.frame), SCREEN_WIDTH, SCREEN_HEIGHT - CGRectGetMaxY(_searchBar.frame) - 64)];
    _baTable.delegate = self;
    _baTable.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_baTable];
    
    _statusView = [[ListingLoadingStatusView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    __weak LiveCitiesViewController *weakSelf = self;
    _statusView.refresh = ^{
        [weakSelf queryCities];
    };
    [self.view addSubview:_statusView];
    _dic = [NSMutableDictionary dictionary];
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
}

/**
 *  查询所有城市
 */
- (void) queryCities {
    [_statusView showWithStatus:Loading];
    [HttpManager queryLiveCities:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([responseObject[@"code"] integerValue] == 0) {
            [_statusView showWithStatus:Done];
            NSArray *array = responseObject[@"result"][@"items"];
            _data = [City objectArrayWithKeyValuesArray:array];
            for(City *city in _data) {
                NSString *cityName = city.city_name_en;
                //取出首字符当作key，将国籍放到对应的array里
                NSString *character = [cityName substringWithRange:NSMakeRange(0, 1)];
                if([[_dic allKeys] containsObject:character]) {
                    NSMutableArray *array = _dic[character];
                    [array addObject:city];
                } else {
                    NSMutableArray *array = [NSMutableArray array];
                    [array addObject:city];
                    [_dic setObject:array forKey:character];
                }
            }
            
            _filteredData = [NSMutableArray arrayWithCapacity:_data.count];
            [_baTable reloadData];
		} else {
			[self processServerErrorWithCode:[responseObject[@"code"] integerValue] andErrorMsg:[responseObject objectForKey:@"message"]];
		}
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_statusView showWithStatus:NetErr];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 *  对字典的key按照字母从小到大进行排序
 *
 *  @return 排序后的key列表
 */
- (NSArray *) sortedKeys {
    NSArray *keys = [_dic allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    return sortedArray;
}

- (void)cancel {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

/**
 *  列表右侧字母表
 *
 *  @param tableView
 *
 *  @return
 */
- (NSArray *) sectionIndexTitlesForABELTableView:(BATableView *)tableView {
    return [self sortedKeys];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(tableView == _baTable.tableView) {
        return [_dic allKeys].count;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == _baTable.tableView) {
        NSString *key = [self sortedKeys][section];
        NSArray *data = _dic[key];
        return data.count;
    } else {
        return _filteredData.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cellidentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if(tableView  == _baTable.tableView) {
        NSString *key = [self sortedKeys][indexPath.section];
        City *city =  _dic[key][indexPath.row];
        cell.textLabel.text = city.city_name_en;
    } else {
        City *city = _filteredData[indexPath.row];
        cell.textLabel.text = city.city_name_en;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(tableView == _baTable.tableView) {
        NSString *key = [_dic allKeys][section];
        return key;
    } else {
        return nil;
    }
}

#pragma mark - tableview delegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(tableView == _baTable.tableView) {
        NSArray *keys = [self sortedKeys];
        NSString *key = keys[indexPath.section];
        NSArray *values = _dic[key];
        self.cityChoosed(values[indexPath.row]);
    } else {
        self.cityChoosed(_filteredData[indexPath.row]);
    }
	
	if (self.selectCityType == SelectCityTypeLiveCity) {
		[self.navigationController popViewControllerAnimated:YES];
	} else if (self.selectCityType == SelectCityTypeAsk) {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(tableView == _baTable.tableView) {
        return 30;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(tableView == _baTable.tableView) {
        //创建section的header view
        UIView *headerSection = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        headerSection.backgroundColor = ColorWithRGB(250, 250, 250);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, 10, 10)];
        label.text = [self sortedKeys][section];
        label.textColor = [UIColor colorWithRed:120.0 / 255 green:120.0 / 255 blue:120.0 / 255 alpha:1.0];
        label.font = [UIFont systemFontOfSize:12];
        [label sizeToFit];
        [headerSection addSubview:label];
        UIView *lineBottomSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, 28, CGRectGetWidth(self.view.frame), 0.5)];
        lineBottomSeperator.backgroundColor = [UIColor colorWithRed:200.0 / 255 green:199.0 / 255 blue:204.0 / 255 alpha:1];
        [headerSection addSubview:lineBottomSeperator];
        
        UIView *lineTopSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 0.5)];
        lineTopSeperator.backgroundColor = [UIColor colorWithRed:200.0 / 255 green:199.0 / 255 blue:204.0 / 255 alpha:1];
        [headerSection addSubview:lineTopSeperator];
        return headerSection;
    } else {
        return nil;
    }
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [_filteredData removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"city_name_en contains[cd] %@",searchText];
    [_filteredData removeAllObjects];
    [_filteredData addObjectsFromArray:[_data filteredArrayUsingPredicate:predicate]];
}

@end
