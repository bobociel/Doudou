//
//  CommListViewController.m
//  lovewith
//
//  Created by momo on 15/10/11.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "CommListViewController.h"
#import "WTLoginViewController.h"
#import "MJRefresh.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@interface CommListViewController ()
@end

@implementation CommListViewController

-(void)setFootOpen:(BOOL)footOpen HeadOpen:(BOOL)headOpen
{
    footerOpen=footOpen;
    headerOpen=headOpen;
    [self initFooterRefresh];
    [self initHeadRefresh];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)]];
    self.automaticallyAdjustsScrollViewInsets=NO;
    dataTableView=[[UITableView alloc]initWithFrame:self.view.frame];
    
    dataTableView.tableFooterView = [[UIView alloc]init];
    dataTableView.rowHeight=UITableViewAutomaticDimension;
    dataTableView.estimatedRowHeight = 44.0;
    dataTableView.scrollsToTop=YES;
    dataTableView.delegate=self;
    dataTableView.dataSource=self;
    dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    dataTableView.backgroundColor=[UIColor whiteColor];
    
    if ([dataTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [dataTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([dataTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [dataTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self.view addSubview:dataTableView];
    
    [self setFootOpen:YES HeadOpen:YES];
    
    isLoading   = NO;
    page            = 1;
    maxPageCount    = 15;
    dataArray=[NSMutableArray array];
}

- (void)initFooterRefresh
{
    if (!footerOpen) {
        [self removeFooterRefresh];
        return;
    }
    __weak UIScrollView *scrollView = dataTableView;
    
    // 添加下拉刷新控件
    if (!scrollView.footer) {
        scrollView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            [self footerRefreshAction];
        }];
    }
    
    // 如果是上拉刷新，就以此类推
}

-(void)footerRefreshAction
{
    [self loadMore];
}

- (void)initHeadRefresh
{
    if (!headerOpen) {
        [self removeHeadRefresh];
        return;
    }
    __weak UIScrollView *scrollView = dataTableView;
    
    // 添加下拉刷新控件
    if (!scrollView.header) {
        scrollView.header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
            [self headRefreshAction];
        }];
    }
    // 如果是上拉刷新，就以此类推
}

-(void)headRefreshAction
{
    [self reloadData];
}

-(void)removeHeadRefresh
{
    __weak UIScrollView *scrollView = dataTableView;
    scrollView.header =nil;
}

-(void)removeFooterRefresh
{
    __weak UIScrollView *scrollView = dataTableView;
    scrollView.footer =nil;
}

- (void)doloadFinishBlock:(NSArray *)result And:(NSError *)error {
    [self hideLoadingView];
    if (dataTableView.footer) {
        [dataTableView.footer endRefreshing];
    }
    if (dataTableView.header) {
        [dataTableView.header endRefreshing];
    }
    
    isLoading = NO;
    [self hideLoadingView];
    [NetWorkingFailDoErr removeAllErrorViewAtView:dataTableView];
    NetWorkStatusType errorType= [LWAssistUtil getNetWorkStatusType:error];
    if (errorType==NetWorkStatusTypeNone) {
        NSArray *dataCash = result;
        
        if (page==1) {
            [dataArray removeAllObjects];
        }
        [dataArray addObjectsFromArray:dataCash];
        if ([dataCash count] >= maxPageCount) {
            [self initFooterRefresh];
        } else {
            [self removeFooterRefresh];
        }
        if (dataArray.count==0) {
            [NetWorkingFailDoErr errWithView:dataTableView content:@"暂时没有数据哦" tapBlock:^{
                [self loadData];
            }];
        }
        [dataTableView reloadData];
        
    }
    else
    {
        NSString *errorContent=[LWAssistUtil getCodeMessage:error defaultStr:@"" noresultStr:@"暂时没有数据哦"];
        [WTProgressHUD ShowTextHUD:errorContent showInView:self.view];
        if (page<=1) {
            [NetWorkingFailDoErr errWithView:dataTableView content:errorContent tapBlock:^{
                [self loadData];
            }];
        }
        if(page>1)
            page--;
    }
}

#pragma mark UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //请务必在子类里面实现正常情况下的cell组装
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([self respondsToSelector:@selector(custemTableView:willDisplayCell:forRowAtIndexPath:)]) {
        [self custemTableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

#pragma custem-MayReDefine
- (void)loadMore {
    page++;
    [self loadData];
}

- (void)reloadData {
    page          = 1;
    isLoading   = NO;
    page            = 1;
    maxPageCount    = 15;
    [self loadData];
}

-(void)loadData
{
    isLoading=YES;
    if (dataArray.count==0) {
        [self showLoadingView:[self.view superview]];
    }
    if ([self respondsToSelector:@selector(getDataFromSever)]) {
        [self getDataFromSever];
    }
}

- (void)cleanData {
    isLoading   = NO;
    page            = 1;
    maxPageCount    = 15;
    dataArray=[NSMutableArray array];
}
@end

#pragma clang diagnostic pop
