//
//  NationalityViewController.m
//  nihao
//
//  Created by 刘志 on 15/6/10.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "NationalityViewController.h"
#import "Nationality.h"
#import "HttpManager.h"
#import "ListingLoadingStatusView.h"
#import <MJExtension.h>
#import "BATableView.h"

@interface NationalityViewController ()<BATableViewDelegate,UISearchBarDelegate, UISearchDisplayDelegate> {
    NSArray *_data;
    NSMutableArray *_filteredData;
    ListingLoadingStatusView *_statusView;
    NSMutableDictionary *_dic;
    
    BATableView *_baTable;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation NationalityViewController

static NSString *identifier = @"cellidentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self queryNations];
}

- (void) initViews {
    self.title = @"Nationality";
    _baTable = [[BATableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_searchBar.frame), SCREEN_WIDTH, SCREEN_HEIGHT - CGRectGetMaxY(_searchBar.frame) - 64)];
    _baTable.delegate = self;
    _baTable.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_baTable];
    
    _statusView = [[ListingLoadingStatusView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    __weak NationalityViewController *weakSelf = self;
    _statusView.refresh = ^{
        [weakSelf queryNations];
    };
    [self.view addSubview:_statusView];
    _dic = [NSMutableDictionary dictionary];
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
    
    if(_enterSource == CONTACTS_FILTER) {
        UIControl *allHeader = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        allHeader.backgroundColor = [UIColor whiteColor];
        UILabel *allLabel = [[UILabel alloc] init];
        allLabel.text = @"All";
        allLabel.font = FontWithSize(16.0);
        allLabel.textColor = [UIColor blackColor];
        [allLabel sizeToFit];
        allLabel.frame = CGRectMake(15, (44 - CGRectGetHeight(allLabel.frame)) / 2, CGRectGetWidth(allLabel.frame), CGRectGetHeight(allLabel.frame));
        [allHeader addSubview:allLabel];
        _baTable.tableView.tableHeaderView = allHeader;
        [allHeader addTarget:self action:@selector(allNationFilterChoosed) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void) allNationFilterChoosed {
    if(self.allNationhoosed) {
        self.allNationhoosed();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  查询所有国家
 */
- (void) queryNations {
    [_statusView showWithStatus:Loading];
    [HttpManager queryNations:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([responseObject[@"code"] integerValue] == 0) {
            [_statusView showWithStatus:Done];
            NSArray *array = responseObject[@"result"][@"items"];
            _data = [Nationality objectArrayWithKeyValuesArray:array];
            for(Nationality *nation in _data) {
                NSString *nationName = nation.country_name_en;
                //取出首字符当作key，将国籍放到对应的array里
                NSString *character = [nationName substringWithRange:NSMakeRange(0,1)];
                if([[_dic allKeys] containsObject:character]) {
                    NSMutableArray *array = _dic[character];
                    [array addObject:nation];
                } else {
                    NSMutableArray *array = [NSMutableArray array];
                    [array addObject:nation];
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
        Nationality *nation = _dic[key][indexPath.row];
        cell.textLabel.text = nation.country_name_en;
    } else {
        Nationality *nation = _filteredData[indexPath.row];
        cell.textLabel.text = nation.country_name_en;
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
        self.nationChoosed(values[indexPath.row]);
    } else {
        self.nationChoosed(_filteredData[indexPath.row]);
    }
    [self.navigationController popViewControllerAnimated:YES];
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
        label.text =  [self sortedKeys][section];
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"country_name_en contains[cd] %@",searchText];
    [_filteredData removeAllObjects];
    [_filteredData addObjectsFromArray:[_data filteredArrayUsingPredicate:predicate]];
}

@end
