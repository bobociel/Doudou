//
//  FindViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/9/22.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTFindViewController.h"
#import "WTSHContainerViewController.h"
#import "WTInspirationCategoryViewController.h"
#import "WTSupplierViewController.h"
#import "WTInspiretionListViewController.h"
#import "WTWorksDetailViewController.h"
#import "WTFilterCityViewController.h"
#import "WTSearchViewController.h"
#import "WTChatListViewController.h"
#import "FindTableViewCell.h"
#import "WTTopView.h"
#import "NetworkManager.h"
#import "UserInfoManager.h"
#import "LWUtil.h"
#import "SQLiteAssister.h"
#import "LWAssistUtil.h"
#import "GetService.h"
#import "MJRefresh.h"
#import "LocationManager.h"
#import "CellAnimation.h"
#define kItemWidth (screenWidth / 4.5)
#define kScrollViewH 56
#define kScrollViewY (screenHeight - kTabBarHeight - kScrollViewH)
@interface WTFindViewController ()<UITableViewDataSource, UITableViewDelegate, FilterSelectDelegate, LocationManagerDelegate,WTTopViewDelegate>
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSMutableArray *categoryArray;
@property (nonatomic, strong) UITableView    *tableView;
@property (nonatomic, strong) UIScrollView   *scrollView;
@property (nonatomic, strong) WTTopView *topView;
@property (nonatomic,assign) double preContentOffsetY;
@end
@implementation WTFindViewController
{
    LocationManager *locationManager;
    NSString *city_id;
    BOOL ifUpDrag;
    int page;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
	[self.topView removeFromSuperview];
	[self.view addSubview:_topView];
	_topView.unreadCount = [[ConversationStore sharedInstance] conversationUnreadCountAll];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.array = [NSMutableArray array];

    city_id = [LWUtil getString:@([UserInfoManager instance].curCityId) andDefaultStr:@"141"];

    int64_t nowDate = [[NSDate date] timeIntervalSince1970];

    [self loadLocalDataWithCityId:city_id Time:nowDate limit:10];
    [self initView];
    [self reconcileDataWithBlock:nil footerTime:0];
    [self initRefresh];
    
	locationManager = [[LocationManager alloc] init];
	locationManager.delegate = self;
	[locationManager beginSearch];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unreadNumUpdateNotificationAction:) name:unreadNumUpdateNotification object:nil];
}

- (void)initRefresh
{
    __weak UIScrollView *scrollView = self.tableView;
    scrollView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        int64_t nowDate = 0;
        if (_array.count > 0) {
            for (FindItemModel *find in _array) {
                if (nowDate == 0) {
                    nowDate = find.update_time;
                } else {
                    if (find.update_time < nowDate) {
                        nowDate = find.update_time;
                    }
                }
            }
        } else{
            nowDate = [[NSDate date] timeIntervalSince1970];
        }
        ifUpDrag = YES;
        [self loadLocalDataWithCityId:city_id Time:nowDate limit:10];
        [self reconcileDataWithBlock:nil footerTime:nowDate];
    }];
    
    scrollView.header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
        ifUpDrag = NO;
        page = 0;
        [self reconcileDataWithBlock:nil footerTime:0];
    }];
}

- (void)cityFilterHasSelectWithInfo:(id)info index:(NSIndexPath *)index
{
    WS(ws);
    [NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];
    city_id = info;
	[UserInfoManager instance].curCityId = city_id.intValue;
	[[UserInfoManager instance] saveToUserDefaults];
    self.array = [NSMutableArray array];
    int64_t nowDate = [[NSDate date] timeIntervalSince1970];
    [self loadLocalDataWithCityId:city_id Time:nowDate limit:10];
    [self reconcileDataWithBlock:^{
        if (ws.array.count > 0) {
            [ws.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]  atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        
    } footerTime:0];
}

#pragma mark - Action
-(void)unreadNumUpdateNotificationAction:(NSNotification*)not
{
	self.topView.unreadCount = [not.userInfo[key_unread] doubleValue] ;
}

- (void)topView:(WTTopView *)topView didSelectedCityFilter:(UIControl *)likeButton
{
	WTFilterCityViewController *filter = [[WTFilterCityViewController alloc] init];
	filter.delegate = self;
	filter.type = WTFliterTypeCity;
	filter.synOrCityID = @([UserInfoManager instance].curCityId).stringValue;
	[self presentViewController:filter animated:YES completion:nil];
}

- (void)topView:(WTTopView *)topView didSelectedSearch:(UIControl *)likeButton
{
	[self.navigationController pushViewController:[WTSearchViewController instanceSearchVCWithType:SearchTypeSupplier] animated:YES];
}

- (void)topView:(WTTopView *)topView didSelectedChat:(UIControl *)chatButton
{
	[self.navigationController pushViewController:[WTChatListViewController new] animated:YES];
}

- (void)loadLocalDataWithCityId:(NSString *)city Time:(int64_t)time limit:(int)limit
{
    SQLiteAssister *sqlite = [SQLiteAssister sharedInstance];
    WS(ws);
    void(^callback)(NSArray *array, NSError *error) = ^(NSArray *array, NSError *error) {
        if (ifUpDrag) {
            [ws.array addObjectsFromArray:array];
        } else{
            ws.array = [NSMutableArray arrayWithArray:array];
        }
        if (city.intValue != 0) {
            [sqlite pullItemsForCityId:@"0" timestamp:time limit:limit callback:^(NSArray *array, NSError *error) {
                [ws.array addObjectsFromArray:array];
            }];
        }
        ws.array = [NSMutableArray arrayWithArray:[self bunbleSortWithArray:ws.array]];
    };
    if (city.intValue == 0) {
        [sqlite pullItemsForAllCityWithtimestamp:time limit:limit callback:^(NSArray *array, NSError *error) {
            if (ifUpDrag) {
                [ws.array addObjectsFromArray:array];
            } else{
                ws.array = [NSMutableArray arrayWithArray:array];
            }
        }];
    } else {
        [sqlite pullItemsForCityId:city timestamp:time limit:limit callback:callback];
    }
    
    [_tableView.footer endRefreshing];
    [_tableView.header endRefreshing];
}


-(void)swapWithData:(NSMutableArray *)aData index1:(NSInteger)index1 index2:(NSInteger)index2{
    NSNumber *tmp = [aData objectAtIndex:index1];
    [aData replaceObjectAtIndex:index1 withObject:[aData objectAtIndex:index2]];
    [aData replaceObjectAtIndex:index2 withObject:tmp];
}

-(NSArray *)bunbleSortWithArray:(NSArray *)aData{
    NSMutableArray *array = [[NSMutableArray alloc]initWithArray:aData];
    if (array.count == 0) {
        return array;
    }
    for (int i=0; i<[array count]-1; i++) {
        for (int j =0; j<[array count]-1-i; j++) {
            FindItemModel *listj = [array objectAtIndex:j];
            FindItemModel *listJ = [array objectAtIndex:j+1];
            if (listj.update_time < listJ.update_time) {
                [self swapWithData:array index1:j index2:j+1];
            }
        }
    }
    return array;
}

- (void)reconcileDataWithBlock:(void(^)())block footerTime:(int64_t)time
{
    WS(ws);
    FindItemModel *modle = [[FindItemModel alloc] init];
    
    if (time != 0) {
        modle.update_time = time;
    } else {
        modle.update_time = [NSDate date].timeIntervalSince1970;
    }
    if (_array.count == 0) {
        [GetService getFindListWithCount:0 CityId:city_id WithifUpDrag:ifUpDrag model:modle WithBlock:^(NSDictionary *result, NSError *error) {
			[LWAssistUtil getCodeMessage:error defaultStr:@"" noresultStr:@""];
            [ws manageTheResultWith:result Blcok:block];
        }];
    } else {
        
        FindItemModel *item;
        if (time!=0) {
            item = [_array lastObject];
        } else {
            item = _array[0];
        }
    [GetService getFindListWithCount:_array.count CityId:city_id WithifUpDrag:ifUpDrag model:item WithBlock:^(NSDictionary *result, NSError *error) {
		[LWAssistUtil getCodeMessage:error defaultStr:@"" noresultStr:@""];
        [ws manageTheResultWith:result Blcok:block];
    }];
    }
}
- (void)manageTheResultWith:(NSDictionary *)result Blcok:(void(^)())block
{
     WS(ws);
    [ws.tableView.header endRefreshing];
    [NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];
    NSArray *array = result[@"data"];
    int count = 0;
    if (array.count > 0) {
        for (NSDictionary *dic in array) {
            FindItemModel *item = [FindItemModel modelWithDictionary:dic];
			
			if ([dic[@"is_delete"] boolValue] == 1) {
				[[SQLiteAssister sharedInstance] deleteItem:item];
				continue;
			}

            if (![item.ID isNotEmptyCtg] || ![item.city_id isNotEmptyCtg] || !item.update_time) {
                continue ;
            }
            for (FindItemModel *SQLitem in _array) {
                if (SQLitem.ID.intValue != item.ID.intValue) {
                    count++;
                }
            }
            [[SQLiteAssister sharedInstance] pushItem:item];
            
        }
        int64_t nowDate;
        nowDate = [[NSDate date] timeIntervalSince1970];
        if (ifUpDrag) {
            if(_array.count > 0) {
            FindItemModel *model = [_array lastObject];
                nowDate = model.update_time;
            }
        }
        
        [self loadLocalDataWithCityId:city_id Time:nowDate limit:(10 + count)];
        if (self.array.count == 0) {
            [NetWorkingFailDoErr errWithView:self.tableView content:@"该城市暂时还没有发现哦" tapBlock:^{
                [NetWorkingFailDoErr removeAllErrorViewAtView:self.tableView];
                [self reconcileDataWithBlock:nil footerTime:0];
            }];
        }
        [_tableView reloadData];
        if (block != nil) {
            block();
        }
        
    } else {
        if (self.array.count == 0) {
            [NetWorkingFailDoErr errWithView:self.tableView content:@"该城市暂时还没有发现哦" tapBlock:^{
                [self loadData];
            }];
        }
        [_tableView reloadData];
        if (block != nil) {
            block();
        }
        return ;
    }
}

- (void)initView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - kTabBarHeight) style:UITableViewStylePlain ];
    [self.view addSubview:_tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;

	self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kScrollViewY, screenWidth, kScrollViewH)];
	_scrollView.delegate = self;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.backgroundColor = [WeddingTimeAppInfoManager instance].baseColor;
	_scrollView.contentSize = CGSizeMake(kItemWidth * 9, kTabBarHeight);
	for (int i = 0; i < self.categoryArray.count; i++) {
		NSDictionary *cateDic = self.categoryArray[i];
		UIButton *cateButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cateButton.tag = [cateDic[@"tag"] intValue];
		[cateButton setImage:[UIImage imageNamed:cateDic[@"image"]] forState:UIControlStateNormal];
		cateButton.frame = CGRectMake( i * kItemWidth + (kItemWidth - 40) / 2.0, 0, 40, kTabBarHeight - 12);
		[cateButton addTarget:self action:@selector(cateAction:) forControlEvents:UIControlEventTouchUpInside];

		UILabel *titleLabel = [[UILabel alloc] init];
		titleLabel.textAlignment = NSTextAlignmentCenter;
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.font = DefaultFont12;
		titleLabel.text = cateDic[@"text"];
		titleLabel.frame = CGRectMake(i * kItemWidth, kTabBarHeight - 12, kItemWidth, 12);
		[_scrollView addSubview:titleLabel];
		[_scrollView addSubview:cateButton];
	}
	[self.view addSubview:self.scrollView];

	self.topView = [WTTopView topViewInView:self.view withType:@[@(WTTopViewTypeCityFilter),@(WTTopViewTypeBigSearch),@(WTTopViewTypeChat)]];
	self.topView.delegate = self;
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _array.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.row < _array.count )
	{
		FindItemModel *info = _array[indexPath.row];

		FindTableViewCell *cell = [tableView findCell];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		[cell setUIWithInfo:info];
		[cell addOpacityAnitionFrom:0.2 to:1];
		return cell;
	}

	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.row >= _array.count) { return ; }

    FindItemModel *find = _array[indexPath.row];
    if (find.discover_type == FindItemTypeSupplier) {
        WTSupplierViewController *supplier = [[WTSupplierViewController alloc] init];
        supplier.supplier_id = find.content.supplier_id;
        [self.navigationController pushViewController:supplier animated:YES];
    } else if(find.discover_type == FindItemTypeInspiretion){
        WTInspiretionListViewController *ins = [[WTInspiretionListViewController alloc] init];
        ins.searchTag = find.content.tag;
        [self.navigationController pushViewController:ins animated:YES];
	}else if (find.discover_type == FindItemTypePost){
		WTWorksDetailViewController *worksVC = [WTWorksDetailViewController instanceWTWorksDetailVCWithWrokID:find.content.post_id];
		[self.navigationController pushViewController:worksVC animated:YES];
	}
}

- (void)cateAction:(UIButton *)cateBtn
{
	WTWeddingType type = (WTWeddingType)cateBtn.tag;
	if(type != WTWeddingTypeInspiration){
		WTSHContainerViewController *sh = [[WTSHContainerViewController alloc] init];
		sh.supplier_type = type;
		[self.navigationController pushViewController:sh animated:YES];
	}
	else if(type == WTWeddingTypeInspiration){
		WTInspirationCategoryViewController *next = [[WTInspirationCategoryViewController alloc]initWithNibName:@"WTInspirationCategoryViewController" bundle:nil];
		[self.navigationController pushViewController:next animated:YES];
	}
	[PostDataService postAccessLogWithServiceID:type andCityID:nil andSUID:nil andSOP:WTLogTypeNone];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (void)didiFalidLocation
{
    [locationManager stopLocating];
}

- (void)didLocationSucceed:(BMKReverseGeoCodeResult *)result {
    [UserInfoManager instance].city_name = result.addressDetail.city ;
	[[UserInfoManager instance] saveToUserDefaults];
    [locationManager stopLocating];
    
    [GetService getCityidWithLon:result.location.longitude  andLat:result.location.latitude WithBlock:^(NSDictionary *result, NSError *error) {
		[LWAssistUtil getCodeMessage:error defaultStr:@"" noresultStr:@""];
        if (!error) {
            if ([result isKindOfClass:[NSDictionary class]]) {
                if (result[@"city_id"]) {
                    [UserInfoManager instance].curCityId = [result[@"city_id"] intValue];
                    [[UserInfoManager instance] saveToUserDefaults];
                }
            }
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if([scrollView isEqual:_tableView]){
		CGFloat offset = scrollView.contentOffset.y - _preContentOffsetY;
		CGRect scrollViewFrame = _scrollView.frame;
		if(scrollView.contentOffset.y < 0){
			return;
		}
		if(offset > 0 && scrollViewFrame.origin.y >= kScrollViewY && scrollViewFrame.origin.y != screenHeight){
			scrollViewFrame.origin.y += offset;
			if(scrollViewFrame.origin.y >= screenHeight)
			{
				scrollViewFrame.origin.y = screenHeight;
			}
			_scrollView.frame = scrollViewFrame;
		}

		if(offset < 0 && scrollViewFrame.origin.y <= screenHeight && scrollViewFrame.origin.y != kScrollViewY){
			scrollViewFrame.origin.y += offset;
			if(scrollViewFrame.origin.y <= kScrollViewY){
				scrollViewFrame.origin.y = kScrollViewY;
			}
			_scrollView.frame = scrollViewFrame;
		}
		_preContentOffsetY = scrollView.contentOffset.y;
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[UIView animateWithDuration:0.35 animations:^{
		_scrollView.frame = CGRectMake(0, kScrollViewY, screenWidth, kScrollViewH);
	}];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (NSMutableArray *)categoryArray
{
	return [@[@{@"tag":@(WTWeddingTypePlan),@"image":@"category_wedding_plan",@"text":@"婚礼策划"}
				,@{@"tag":@(WTWeddingTypePhoto),@"image":@"category_wedding_photo",@"text":@"婚纱写真"}
				,@{@"tag":@(WTWeddingTypeCapture),@"image":@"category_wedding_follow",@"text":@"婚礼摄影"}
				,@{@"tag":@(WTWeddingTypeHost),@"image":@"category_wedding_holder",@"text":@"婚礼主持"}
				,@{@"tag":@(WTWeddingTypeDress),@"image":@"category_wedding_choth",@"text":@"婚纱礼服"}
				,@{@"tag":@(WTWeddingTypeMakeUp),@"image":@"category_wedding_sculpt",@"text":@"新娘跟妆"}
				,@{@"tag":@(WTWeddingTypeVideo),@"image":@"category_wedding_video",@"text":@"婚礼摄像"}
				,@{@"tag":@(WTWeddingTypeHotel),@"image":@"category_wedding_hotel",@"text":@"婚宴酒店"}
				,@{@"tag":@(WTWeddingTypeInspiration),@"image":@"category_wedding_inspiration",@"text":@"婚礼灵感"}]
				mutableCopy];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
