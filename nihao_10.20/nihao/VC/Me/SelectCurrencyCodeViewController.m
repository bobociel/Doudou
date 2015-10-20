//
//  SelectCurrencyCodeViewController.m
//  nihao
//
//  Created by HelloWorld on 7/21/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "SelectCurrencyCodeViewController.h"
#import "BATableView.h"
#import "CurrencyCodeCell.h"
#import "CurrencyCode.h"
#import <MJExtension/MJExtension.h>

@interface SelectCurrencyCodeViewController () <BATableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UITableView *headerTableView;
@property (nonatomic, strong) UIButton *searchBtn;
@property (nonatomic, strong) BATableView *tableView;

@end

static NSInteger CELL_HEIGHT = 50;
static NSString *CELL_IDENTIFIER = @"CurrencyCodeCell";

@implementation SelectCurrencyCodeViewController {
	NSArray *currencyCodeArray;
	NSArray *commonCurrencyCodeArray;
	NSMutableArray *filteredArray;
	NSMutableDictionary *dic;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	self.title = @"Currency Code";
	
	UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
	self.navigationItem.leftBarButtonItem = cancelBtn;
	
	[self initViews];
	[self initDatas];
}

#pragma mark - Lifecycle

- (void)dealloc {
	[self.searchBtn removeTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
	self.searchBtn = nil;
	self.headerTableView.delegate = nil;
	self.headerTableView.dataSource = nil;
	self.headerTableView = nil;
	self.headerView = nil;
	self.tableView.delegate = nil;
	self.tableView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView DataSource

/**
 *  列表右侧字母表
 *
 *  @param tableView
 *
 *  @return
 */
- (NSArray *)sectionIndexTitlesForABELTableView:(BATableView *)tableView {
	return [self sortedKeys];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if(tableView == self.tableView.tableView) {
		return [dic allKeys].count;
	} else {
		return 1;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(tableView == self.tableView.tableView) {
		NSString *key = [self sortedKeys][section];
		NSArray *data = dic[key];
		return data.count;
	} else if(tableView == self.headerTableView) {
		return commonCurrencyCodeArray.count;
	} else {
		return filteredArray.count;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	CurrencyCodeCell *cell = (CurrencyCodeCell *)[tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
	
	CurrencyCode *currencyCode;
	if(tableView == self.tableView.tableView) {
		NSString *key = [self sortedKeys][indexPath.section];
		currencyCode = dic[key][indexPath.row];
	} else if(tableView == self.headerTableView) {
		currencyCode = commonCurrencyCodeArray[indexPath.row];
	} else {
		currencyCode = filteredArray[indexPath.row];
	}
	
	if (currencyCode) {
		cell.currencyCodeLabel.text = currencyCode.country_currency_code;
		cell.currencyNameLabel.text = [NSString stringWithFormat:@"%@ (%@)", currencyCode.country_currency_symbol, currencyCode.country_name_zh];
		
		return cell;
	} else {
		return nil;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if(tableView == self.tableView.tableView) {
		NSString *key = [dic allKeys][section];
		return key;
	} else {
		return nil;
	}
}

#pragma mark - TableView Delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	CurrencyCode *currencyCode;
	if(tableView == self.tableView.tableView) {
		NSString *key = [self sortedKeys][indexPath.section];
		currencyCode = dic[key][indexPath.row];
	} else if(tableView == self.headerTableView) {
		currencyCode = commonCurrencyCodeArray[indexPath.row];
	} else {
		currencyCode = filteredArray[indexPath.row];
	}
	
	NSLog(@"select currencyCode = %@", currencyCode);
	
	if (self.selectedCurrencyCode) {
		self.selectedCurrencyCode(self.selectCurrencyCodeType, currencyCode.country_currency_code);
	}

	[self cancel];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if(tableView == self.tableView.tableView) {
		return 30;
	} else {
		return 0;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if(tableView == self.tableView.tableView) {
		// 创建section的 headerView
		UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
		sectionView.backgroundColor = RootBackgroundWhitelyColor;
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, 10, 10)];
		label.text = [self sortedKeys][section];
		label.textColor = HomeCategoryUnSelectedTextColor;
		label.font = FontNeveLightWithSize(12.0);
		[label sizeToFit];
		[sectionView addSubview:label];
		
		return sectionView;
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

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
	[self.view bringSubviewToFront:self.tableView];
}

#pragma mark - Private

- (void) initViews {
	// 初始化 TableView HeaderView
	self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40 * 2 + CELL_HEIGHT * 10)];
	self.headerView.backgroundColor = [UIColor whiteColor];
	UIView *searchBtnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.headerView.frame), 40)];
	searchBtnView.backgroundColor = ColorF4F4F4;
	UIImage *searchBtnImage = [UIImage imageNamed:@"common_icon_search_gray"];
	self.searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	self.searchBtn.frame = CGRectMake(0, 0, CGRectGetWidth(searchBtnView.frame) - 15 * 2, 28);
	self.searchBtn.backgroundColor = [UIColor whiteColor];
	[self.searchBtn setImage:searchBtnImage forState:UIControlStateNormal];
	[self.searchBtn setTitle:@"Currency Code" forState:UIControlStateNormal];
	[self.searchBtn setTitleColor:HintTextColor forState:UIControlStateNormal];
	self.searchBtn.titleLabel.font = FontNeveLightWithSize(14.0);
	self.searchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	self.searchBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
	self.searchBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 9, 0, 0);
	[self.searchBtn addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
	[searchBtnView addSubview:self.searchBtn];
	self.searchBtn.center = searchBtnView.center;
	[self.headerView addSubview:searchBtnView];
	
	UILabel *commonLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, SCREEN_WIDTH - 15, 40)];
	commonLabel.backgroundColor = [UIColor whiteColor];
	commonLabel.textColor = TextFieldBeginEditingColor;
	commonLabel.text = @"Common Currency";
	commonLabel.font = FontNeveLightWithSize(14.0);
	[self.headerView addSubview:commonLabel];
	
	self.headerTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, SCREEN_WIDTH, CELL_HEIGHT * 10)];
	self.headerTableView.delegate = self;
	self.headerTableView.dataSource = self;
	self.headerTableView.rowHeight = CELL_HEIGHT;
	[self.headerTableView registerNib:[UINib nibWithNibName:@"CurrencyCodeCell" bundle:nil] forCellReuseIdentifier:CELL_IDENTIFIER];
	[self.headerView addSubview:self.headerTableView];
	
	UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 80, SCREEN_WIDTH, 0.5)];
	line.backgroundColor = SeparatorColor;
	[self.headerView addSubview:line];
	
	self.tableView = [[BATableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
	self.tableView.delegate = self;
	self.tableView.tableView.tableFooterView = [[UIView alloc] init];
	self.tableView.tableView.rowHeight = CELL_HEIGHT;
	[self.tableView.tableView registerNib:[UINib nibWithNibName:@"CurrencyCodeCell" bundle:nil] forCellReuseIdentifier:CELL_IDENTIFIER];
	self.tableView.tableView.tableHeaderView = self.headerView;
	[self.view addSubview:self.tableView];
	
	[self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"CurrencyCodeCell" bundle:nil] forCellReuseIdentifier:CELL_IDENTIFIER];
	self.searchDisplayController.searchResultsTableView.rowHeight = CELL_HEIGHT;
	self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
}

// 读取文件内容解析并初始化数据
- (void)initDatas {
	dic = [NSMutableDictionary dictionary];
	
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"country_currency_codes" ofType:@".txt"];
	NSData *tempData = [NSData dataWithContentsOfFile:filePath];
	NSDictionary *tempDict = [NSJSONSerialization JSONObjectWithData:tempData options:0 error:nil];
	currencyCodeArray = [CurrencyCode objectArrayWithKeyValuesArray:tempDict[@"codes"]];
	
	for(CurrencyCode *currencyCode in currencyCodeArray) {
		NSString *cCode = currencyCode.country_currency_code;
		// 取出首字符当作key，将国家币种放到对应的array里
		NSString *firstCharacter = [cCode substringWithRange:NSMakeRange(0, 1)];
		if([[dic allKeys] containsObject:firstCharacter]) {
			NSMutableArray *array = dic[firstCharacter];
			[array addObject:currencyCode];
		} else {
			NSMutableArray *array = [[NSMutableArray alloc] init];
			[array addObject:currencyCode];
			[dic setObject:array forKey:firstCharacter];
		}
	}
	
	filteredArray = [[NSMutableArray alloc] init];
	
	NSString *commonCCfilePath = [[NSBundle mainBundle] pathForResource:@"common_currency_codes" ofType:@".txt"];
	NSData *commonCCTempData = [NSData dataWithContentsOfFile:commonCCfilePath];
	NSDictionary *commonCCTempDict = [NSJSONSerialization JSONObjectWithData:commonCCTempData options:0 error:nil];
	commonCurrencyCodeArray = [CurrencyCode objectArrayWithKeyValuesArray:commonCCTempDict[@"codes"]];
	
	[self.tableView reloadData];
}

/**
 *  对字典的key按照字母从小到大进行排序
 *
 *  @return 排序后的key列表
 */
- (NSArray *) sortedKeys {
	NSArray *keys = [dic allKeys];
	NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
	}];
	return sortedArray;
}

#pragma mark Content Filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	// Update the filtered array based on the search text and scope.
	// Remove all objects from the filtered search array
	[filteredArray removeAllObjects];
	// Filter the array using NSPredicate
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"country_currency_code contains[cd] %@", searchText];
	[filteredArray removeAllObjects];
	[filteredArray addObjectsFromArray:[currencyCodeArray filteredArrayUsingPredicate:predicate]];
}

#pragma mark - Touch Events

- (void)cancel {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)search {
	[self.view bringSubviewToFront:self.searchBar];
	[self.searchBar becomeFirstResponder];
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
