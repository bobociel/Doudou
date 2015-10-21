//
//  SelectCountryCodeViewController.m
//  nihao
//
//  Created by HelloWorld on 7/8/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "SelectCountryCodeViewController.h"
#import "BATableView.h"
#import "CountryCodeCell.h"

@interface SelectCountryCodeViewController () <BATableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate> {
	NSArray *_countryCodeArray;
	NSMutableArray *_filteredData;
	NSMutableDictionary *_dic;
	
	BATableView *_baTable;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

static NSString *CellIdentifier = @"CountryCodeCell";

@implementation SelectCountryCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	self.title = @"Countries";
	
	UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
	self.navigationItem.leftBarButtonItem = cancelBtn;
	
	[self initViews];
	[self initDatas];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initViews {
	_baTable = [[BATableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_searchBar.frame), SCREEN_WIDTH, SCREEN_HEIGHT - CGRectGetMaxY(_searchBar.frame) - 64)];
	_baTable.delegate = self;
	_baTable.tableView.tableFooterView = [[UIView alloc] init];
	[_baTable.tableView registerNib:[UINib nibWithNibName:@"CountryCodeCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
	[self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"CountryCodeCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
	self.searchDisplayController.searchResultsTableView.rowHeight = _baTable.tableView.rowHeight;
	[self.view addSubview:_baTable];
	
	_dic = [NSMutableDictionary dictionary];
	self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
}

// 读取文件内容解析并初始化数据
- (void)initDatas {
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"country_codes" ofType:@".txt"];
	NSData *tempData = [NSData dataWithContentsOfFile:filePath];
	NSDictionary *tempDict = [NSJSONSerialization JSONObjectWithData:tempData options:0 error:nil];
	_countryCodeArray = [NSArray arrayWithArray:tempDict[@"codes"]];
	
	for(NSDictionary *country in _countryCodeArray) {
		NSString *countryName = country[@"country"];
		// 取出首字符当作key，将国籍放到对应的array里
		NSString *character = [countryName substringWithRange:NSMakeRange(0, 1)];
		if([[_dic allKeys] containsObject:character]) {
			NSMutableArray *array = _dic[character];
			[array addObject:country];
		} else {
			NSMutableArray *array = [NSMutableArray array];
			[array addObject:country];
			[_dic setObject:array forKey:character];
		}
	}
	
	_filteredData = [NSMutableArray arrayWithCapacity:_countryCodeArray.count];
	[_baTable reloadData];
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
	CountryCodeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	
	if(tableView  == _baTable.tableView) {
		NSString *key = [self sortedKeys][indexPath.section];
		NSDictionary *country =  _dic[key][indexPath.row];
		cell.countryNameLabel.text = country[@"country"];
		cell.countryCodeLabel.text = [NSString stringWithFormat:@"+%@", country[@"code"]];
	} else {
		NSDictionary *country = _filteredData[indexPath.row];
		cell.countryNameLabel.text = country[@"country"];
		cell.countryCodeLabel.text = [NSString stringWithFormat:@"+%@", country[@"code"]];
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
		NSString *codeString = [NSString stringWithFormat:@"+%@", values[indexPath.row][@"code"]];
		NSString *countryName = [NSString stringWithFormat:@"%@", values[indexPath.row][@"country"]];
		self.countryCodeSelected(countryName, codeString);
	} else {
		NSString *codeString = [NSString stringWithFormat:@"+%@", _filteredData[indexPath.row][@"code"]];
		NSString *countryName = [NSString stringWithFormat:@"%@", _filteredData[indexPath.row][@"country"]];
		self.countryCodeSelected(countryName, codeString);
	}
	
	[self cancel];
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

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	// Tells the table data source to reload when text changes
	[self filterContentForSearchText:searchString scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
	// Return YES to cause the search result table view to be reloaded.
	return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
	// Tells the table data source to reload when scope bar selection changes
	[self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
	// Return YES to cause the search result table view to be reloaded.
	return YES;
}

#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	// Update the filtered array based on the search text and scope.
	// Remove all objects from the filtered search array
	[_filteredData removeAllObjects];
	// Filter the array using NSPredicate
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"country contains[cd] %@", searchText];
	[_filteredData removeAllObjects];
	[_filteredData addObjectsFromArray:[_countryCodeArray filteredArrayUsingPredicate:predicate]];
}

- (void)cancel {
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
