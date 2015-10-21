//
//  MerchantListViewController.m
//  nihao
//
//  Created by HelloWorld on 6/3/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "MerchantListViewController.h"
#import "FSDropDownMenu.h"
#import "MerchantCell.h"
#import "HttpManager.h"
#import "City.h"
#import "AppConfigure.h"
#import "MerchantDetailsViewController.h"
#import "ListingLoadingStatusView.h"
#import "BaseFunction.h"
#import "SearchShopViewController.h"
#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>
#import "Merchant.h"

#define TAG_NEARBY 1001
#define TAG_CATEGORY 1002

@interface MerchantListViewController () <UITableViewDelegate, UITableViewDataSource, FSDropDownMenuDataSource, FSDropDownMenuDelegate> {
    ListingLoadingStatusView *_loadingStatus;
}

@property (weak, nonatomic) IBOutlet UIView *topOptionsView;
@property (weak, nonatomic) IBOutlet UIImageView *nearbyTriangleImg;
@property (weak, nonatomic) IBOutlet UIImageView *categoryTriangleImg;
@property (weak, nonatomic) IBOutlet UILabel *nearbyLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) FSDropDownMenu *nearbyMenu;
@property (strong, nonatomic) FSDropDownMenu *cateMenu;

@end

static NSString *CellReuseIdentifier = @"MerchantCell";

@implementation MerchantListViewController {
    // 商户列表
    NSMutableArray *merchantsArray;
    // Nearby下拉选择左列表
    NSMutableArray *nearbyLeftArr;
    // Nearby下拉选择右列表
    NSMutableArray *nearbyRightArr;
    // Nearby下拉选择当前选择的右列表
    NSMutableArray *nearbyCurrentRightArr;
    // 分类下拉选择左列表
    NSMutableArray *cateLeftArr;
    // 分类下拉选择右列表
    NSMutableArray *cateRightArr;
    // 分类下拉选择当前选择的右列表
    NSMutableArray *cateCurrentRightArr;
    // 定位城市和选择的城市相同时显示的Nearby
    NSDictionary *nearbyDictionary;
    // 定位城市和选择的城市相同时显示的Nearby右列表
    NSArray *nearbyRightArray;
    // 初始时的过滤器
    MyMerchantListFilter *firstListFilter;
    // 根据用户的选择创建的过滤器
    MyMerchantListFilter *userListFilter;
    // 是否添加Nearby标记
    BOOL hasNearby;
}

#pragma mark - view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"---------%ld",(long)self.currentOneLevelMhcID);

//    if (0==self.currentOneLevelMhcID) {
//        for (UIView *view in [self.view subviews])
//        {
//            if ([view isKindOfClass:[UIView class]])
//            {
//                [view removeFromSuperview];
//            }
//        }
//    }
    
	self.view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:16.0];
    label.textColor = [UIColor whiteColor];
    label.text = self.categoryTitle;
    [label sizeToFit];
    self.navigationItem.titleView = label;
    
    self.categoryLabel.text = self.categoryTitle;
    
    // 不显示返回按钮上的文字
    [self dontShowBackButtonTitle];
    self.tableView.rowHeight = 86.0;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:@"MerchantCell" bundle:nil] forCellReuseIdentifier:CellReuseIdentifier];
    merchantsArray = [[NSMutableArray alloc] init];
    
    UIImage *searchImage = [UIImage imageNamed:@"nav_search_btn_img"];
    // 设置导航栏按钮的点击执行方法等
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithImage:searchImage style:UIBarButtonItemStylePlain target:self action:@selector(searchBtnClick:)];
    NSArray *rightButtonItems = @[searchItem];
    self.navigationItem.rightBarButtonItems = rightButtonItems;
    
    [self drawLines];
    
    // 初始化Nearby下拉选择视图
    self.nearbyMenu = [[FSDropDownMenu alloc] initWithOrigin:CGPointMake(0, self.nearbyLabel.frame.size.height) andHeight:333];
    self.nearbyMenu.transformView = self.nearbyTriangleImg;
    self.nearbyMenu.tag = TAG_NEARBY;
    self.nearbyMenu.dataSource = self;
    self.nearbyMenu.delegate = self;
    [self.view addSubview:self.nearbyMenu];
    // 初始化分类下拉选择视图
    self.cateMenu = [[FSDropDownMenu alloc] initWithOrigin:CGPointMake(0, self.categoryLabel.frame.size.height) andHeight:350];
    self.cateMenu.transformView = self.categoryTriangleImg;
    self.cateMenu.tag = TAG_CATEGORY;
    self.cateMenu.dataSource = self;
    self.cateMenu.delegate = self;
    [self.view addSubview:self.cateMenu];
    
    nearbyDictionary = [NSDictionary dictionaryWithObjects:@[@"Nearby", @"附近"] forKeys:@[@"district_name_en", @"district_name"]];
	NSDictionary *nearbyRight0 = [NSDictionary dictionaryWithObjects:@[@"All", @"全部"] forKeys:@[@"bid_name_en", @"bid_name"]];
    NSDictionary *nearbyRight1 = [NSDictionary dictionaryWithObjects:@[@"500M", @"500M"] forKeys:@[@"bid_name_en", @"bid_name"]];
    NSDictionary *nearbyRight2 = [NSDictionary dictionaryWithObjects:@[@"1KM", @"1KM"] forKeys:@[@"bid_name_en", @"bid_name"]];
    NSDictionary *nearbyRight3 = [NSDictionary dictionaryWithObjects:@[@"2KM", @"2KM"] forKeys:@[@"bid_name_en", @"bid_name"]];
    NSDictionary *nearbyRight4 = [NSDictionary dictionaryWithObjects:@[@"5KM", @"5KM"] forKeys:@[@"bid_name_en", @"bid_name"]];
    NSDictionary *nearbyRight5 = [NSDictionary dictionaryWithObjects:@[@"10KM", @"10KM"] forKeys:@[@"bid_name_en", @"bid_name"]];
    nearbyRightArray = [NSArray arrayWithObjects:nearbyRight0, nearbyRight1, nearbyRight2, nearbyRight3, nearbyRight4, nearbyRight5, nil];
	
	firstListFilter = [[MyMerchantListFilter alloc] initWithOneLevelMhcID:self.currentOneLevelMhcID];
	if ([self isLocateCitySameAsSelectedCity]) {
		firstListFilter.latitude = self.coordinate.latitude;
		firstListFilter.longitude = self.coordinate.longitude;
	} else {
		self.nearbyLabel.text = @"District";
	}
	firstListFilter.mhiCityName = [City getCityFromUserDefault:CURRENT_CITY].city_name;
	
	self.topOptionsView.userInteractionEnabled = NO;

//    if (self.coordinate.latitude != 0) {
//        self.nearbyLabel.text = @"5KM";
//        firstListFilter.distance = 5000;
//    }
	
    userListFilter = [[MyMerchantListFilter alloc] initWithFilter:firstListFilter];
    
    [self initLoadingStatus];
    [self requestMerchantListByFilter:firstListFilter];
    [self requestFilterList];
    
    [BaseFunction addRefreshHeaderAndFooter:self.tableView refreshAction:@selector(refreshMerchantList) loadMoreAction:@selector(loadMoreMerchantList) target:self];
    self.tableView.footer.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
//	self.navigationController.edgesForExtendedLayout = UIRectEdgeAll;
//	self.navigationController.navigationBar.translucent = YES;
//	self.navigationController.navigationBarBackgroundAlpha = 1;
	[_loadingStatus showWithStatus:Loading];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
//	self.navigationController.navigationBarBackgroundAlpha = 1;
}

- (void)initLoadingStatus {
    _loadingStatus = [[ListingLoadingStatusView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    __weak MerchantListViewController *weakSelf = self;
    __weak MyMerchantListFilter *weakFirstListFilter = firstListFilter;
    _loadingStatus.refresh = ^() {
        [weakSelf requestMerchantListByFilter:weakFirstListFilter];
    };
    [self.view addSubview:_loadingStatus];
}

#pragma mark - network request functions
#pragma mark 获取商家列表
- (void)requestMerchantListByFilter:(MyMerchantListFilter *)filter {
    [HttpManager requestMerchantListByFilter:filter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"JSON: %@", responseObject);
        NSDictionary *resultDict = (NSDictionary *)responseObject;
//        NSLog(@"商家列表 resultDict: %@", resultDict);
        NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
        NSInteger merchantCount = 0;
        if (rtnCode == 0) {
            if (userListFilter.page == 1) {// 刷新或者第一次加载列表
				[merchantsArray removeAllObjects];
//                merchantsArray = [(NSArray *)[[resultDict objectForKey:@"result"] objectForKey:@"rows"] mutableCopy];
            } else {// 分页加载非第一页数据
//                NSArray *moreMerchantArray = [[resultDict objectForKey:@"result"] objectForKey:@"rows"];
            }
			NSArray *moreMerchantArray = [Merchant objectArrayWithKeyValuesArray:[[resultDict objectForKey:@"result"] objectForKey:@"rows"]];
			merchantCount = moreMerchantArray.count;
			[merchantsArray addObjectsFromArray:moreMerchantArray];
			
            // 还能获取更多数据
            if (merchantCount >= DEFAULT_REQUEST_DATA_ROWS_INT) {
                self.tableView.footer.hidden = NO;
            } else {// 已经获取全部数据
                self.tableView.footer.hidden = YES;
            }
            // 如果列表有数据
            if (merchantsArray.count > 0) {
                [_loadingStatus showWithStatus:Done];
                self.tableView.header.hidden = NO;
            } else {// 如果列表没有数据
                if (!_loadingStatus.superview) {
                    [self.view addSubview:_loadingStatus];
                }
                [_loadingStatus showWithStatus:Empty];
                [_loadingStatus setEmptyImage:@"icon_no_shop" emptyContent:@"No result,recommend us a place you like" imageSize:NO_SHOP];
                self.tableView.footer.hidden = YES;
                self.tableView.header.hidden = YES;
            }
            
            if (self.tableView.footer.isRefreshing) {
                [self.tableView.footer endRefreshing];
            }
            if (self.tableView.header.isRefreshing) {
                [self.tableView.header endRefreshing];
            }
            
            [self.tableView reloadData];
		}else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_loadingStatus showWithStatus:NetErr];
    }];
}

#pragma mark 获取筛选列表
- (void)requestFilterList {
    City *city = [City getCityFromUserDefault:CURRENT_CITY];
    NSLog(@"city name--->%@",city.city_name);
    NSString *cityID = [NSString stringWithFormat:@"%d", [City getCityFromUserDefault:CURRENT_CITY].city_id];
    NSString *mhcID = [NSString stringWithFormat:@"%ld", self.currentOneLevelMhcID];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[cityID, mhcID] forKeys:@[@"city_id", @"mhc_pid"]];
    NSLog(@"parameters = %@", parameters);
    [HttpManager requestFilterListWithParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
            NSDictionary *resultDict = (NSDictionary *)responseObject;
            NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
            if (rtnCode == 0) {
				self.topOptionsView.userInteractionEnabled = YES;
								
                nearbyLeftArr = [[NSMutableArray alloc] init];
                nearbyRightArr = [[NSMutableArray alloc] init];
                // 如果定位的城市与用户选择的城市相同的话，就显示Nearby下的Nearby行
                if ([self isLocateCitySameAsSelectedCity]) {
                    [nearbyLeftArr addObject:nearbyDictionary];
                    [nearbyRightArr addObject:nearbyRightArray];
                    hasNearby = YES;
                } else {
                    hasNearby = NO;
                }
                NSArray *districtAndBusinessDistrictListResult = [[resultDict objectForKey:@"result"] objectForKey:@"districtAndBusinessDistrictListResult"];
                for (NSDictionary *district in districtAndBusinessDistrictListResult) {
                    [nearbyLeftArr addObject:district];
                    NSMutableArray *businessDistrictResult = [[district objectForKey:@"businessDistrictResult"] mutableCopy];
                    [businessDistrictResult insertObject:[NSDictionary dictionaryWithObjects:@[@"-1", @"All", @"全部"] forKeys:@[@"bid_id", @"bid_name_en", @"bid_name"]] atIndex:0];
                    [nearbyRightArr addObject:businessDistrictResult];
                }
                
                cateLeftArr = [[NSMutableArray alloc] init];
                cateRightArr = [[NSMutableArray alloc] init];
                NSArray *twoAndThreeLevelMerchantsCategoryListResult = [[resultDict objectForKey:@"result"] objectForKey:@"twoAndThreeLevelMerchantsCategoryListResult"];
                for (NSDictionary *twoLevel in twoAndThreeLevelMerchantsCategoryListResult) {
                    [cateLeftArr addObject:twoLevel];
                    NSMutableArray *threeLevelResult = [[twoLevel objectForKey:@"threeLevelResult"] mutableCopy];
                    [threeLevelResult insertObject:[NSDictionary dictionaryWithObjects:@[@-1, @"All"] forKeys:@[@"mhc_id", @"mhc_name"]] atIndex:0];
                    [cateRightArr addObject:threeLevelResult];
                }
            }
        });
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)refreshMerchantList {
    userListFilter.page = 1;
    [self requestMerchantListByFilter:userListFilter];
}

- (void)loadMoreMerchantList {
    userListFilter.page += 1;
    [self requestMerchantListByFilter:userListFilter];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return merchantsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = (int)indexPath.row;
//    static BOOL nibsRegistered = NO;
    // 通过标识来获取列表cell
    MerchantCell *cell = (MerchantCell *)[tableView dequeueReusableCellWithIdentifier:CellReuseIdentifier forIndexPath:indexPath];
    
    [cell initCellWithMerchantData:[merchantsArray objectAtIndex:row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self openMerchantDetailViewControllerWithMerchant:merchantsArray[indexPath.row]];
}

#pragma mark - click events
- (void)searchBtnClick:(id)sender {
    SearchShopViewController *controller = [[SearchShopViewController alloc] initWithNibName:@"SearchShopViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)nearbyClick:(id)sender {
    if (self.cateMenu.isShow) {
        [self.cateMenu hide];
    }
    [self btnPressedWithTag:TAG_NEARBY];
}

- (IBAction)categoryClick:(id)sender {
    if (self.nearbyMenu.isShow) {
        [self.nearbyMenu hide];
    }
    [self btnPressedWithTag:TAG_CATEGORY];
}

- (void)btnPressedWithTag:(NSInteger)tag {
    FSDropDownMenu *menu = (FSDropDownMenu*)[self.view viewWithTag:tag];
    [UIView animateWithDuration:0.2 animations:^{
        
    } completion:^(BOOL finished) {
        [menu menuTapped];
    }];
}

// 跳转到商户详情界面
- (void)openMerchantDetailViewControllerWithMerchant:(Merchant *)merchant {
    MerchantDetailsViewController *merchantDetailsViewController = [[MerchantDetailsViewController alloc] init];
    merchantDetailsViewController.merchantInfo = merchant;
//	merchantDetailsViewController.navigationBarBackgroundHidden = YES;
    [self.navigationController pushViewController:merchantDetailsViewController animated:YES];
}

#pragma mark - FSDropDown datasource & delegate
- (NSInteger)menu:(FSDropDownMenu *)menu tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section{
    if (menu.tag == TAG_NEARBY) {
        if (tableView == menu.rightTableView) {
            return nearbyCurrentRightArr.count;
        }else{
            return nearbyLeftArr.count;
        }
    } else if (menu.tag == TAG_CATEGORY) {
        if (tableView == menu.rightTableView) {
            return cateCurrentRightArr.count;
        }else{
            return cateLeftArr.count;
        }
    }
    
    return 0;
}
- (NSString *)menu:(FSDropDownMenu *)menu tableView:(UITableView*)tableView titleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (menu.tag == TAG_NEARBY) {
        if (tableView == menu.rightTableView) {
            return [nearbyCurrentRightArr[indexPath.row] objectForKey:@"bid_name_en"];
        }else{
            return [nearbyLeftArr[indexPath.row] objectForKey:@"district_name_en"];
        }
    } else if (menu.tag == TAG_CATEGORY) {
        if (tableView == menu.rightTableView) {
            return [cateCurrentRightArr[indexPath.row] objectForKey:@"mhc_name"];
        }else{
            return [cateLeftArr[indexPath.row] objectForKey:@"mhc_name"];
        }
    }
    
    return @"nil";
}

- (void)menu:(FSDropDownMenu *)menu tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (menu.currentSelectedLeftRow != 0) {
		[menu.leftTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
	}
    if (menu.tag == TAG_NEARBY) {
        if (tableView == menu.leftTableView) {
            if (nearbyRightArr.count > indexPath.row) {
                nearbyCurrentRightArr = nearbyRightArr[indexPath.row];
                [menu.rightTableView reloadData];
            }
        } else {
            if (nearbyCurrentRightArr.count > indexPath.row) {
                NSString *itemString = @"";
//                NSLog(@"nearby current select %@", nearbyCurrentRightArr[indexPath.row]);
                NSString *districtName = [[nearbyLeftArr objectAtIndex:menu.lastChooseLeftRow] objectForKey:@"district_name_en"];
                if (menu.lastChooseLeftRow == 0 && [@"Nearby" isEqualToString:districtName]) {
                    long dis = [BaseFunction getDistanceFromSelectedNearby:[nearbyCurrentRightArr[indexPath.row] objectForKey:@"bid_name_en"]];
                    itemString = [nearbyCurrentRightArr[indexPath.row] objectForKey:@"bid_name_en"];
                    userListFilter.distance = dis;
                    userListFilter.mhiDistrictName = @"";
                } else {
                    NSString *bid = [nearbyCurrentRightArr[indexPath.row] objectForKey:@"bid_id"];
                    if ([bid integerValue] == -1) {// All
                        NSDictionary *lastLeftChooseDistrict = [nearbyLeftArr objectAtIndex:menu.lastChooseLeftRow];
                        userListFilter.mhiDistrictName = [lastLeftChooseDistrict objectForKey:@"district_name"];
                        userListFilter.mhiBidId = 0;
                        itemString = [lastLeftChooseDistrict objectForKey:@"district_name_en"];
                    } else {
                        userListFilter.mhiBidId = [bid integerValue];
                        itemString = [nearbyCurrentRightArr[indexPath.row] objectForKey:@"bid_name_en"];
                    }
                    userListFilter.distance = 0;
                }
                [self resetItemSizeByString:itemString withTag:menu.tag];
                userListFilter.page = 1;
                [self requestMerchantListByFilter:userListFilter];
            }
        }
    } else if (menu.tag == TAG_CATEGORY) {
        if(tableView == menu.leftTableView){
            if (cateRightArr.count > indexPath.row) {
                cateCurrentRightArr = cateRightArr[indexPath.row];
                [menu.rightTableView reloadData];
            }
        } else {
            if (cateCurrentRightArr.count > indexPath.row) {
                NSString *itemString = @"";
//                NSLog(@"cate current select %@", cateCurrentRightArr[indexPath.row]);
                NSInteger threeLevelMhcId = [(NSNumber *)[cateCurrentRightArr[indexPath.row] objectForKey:@"mhc_id"] integerValue];
                NSInteger twoLevelMhcId = [(NSNumber *)[[cateCurrentRightArr lastObject] objectForKey:@"mhc_pid"] integerValue];
                
                userListFilter.twoLevelMhcID = twoLevelMhcId;
                if (threeLevelMhcId == -1) {// All
//                    userListFilter.twoLevelMhcID = twoLevelMhcId;
                    userListFilter.threeLevelMhcID = 0;
                    NSDictionary *lastLeftChooseDistrict = [cateLeftArr objectAtIndex:menu.lastChooseLeftRow];
                    itemString = [lastLeftChooseDistrict objectForKey:@"mhc_name"];
                } else {
//                    userListFilter.twoLevelMhcID = twoLevelMhcId;
                    userListFilter.threeLevelMhcID = threeLevelMhcId;
                    itemString = [cateCurrentRightArr[indexPath.row] objectForKey:@"mhc_name"];
                }
                [self resetItemSizeByString:itemString withTag:menu.tag];
                [self requestMerchantListByFilter:userListFilter];
            }
        }
    }
}

#pragma mark - reset button size
- (void)resetItemSizeByString:(NSString*)string withTag:(NSInteger)tag {
    if (tag == TAG_NEARBY) {
        self.nearbyLabel.text = string;
    } else if (tag == TAG_CATEGORY) {
        self.categoryLabel.text = string;
    }
}

#pragma mark - other functions
- (void)drawLines {
	UIView *topOptionsVLine = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2.0, 10, 0.5, CGRectGetHeight(self.topOptionsView.frame) - 20)];
	topOptionsVLine.backgroundColor = SeparatorColor;
	[self.topOptionsView addSubview:topOptionsVLine];
	
    UIView *topOptionsViewBottomHLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.topOptionsView.frame) - 0.5, SCREEN_WIDTH, 0.5f)];
    topOptionsViewBottomHLine.backgroundColor = SeparatorColor;
    [self.topOptionsView addSubview:topOptionsViewBottomHLine];
}

- (BOOL)isLocateCitySameAsSelectedCity {
	NSString *selectedCityName = [City getCityFromUserDefault:CURRENT_CITY].city_name_en;
	selectedCityName = [selectedCityName stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSString *locateCityName = [AppConfigure objectForKey:LOCATE_CITY];
	NSLog(@"selectedCityName = %@, locateCityName = %@", selectedCityName, locateCityName);
	
	if ([selectedCityName compare:locateCityName options:NSCaseInsensitiveSearch] == NSOrderedSame) {
		return YES;
	} else {
		return NO;
	}
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
