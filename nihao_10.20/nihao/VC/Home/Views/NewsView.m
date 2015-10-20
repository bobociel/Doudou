//
//  NewsView.m
//  nihao
//
//  Created by HelloWorld on 6/15/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "NewsView.h"
#import "NewsCell.h"
#import "Constants.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "ListingLoadingStatusView.h"
#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>
#import "BaseFunction.h"
#import "HttpManager.h"
#import "News.h"
#import "MBProgressHUD.h"
#import "MWPhotoBrowser.h"
#import "NewsViewController.h"
#import "AppConfigure.h"

@interface NewsView () <UITableViewDelegate, UITableViewDataSource, MWPhotoBrowserDelegate> {
    ListingLoadingStatusView *_loadingStatus;
    MWPhotoBrowser *_photoBrowser;
    //当前选中tableviewcell里面的图片集
    NSMutableArray *_imgs;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL cellHeightCacheEnabled;

@end

static NSString *NewsCellReuseIdentifier = @"NewsCell";

@implementation NewsView {
    NSMutableArray *newsArray;
    NSUInteger page;
	NSIndexPath *lastSelectedIndexPath;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        newsArray = [[NSMutableArray alloc] init];
        page = 1;
        self.cellHeightCacheEnabled = YES;
        self.backgroundColor = RootBackgroundColor;
        
        [self initNewsTableView];
        [self initLoadingViews];
    }
    
    return self;
}

- (void)initNewsTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = RootBackgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 200;
//    self.tableView.fd_debugLogEnabled = YES;
    [self.tableView registerNib:[UINib nibWithNibName:@"NewsCell" bundle:nil] forCellReuseIdentifier:NewsCellReuseIdentifier];
    [self addSubview:self.tableView];
    [BaseFunction addRefreshHeaderAndFooter:self.tableView refreshAction:@selector(refreshNewsList) loadMoreAction:@selector(loadMoreNewsList) target:self];
}

- (void)initLoadingViews {
    _loadingStatus = [[ListingLoadingStatusView alloc] initWithFrame:self.bounds];
    __weak NewsView *weakSelf = self;
    __weak ListingLoadingStatusView *weakStatusView = _loadingStatus;
    _loadingStatus.refresh = ^() {
        [weakStatusView showWithStatus:Loading];
        [weakSelf requestNews];
    };
    [self addSubview:_loadingStatus];
    [_loadingStatus showWithStatus:Loading];
    self.tableView.hidden = YES;
    [self requestNews];
}

- (void)requestNews {
	NSString *uid = [AppConfigure objectForKey:LOGINED_USER_ID];
    NSString *pageString = [NSString stringWithFormat:@"%lu", page];
	NSString *random = [NSString stringWithFormat:@"%d", [BaseFunction random:1000]];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[uid, pageString, DEFAULT_REQUEST_DATA_ROWS, random] forKeys:@[@"ci_id", @"page", @"rows", @"random"]];
    NSLog(@"request top users parameters = %@", parameters);
    [HttpManager requestNewsListByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *resultDict = (NSDictionary *)responseObject;
        NSInteger rtnCode = [resultDict[@"code"] integerValue];
        if (rtnCode == 0) {
            [self processNewsList:resultDict[@"result"]];
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
		if(self.tableView.header.isRefreshing) {
			[self.tableView.header endRefreshing];
		} else if(self.tableView.footer.isRefreshing){
			[self.tableView.footer endRefreshing];
		}
		
		if(newsArray.count > 0) {
			MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self];
			[self addSubview:hud];
			hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_icon_error"]];
			hud.mode = MBProgressHUDModeCustomView;
			hud.labelText = BAD_NETWORK;
			[hud show:YES];
			[hud hide:YES afterDelay:1.5];
		} else {
			if(_loadingStatus.hidden) {
				_loadingStatus.hidden = NO;
			}
			[_loadingStatus showWithStatus:NetErr];
		}
    }];
}

- (void)refreshNewsList {
    page = 1;
    [self requestNews];
}

- (void)loadMoreNewsList {
    page++;
    [self requestNews];
}

- (void)processNewsList:(NSDictionary *)newsDict {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        NSInteger newsCount = 0;
        
        NSArray *newsTempArray = [News objectArrayWithKeyValuesArray:newsDict[@"rows"]];
		newsCount = newsTempArray.count;
        if (page == 1) {
            [newsArray removeAllObjects];
        }
        [newsArray addObjectsFromArray:newsTempArray];
        NSLog(@"newsArray.count = %ld, newsCount = %ld", newsArray.count, newsCount);
        dispatch_async(dispatch_get_main_queue(), ^(){
            // 还能获取更多数据
            if (newsCount >= DEFAULT_REQUEST_DATA_ROWS_INT) {
                self.tableView.footer.hidden = NO;
            } else {// 已经获取全部数据
                self.tableView.footer.hidden = YES;
            }
            // 如果列表有数据
            if (newsArray.count > 0) {
                [_loadingStatus showWithStatus:Done];
                self.tableView.header.hidden = NO;
            } else {// 如果列表没有数据
                if (!_loadingStatus.superview) {
                    [self addSubview:_loadingStatus];
                }
                [_loadingStatus showWithStatus:Empty];
                self.tableView.footer.hidden = YES;
                self.tableView.header.hidden = YES;
            }
            
            if (self.tableView.footer.isRefreshing) {
                [self.tableView.footer endRefreshing];
            }
            if (self.tableView.header.isRefreshing) {
                [self.tableView.header endRefreshing];
            }
            
            self.tableView.hidden = NO;
            [self.tableView reloadData];
        });
    });
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return newsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsCell *cell = (NewsCell *)[tableView dequeueReusableCellWithIdentifier:NewsCellReuseIdentifier forIndexPath:indexPath];
    [cell configureCellWithInfo:newsArray[indexPath.row] forRowAtIndexPath:indexPath];
    cell.showBigPhoto = ^() {
        News *news = newsArray[indexPath.row];
        NSArray *pics = news.pictures;
        _imgs = [NSMutableArray arrayWithArray:pics];
        [self showPhotoBrower];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.cellHeightCacheEnabled) {
        return [tableView fd_heightForCellWithIdentifier:NewsCellReuseIdentifier cacheByIndexPath:indexPath configuration:^(NewsCell *cell) {
            [cell configureCellWithInfo:newsArray[indexPath.row] forRowAtIndexPath:indexPath];
        }];
    } else {
        return [tableView fd_heightForCellWithIdentifier:NewsCellReuseIdentifier configuration:^(NewsCell *cell) {
            [cell configureCellWithInfo:newsArray[indexPath.row] forRowAtIndexPath:indexPath];
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	lastSelectedIndexPath = indexPath;
    NewsViewController *controller = [[NewsViewController alloc] initWithNibName:@"NewsViewController" bundle:nil];
    controller.news = newsArray[indexPath.row];
    controller.like = ^(News *news) {
        for(News *n in newsArray) {
            if(n.ni_id == news.ni_id) {
                n.ni_sum_pii_count = news.ni_sum_pii_count;
                n.pii_is_praise = news.pii_is_praise;
            }
        }
        [_tableView reloadData];
    };
    [_navController pushViewController:controller animated:YES];
}

#pragma mark - 浏览图片gallery
- (void) showPhotoBrower {
    _photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    //设置浏览图片的navigationbar为蓝色
    _photoBrowser.navigationController.navigationBar.barTintColor = AppBlueColor;
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    _photoBrowser.displayActionButton = NO;
    _photoBrowser.enableGrid = NO;
    //[_photoBrowser setCurrentPhotoIndex:index];
    [_photoBrowser setCurrentPhotoIndex:0];
    // Manipulate
    [_photoBrowser showNextPhotoAnimated:YES];
    [_photoBrowser showPreviousPhotoAnimated:YES];
    // Present
    [_navController pushViewController:_photoBrowser animated:YES];
}

#pragma mark - mwphotobrowser delegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _imgs.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _imgs.count) {
        NSDictionary *picture = _imgs[index];
        MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:picture[@"picture_big_network_url"]]]];
        return photo;
    }
    
    return nil;
}

#pragma mark - other functions
- (void)refreshTableView {
	if (lastSelectedIndexPath != nil) {
		[self.tableView reloadRowsAtIndexPaths:@[lastSelectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
	}
}

@end
