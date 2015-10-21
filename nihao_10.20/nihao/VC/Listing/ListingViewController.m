//
//  ListingViewController.m
//  nihao
//
//  Created by HelloWorld on 5/26/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "ListingViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "SwitchCityViewController.h"
#import "SearchShopViewController.h"
#import "SDCycleScrollView.h"
#import "SwipeView.h"
#import "ListingCategoryCell.h"
#import "MerchantListViewController.h"
#import "City.h"
#import "AppConfigure.h"
#import "BaseFunction.h"
#import "HttpManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MerchantDetailsViewController.h"
#import <MJExtension/MJExtension.h>
#import "Merchant.h"
#import "CommonMerchantListViewController.h"
#import <BaiduMapAPI/BMapKit.h>
#import "NewEventsViewController.h"
#import "DetailsViewController.h"

@interface ListingViewController () <SDCycleScrollViewDelegate, SwipeViewDataSource, SwipeViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate, UIAlertViewDelegate> {
    UILabel *_cityLabel;
    CLLocationManager *_locationManager;
    CLGeocoder *_geocoder;
    //当前服务城市的中文名,关键字搜索需要使用
    NSString *_cityNameCn;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet SwipeView *categorySwipeView;
@property (weak, nonatomic) IBOutlet UIPageControl *categoryPageControl;
@property (weak, nonatomic) IBOutlet UIView *scrollAdsContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *newlyAddedVenuesImageView0;
@property (weak, nonatomic) IBOutlet UILabel *newlyAddedVenuesLabel0;
@property (weak, nonatomic) IBOutlet UIImageView *newlyAddedVenuesImageView1;
@property (weak, nonatomic) IBOutlet UILabel *newlyAddedVenuesLabel1;
@property (weak, nonatomic) IBOutlet UIImageView *newlyAddedVenuesImageView2;
@property (weak, nonatomic) IBOutlet UILabel *newlyAddedVenuesLabel2;
@property (weak, nonatomic) IBOutlet UIImageView *recommendedMerchantImageView0;
@property (weak, nonatomic) IBOutlet UILabel *recommendedMerchantLabel0;
@property (weak, nonatomic) IBOutlet UIImageView *recommendedMerchantImageView1;
@property (weak, nonatomic) IBOutlet UILabel *recommendedMerchantLabel1;
@property (weak, nonatomic) IBOutlet UIImageView *recommendedMerchantImageView2;
@property (weak, nonatomic) IBOutlet UILabel *recommendedMerchantLabel2;
@property (weak, nonatomic) IBOutlet UIView *recommendedMerchantView;
@property (weak, nonatomic) IBOutlet UIView *newlyAddedVenuesView;
@property (weak, nonatomic) IBOutlet UIView *recentView;

@end

static NSString *CellReuseIdentifier = @"ListingCategoryCell";

@implementation ListingViewController {
    // 服务分类列表
    NSMutableArray *categoryArray;
    // 商家广告图片url地址列表
    NSMutableArray *merchantAdArray;
    // 商家广告列表
    NSMutableArray *merchantAdDictionaryArray;
    // 新加商户列表
    NSArray *newlyAddMerchantArray;
	// 推荐商户列表
	NSArray *recommendedMerchantArray;
    // 服务分类Cell宽度
    CGFloat categoryItemWidth;
    // 当前定位的坐标
    MyLocationCoordinate2D currentCoordinate;
    
    NSArray *adControlLabelArray;
    NSArray *adControlImageViewArray;
	NSArray *rcmdControlLabelArray;
	NSArray *rcmdControlImageViewArray;
}

#pragma mark - view life cycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImage *deselectedImage = [[UIImage imageNamed:@"tabbar_icon_listing_unselected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *selectedImage = [[UIImage imageNamed:@"tabbar_icon_listing_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        // 底部导航item
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Listing" image:nil tag:0];
        tabBarItem.image = deselectedImage;
        tabBarItem.selectedImage = selectedImage;
        self.tabBarItem = tabBarItem;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavTitle];
    [self requestLocation];
    self.mainView.frame = CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(self.mainView.frame));
    self.scrollView.contentSize = self.mainView.frame.size;
    self.scrollView.backgroundColor = self.mainView.backgroundColor;
    [self.scrollView addSubview:self.mainView];
    self.scrollView.alwaysBounceVertical = YES;
    
    self.categorySwipeView.bounces = NO;
    
    merchantAdArray = [[NSMutableArray alloc] init];
    merchantAdDictionaryArray = [[NSMutableArray alloc] init];
    categoryItemWidth = SCREEN_WIDTH / 3.0;
    adControlLabelArray = [NSArray arrayWithObjects:self.newlyAddedVenuesLabel0, self.newlyAddedVenuesLabel1, self.newlyAddedVenuesLabel2, nil];
    adControlImageViewArray = [NSArray arrayWithObjects:self.newlyAddedVenuesImageView0, self.newlyAddedVenuesImageView1, self.newlyAddedVenuesImageView2, nil];
	rcmdControlLabelArray = [NSArray arrayWithObjects:self.recommendedMerchantLabel0, self.recommendedMerchantLabel1, self.recommendedMerchantLabel2, nil];
	rcmdControlImageViewArray = [NSArray arrayWithObjects:self.recommendedMerchantImageView0, self.recommendedMerchantImageView1, self.recommendedMerchantImageView2, nil];
	
	[self drawLines];
	
    [self requestServiceList];
//    [self requestMerchantAdsList];
//    [self requestNewlyAddMerchantList];
//	[self requestRecommededMerchantList];
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
//	self.navigationController.navigationBarBackgroundAlpha = 1;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.hidesBottomBarWhenPushed = NO;
}

/*
 * 初始化导航条的顶部控件
 */
- (void) initNavTitle {
    //城市
    UIControl *cityControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 90, 44)];
    _cityLabel = [[UILabel alloc] init];
    _cityLabel.font = FontNeveLightWithSize(14.0);
    
    //如果当前城市为nil，则使用默认服务城市
    City *city = [City getCityFromUserDefault:CURRENT_CITY];
    if(!city) {
        city = [City getCityFromUserDefault:DEFAULT_CITY];
        [City saveCityToUserDefault:city key:CURRENT_CITY];
    }
    _cityLabel.text = city.city_name_en;
    _cityNameCn = city.city_name;
    _cityLabel.textColor = [UIColor whiteColor];
    _cityLabel.frame = CGRectMake(0, 13, 70, 17);
    UIImageView *arrow = [[UIImageView alloc] initWithImage:ImageNamed(@"arrow_white")];
    arrow.frame = CGRectMake(71, 20, 12, 6);
    [cityControl addSubview:_cityLabel];
    [cityControl addSubview:arrow];
    [cityControl addTarget:self action:@selector(switchCity) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cityControl];
    //搜索
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 8, SCREEN_WIDTH - CGRectGetWidth(cityControl.frame) - 32, 27)];
    //搜索背景
    UIControl *searchBg = [[UIControl alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(searchView.frame) - 10, 27)];
    searchBg.backgroundColor = ColorWithRGBA(255, 255, 255, 0.2);
    //搜索图标
    UIImageView *searchImage = [[UIImageView alloc] initWithImage:ImageNamed(@"common_icon_search")];
    searchImage.frame = CGRectMake(10, 5, 16, 16);
    [searchBg addTarget:self action:@selector(searchKeyword) forControlEvents:UIControlEventTouchUpInside];
    [searchBg addSubview:searchImage];
    //搜索提示
    UILabel *searchHint = [[UILabel alloc] init];
    searchHint.font = FontNeveLightWithSize(14.0);
    searchHint.text = @"Search";
    searchHint.textColor = ColorWithRGB(184, 228, 254);
    [searchHint sizeToFit];
    searchHint.frame = CGRectMake(CGRectGetMaxX(searchImage.frame) + 8, 4, CGRectGetWidth(searchHint.frame), CGRectGetHeight(searchHint.frame));
    [searchBg addSubview:searchHint];
    [searchView addSubview:searchBg];
    self.navigationItem.titleView = searchView;
}

#pragma mark - network request functions
#pragma mark 获取服务分类列表
- (void)requestServiceList {
    [HttpManager requestServiceList:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *resultDict = (NSDictionary *)responseObject;
        NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
        if (rtnCode == 0) {
            NSLog(@"-----------------%@",resultDict);
            NSArray *result = [[resultDict objectForKey:@"result"] objectForKey:@"items"];
            categoryArray = [[NSMutableArray alloc] initWithArray:result];
            NSLog(@"%lu",(unsigned long)categoryArray.count);
            
//            NSDictionary *addMerchant = @{@"mhc_id":@"0",@"mhc_name":@"Add Merchant"};
//            [categoryArray addObject:addMerchant];
            int pages = [self getNumberOfCategoryPages];
            self.categoryPageControl.numberOfPages = pages;
            [self.categorySwipeView reloadData];
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
//        [self showHUDWithText:@"请求失败,请稍后重试" delay:2];
    }];
}

#pragma mark 获取商家广告列表
- (void)requestMerchantAdsList {
//	NSString *cityName = [City getCityFromUserDefault:CURRENT_CITY].city_name;
//	NSLog(@"cityName = %@", cityName);
//	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
//	[parameters setObject:cityName forKey:@"mhi_city"];
//	
//	if ([self isLocateCitySameAsSelectedCity]) {
//		NSString *latString = [NSString stringWithFormat:@"%lf", currentCoordinate.latitude];
//		NSString *longString = [NSString stringWithFormat:@"%lf", currentCoordinate.longitude];
//		[parameters setObject:latString forKey:@"ci_gpslat"];
//		[parameters setObject:longString forKey:@"ci_gpslong"];
//	}
//	NSLog(@"request listing ads parameters = %@", parameters);
	
	[HttpManager requestMerchantAdsListByParameters:[self requestParametersForAd:YES] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *resultDict = (NSDictionary *)responseObject;
//        NSLog(@"商家广告列表 resultDict = %@", resultDict);
        NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
        if (rtnCode == 0) {
//            NSArray *merchantAdTempArray = [[resultDict objectForKey:@"result"] objectForKey:@"items"];
			NSArray *merchantAdTempArray = [Merchant objectArrayWithKeyValuesArray:resultDict[@"result"][@"items"]];
            [merchantAdArray removeAllObjects];
            [merchantAdDictionaryArray removeAllObjects];
            for (Merchant *adMerchant in merchantAdTempArray) {
                NSString *adURLString = [BaseFunction convertServerImageURLToURLString:adMerchant.mhi_advert_img];
                [merchantAdArray addObject:[NSURL URLWithString:adURLString]];
            }
			[merchantAdDictionaryArray addObjectsFromArray:merchantAdTempArray];
            // 网络加载图片的轮播器
            SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(self.scrollAdsContainerView.frame)) imageURLsGroup:merchantAdArray];
            cycleScrollView.placeholderImage = [UIImage imageNamed:@"img_is_loading"];
            cycleScrollView.delegate = self;
			cycleScrollView.autoScrollTimeInterval = 4.0;
            [self.scrollAdsContainerView addSubview:cycleScrollView];
		} else {
			NSLog(@"Listing 轮播广告 responseObject: %@", responseObject);
		}
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
    }];
}

#pragma mark 获取最新添加商户列表
- (void)requestNewlyAddMerchantList {
//	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
//	NSString *cityName = [City getCityFromUserDefault:CURRENT_CITY].city_name;
//	[parameters setObject:cityName forKey:@"mhi_city"];
//	[parameters setObject:@"1" forKey:@"page"];
//	[parameters setObject:@"3" forKey:@"rows"];
//	
//	if ([self isLocateCitySameAsSelectedCity]) {
//		NSString *latString = [NSString stringWithFormat:@"%lf", currentCoordinate.latitude];
//		NSString *longString = [NSString stringWithFormat:@"%lf", currentCoordinate.longitude];
//		[parameters setObject:latString forKey:@"ci_gpslat"];
//		[parameters setObject:longString forKey:@"ci_gpslong"];
//	}
	
	[HttpManager requestNewlyAddMerchantListByParameters:[self requestParametersForAd:NO] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *resultDict = (NSDictionary *)responseObject;
//        NSLog(@"最新添加商户列表 resultDict = %@", resultDict);
        NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
        if (rtnCode == 0) {
			newlyAddMerchantArray = [Merchant objectArrayWithKeyValuesArray:[[resultDict objectForKey:@"result"] objectForKey:@"rows"]];
            if (newlyAddMerchantArray.count > 0) {
                int cnt = 0;
                for (Merchant *merchant in newlyAddMerchantArray) {
                    NSURL *merchantURL = [NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:merchant.mhi_header_img]];
                    UIImageView *adImageView = (UIImageView *)adControlImageViewArray[cnt];
                    adImageView.hidden = NO;
                    [adImageView sd_setImageWithURL:merchantURL placeholderImage:[UIImage imageNamed:@"img_is_loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        if (error) {
                            adImageView.image = [UIImage imageNamed:@"img_is_load_failed"];
                        }
                    }];
                    UILabel *adLabel = (UILabel *)adControlLabelArray[cnt];
                    adLabel.hidden = NO;
                    adLabel.text = merchant.mhi_name;
                    ++cnt;
                }
            } else {
                for (int i = 0; i < 3; ++i) {
                    UIImageView *adImageView = (UIImageView *)adControlImageViewArray[i];
                    UILabel *adLabel = (UILabel *)adControlLabelArray[i];
                    adImageView.hidden = YES;
                    adLabel.hidden = YES;
                }
            }
        }
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
//        [self showHUDWithText:@"请求失败,请稍后重试" delay:2];
    }];
}

#pragma mark 获取推荐商户列表
- (void)requestRecommededMerchantList {
	[HttpManager requestRecommendedMerchantListByParameters:[self requestParametersForAd:NO] success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
		if (rtnCode == 0) {
			recommendedMerchantArray = [Merchant objectArrayWithKeyValuesArray:[[resultDict objectForKey:@"result"] objectForKey:@"rows"]];
			if (recommendedMerchantArray.count > 0) {
				int cnt = 0;
				for (Merchant *merchant in recommendedMerchantArray) {
					NSURL *merchantURL = [NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:merchant.mhi_header_img]];
					UIImageView *rcmdImageView = (UIImageView *)rcmdControlImageViewArray[cnt];
					rcmdImageView.hidden = NO;
					[rcmdImageView sd_setImageWithURL:merchantURL placeholderImage:[UIImage imageNamed:@"img_is_loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
						if (error) {
							rcmdImageView.image = [UIImage imageNamed:@"img_is_load_failed"];
						}
					}];
					UILabel *adLabel = (UILabel *)rcmdControlLabelArray[cnt];
					adLabel.hidden = NO;
					adLabel.text = merchant.mhi_name;
					++cnt;
				}
			} else {
				for (int i = 0; i < 3; ++i) {
					UIImageView *adImageView = (UIImageView *)rcmdControlImageViewArray[i];
					UILabel *adLabel = (UILabel *)rcmdControlLabelArray[i];
					adImageView.hidden = YES;
					adLabel.hidden = YES;
				}
			}
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
	}];
}

#pragma mark 获取请求参数
- (NSDictionary *)requestParametersForAd:(BOOL)isForAd {
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	NSString *cityName = [City getCityFromUserDefault:CURRENT_CITY].city_name;
	[parameters setObject:cityName forKey:@"mhi_city"];
	
	if (!isForAd) {
		[parameters setObject:@"1" forKey:@"page"];
		[parameters setObject:@"3" forKey:@"rows"];
	}
	
	if ([self isLocateCitySameAsSelectedCity]) {
		NSString *latString = [NSString stringWithFormat:@"%lf", currentCoordinate.latitude];
		NSString *longString = [NSString stringWithFormat:@"%lf", currentCoordinate.longitude];
		[parameters setObject:latString forKey:@"ci_gpslat"];
		[parameters setObject:longString forKey:@"ci_gpslong"];
	}
	
	return parameters;
}

#pragma mark - SwipeViewDataSource, SwipeViewDelegate
- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    return [self getNumberOfCategoryPages];
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:view.bounds collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.bounces = NO;
    [collectionView registerNib:[UINib nibWithNibName:@"ListingCategoryCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:CellReuseIdentifier];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.tag = index;
    
    UIView *hLine0 = [[UIView alloc] initWithFrame:CGRectMake(0, 60, SCREEN_WIDTH, 0.5)];
    hLine0.backgroundColor = SeparatorColor;
    [collectionView addSubview:hLine0];
    UIView *hLine1 = [[UIView alloc] initWithFrame:CGRectMake(0, 119.5, SCREEN_WIDTH, 0.5)];
    hLine1.backgroundColor = SeparatorColor;
    [collectionView addSubview:hLine1];
    
    int vLineCount = [self getNumberOfCategoryPages] * 3 - 1;
    for (int i = 1; i <= vLineCount; ++i) {
        UIView *vLine = [[UIView alloc] initWithFrame:CGRectMake(categoryItemWidth * i, 0, 0.5, 120)];
        vLine.backgroundColor = SeparatorColor;
        [collectionView addSubview:vLine];
    }
    
    view = collectionView;
    return view;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView {
    return CGSizeMake(SCREEN_WIDTH, CGRectGetHeight(self.categorySwipeView.frame));
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView {
    self.categoryPageControl.currentPage = swipeView.currentItemIndex;
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self getNumberForCollectionViewTag:collectionView.tag];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ListingCategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];
    NSInteger categoryIndex = collectionView.tag * 6 + indexPath.row;
    NSLog(@"__________________%ld",(long)categoryIndex);
    cell.backgroundColor = [UIColor whiteColor];
    NSDictionary *categoryInfo = [categoryArray objectAtIndex:categoryIndex];
    
    NSLog(@"%@",categoryInfo);
    NSString *iconUrlString = [categoryInfo[@"mhc_id"] integerValue] == 0 ? nil :[BaseFunction convertServerImageURLToURLString:[categoryInfo objectForKey:@"mhc_img"]];
    
    [cell initCellWithCategoryImagePath:iconUrlString categoryName:[categoryInfo objectForKey:@"mhc_name"]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(categoryItemWidth, 60.0f);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger categoryIndex = collectionView.tag * 6 + indexPath.row;
    MerchantListViewController *merchantListViewController = [[MerchantListViewController alloc] init];
    merchantListViewController.categoryTitle = [[categoryArray objectAtIndex:categoryIndex] objectForKey:@"mhc_name"];
    merchantListViewController.coordinate = currentCoordinate;
    merchantListViewController.currentOneLevelMhcID = [[[categoryArray objectAtIndex:categoryIndex] objectForKey:@"mhc_id"] integerValue];
    [self.navigationController pushViewController:merchantListViewController animated:YES];
}

#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
	//[self needOpenMerchantDetailWithMerchantInfoInArray:merchantAdDictionaryArray atIndex:index];
}

#pragma mark - click events
- (IBAction)categoryPageControlValueChanged:(UIPageControl *)sender {
    [self.categorySwipeView scrollToItemAtIndex:sender.currentPage duration:0.3];
}

// 新加商户点击
- (IBAction)merchantAd0Click:(id)sender {
    [self needOpenMerchantDetailWithMerchantInfoInArray:newlyAddMerchantArray atIndex:0];
}

- (IBAction)merchantAd1Click:(id)sender {
    [self needOpenMerchantDetailWithMerchantInfoInArray:newlyAddMerchantArray atIndex:1];
}

- (IBAction)merchantAd2Click:(id)sender {
	[self needOpenMerchantDetailWithMerchantInfoInArray:newlyAddMerchantArray atIndex:2];
}

// 查看更多新加商户
- (IBAction)newlyAddVenuesClick:(id)sender {
	[self openCMerchantListVCByType:CommonMerchantListTypeNewlyAdded];
}

// 推荐商户点击
- (IBAction)merchantRcmd0Click:(id)sender {
	[self needOpenMerchantDetailWithMerchantInfoInArray:recommendedMerchantArray atIndex:0];
}

- (IBAction)merchantRcmd1Click:(id)sender {
	[self needOpenMerchantDetailWithMerchantInfoInArray:recommendedMerchantArray atIndex:1];
}

- (IBAction)merchantRcmd2Click:(id)sender {
	[self needOpenMerchantDetailWithMerchantInfoInArray:recommendedMerchantArray atIndex:2];
}

// 查看更多推荐商户
- (IBAction)recommendedMerchantClick:(id)sender {
	[self openCMerchantListVCByType:CommonMerchantListTypeRecommended];
}

#pragma mark - other functions

- (void)drawLines {
	UIView *line0 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
	line0.backgroundColor = SeparatorColor;
	[self.recommendedMerchantView addSubview:line0];
	
	UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2, 0, 0.5, CGRectGetHeight(self.recommendedMerchantView.frame))];
	line1.backgroundColor = SeparatorColor;
	[self.recommendedMerchantView addSubview:line1];
	
	UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2, CGRectGetHeight(self.recommendedMerchantView.frame) / 2, SCREEN_WIDTH / 2, 0.5)];
	line2.backgroundColor = SeparatorColor;
	[self.recommendedMerchantView addSubview:line2];
	
	UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
	line3.backgroundColor = SeparatorColor;
	[self.newlyAddedVenuesView addSubview:line3];
    
    UIView *line4 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
    line4.backgroundColor = SeparatorColor;
    [self.recentView addSubview:line4];
    
}
- (IBAction)openNweEventsController:(id)sender {
    NewEventsViewController *newevent =[[NewEventsViewController alloc]init];
    [self.navigationController pushViewController:newevent animated:YES];
    NSLog(@"我点击了按钮！！！！！！！！！！！");
    
//    DetailsViewController *details =[[DetailsViewController alloc]init];
//    [self.navigationController pushViewController:details animated:YES];
//    NSLog(@"Show Details");
}
- (IBAction)openDetailsViewController:(id)sender {
    DetailsViewController *details =[[DetailsViewController alloc]init];
    [self.navigationController pushViewController:details animated:YES];
    NSLog(@"Show Details");
    
}

- (void)openCMerchantListVCByType:(CommonMerchantListType)type {
	CommonMerchantListViewController *commonMerchantListViewController = [[CommonMerchantListViewController alloc] init];
	commonMerchantListViewController.currentCoordinate = currentCoordinate;
	commonMerchantListViewController.commonMerchantListType = type;
	[self.navigationController pushViewController:commonMerchantListViewController animated:YES];
}

#pragma mark 打开商户详情界面并传入商户数据
- (void)needOpenMerchantDetailWithMerchantInfoInArray:(NSArray *)merchants atIndex:(NSInteger)index {
	if (merchants.count > index) {
		Merchant *merchant = [merchants objectAtIndex:index];
		MerchantDetailsViewController *merchantDetailsViewController = [[MerchantDetailsViewController alloc] init];
		merchantDetailsViewController.merchantInfo = merchant;
		[self.navigationController pushViewController:merchantDetailsViewController animated:YES];
	}
}

- (BOOL)isLocateCitySameAsSelectedCity {
	NSString *selectedCityName = [City getCityFromUserDefault:CURRENT_CITY].city_name_en;
	selectedCityName = [selectedCityName stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSString *locateCityName = [AppConfigure objectForKey:LOCATE_CITY];
//	NSLog(@"selectedCityName = %@, locateCityName = %@", selectedCityName, locateCityName);
	
	if ([selectedCityName compare:locateCityName options:NSCaseInsensitiveSearch] == NSOrderedSame) {
		return YES;
	} else {
		return NO;
	}
}

#pragma mark 获取服务分类的页数
- (int)getNumberOfCategoryPages {
    // 判断categoryArray是否为空
    if (categoryArray) {
        // 判断服务分类列表数量是否为6的整数，根据余数计算分类列表页数
        if ((categoryArray.count % 6) == 0) {
            return (int)(categoryArray.count / 6);
        } else {
            return (int)(categoryArray.count / 6) + 1;
        }
    } else {
        return 0;
    }
}

#pragma mark 根据CollectionView的Tag来获取要显示的服务分类个数
- (int)getNumberForCollectionViewTag:(NSInteger)tag {
    int categoryCount = (int)categoryArray.count;
    if (categoryCount - ((tag + 1) * 6) >= 0) {
        return 6;
    } else {
        return (int)(categoryCount - tag * 6);
    }
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
 * 切换城市
 */
- (void) switchCity {
    SwitchCityViewController *controller = [[SwitchCityViewController alloc] initWithNibName:@"SwitchCityViewController" bundle:nil];
    controller.switchCity = ^(City *city) {
        _cityLabel.text = city.city_name_en;
        _cityNameCn = city.city_name;
        [City saveCityToUserDefault:city key:CURRENT_CITY];
//		currentCoordinate.latitude = 0;
        //更新listing首页ui
        [self requestServiceList];
        [self requestMerchantAdsList];
        [self requestNewlyAddMerchantList];
		[self requestRecommededMerchantList];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Navigation

/*
 * 关键字搜索
 */
- (void)searchKeyword {
    SearchShopViewController *controller = [[SearchShopViewController alloc] initWithNibName:@"SearchShopViewController" bundle:nil];
    controller.cityName  = _cityNameCn;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)requestLocation {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    
    if([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [_locationManager requestAlwaysAuthorization]; // 永久授权
    }
    
    _locationManager.delegate = self;
    // 用来控制定位精度，精度越高耗电量越大，当前设置定位精度为最好的精度
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // 开始定位
    [_locationManager startUpdatingLocation];
    
    _geocoder = [[CLGeocoder alloc] init];
}

#pragma mark - locate delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    [manager stopUpdatingLocation];
    NSDictionary *bmkCoordinateDic = BMKConvertBaiduCoorFrom(location.coordinate,BMK_COORDTYPE_GPS);
    CLLocationCoordinate2D coordinate = BMKCoorDictionaryDecode(bmkCoordinateDic);
    currentCoordinate.latitude = coordinate.latitude;
    currentCoordinate.longitude = coordinate.longitude;
	[self requestMerchantAdsList];
//    [self getCityInfoByLocation:location];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//	currentCoordinate.latitude = 0;
	[self requestMerchantAdsList];
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"can't get your location" message:@"please open app location service in settings" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        
    }
}

/*
 * @param coordinate 经纬度
 *
 */
- (void)getCityInfoByLocation : (CLLocation *) location {
    //反向地理编码
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error && [placemarks count] > 0) {
//            NSDictionary *dict = [[placemarks objectAtIndex:0] addressDictionary];
//			City *city = [[City alloc] init];
//			city.city_name_en = dict[@"City"];
//            [AppConfigure setObject:city ForKey:LOCATE_CITY];
            //是否切换城市提醒
            
        } else {
            NSLog(@"ERROR: %@", error);
        }}];
}

@end
