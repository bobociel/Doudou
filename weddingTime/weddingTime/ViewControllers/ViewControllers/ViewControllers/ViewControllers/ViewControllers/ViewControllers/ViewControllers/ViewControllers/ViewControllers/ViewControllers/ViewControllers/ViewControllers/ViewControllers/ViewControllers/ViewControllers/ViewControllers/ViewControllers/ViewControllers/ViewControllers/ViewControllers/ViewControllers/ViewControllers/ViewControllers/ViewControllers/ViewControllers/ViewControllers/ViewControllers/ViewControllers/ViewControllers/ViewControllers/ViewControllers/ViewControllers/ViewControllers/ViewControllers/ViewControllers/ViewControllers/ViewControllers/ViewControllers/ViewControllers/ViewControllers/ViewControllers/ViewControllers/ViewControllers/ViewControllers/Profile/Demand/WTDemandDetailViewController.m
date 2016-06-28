//
//  emandDetailViewController.m
//  weddingTime
//
//  Created by _Cuixin on 15/9/23.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTDemandDetailViewController.h"
#import "WTSupplierViewController.h"
#import "WTChatDetailViewController.h"
#import "WeddingTimeAppInfoManager.h"
#import "WTAlertView.h"
#import "GetService.h"
#import "WTProgressHUD.h"
#import "WTDemandCell.h"
#import "UIImageView+SDWebImage_M13ProgressSuite.h"
#import "ChatConversationManager.h"
#import "MJRefresh.h"
#import "NotificationTopPush.h"
#define kLeftGap 10.0
#define kTopGap 20.0
#define kItemWidth (screenWidth / 3.0 - 2 *kLeftGap)
#define kHeadViewHeight 95.0
#define kPageSize 12
@interface WTDemandDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@end

@implementation WTDemandDetailViewController
{
    UITableView *baseTableView;
    UIView      *headView;

    UILabel     *weddingTimeLabel;
    UILabel     *weddingTimeLabelOfNum;
    UILabel     *budgetLabel;
    UILabel     *budgetLabelOfNum;
    UILabel     *cityFormLabel;
    UILabel     *cityFormNumLabel;
    
    WTDemand       *demand;
    NSMutableArray *bidsArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = @"需求详情";
	bidsArray = [NSMutableArray array];
    [self initView];
    [self loadData];

	baseTableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
		[self loadMore];
	}];
}

- (void)loadData
{
    [self showLoadingView];
    [GetService getDemandDetailWithRewardId:self.rewardId WithBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
		if(!error)
		{
			demand = [WTDemand modelWithDictionary:result[@"data"]];
			self.title = [NSString stringWithFormat:@"%@需求",demand.service_name] ;
			[baseTableView reloadData];
			[self loadMore];
		}
		else
		{
			[WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error defaultStr:@"" noresultStr:@""] showInView:self.view];
		}
    }];
}

-(void)loadMore
{
	NSInteger page = ceil(bidsArray.count / kPageSize * 1.0) + 1;
	[GetService getDemandRibedWithRewardId:demand.ID WithPage:page WithBlock:^(NSDictionary *result, NSError *error) {
		[baseTableView.footer endRefreshing];
		if(!error)
		{
			if(page == 1){ bidsArray = [NSMutableArray array]; }
			NSArray *suppliers = [NSArray modelArrayWithClass:[WTSupplier class] json:result[@"data"]];
			[bidsArray addObjectsFromArray:suppliers];
			[baseTableView reloadData];
			baseTableView.footer.hidden = suppliers.count < kPageSize;
			if(bidsArray.count == 0){
				[WTProgressHUD ShowTextHUD:@"暂时还没有商家接单哦，请耐心等待" showInView:self.view];
			}
		}
		else
		{
			NSString *errMsg = [LWAssistUtil getCodeMessage:error andDefaultStr:@""];
			[WTProgressHUD showLoadingHUDWithTitle:errMsg showInView:self.dataTableView];
		}
	}];
}

-(void)initView {
    headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, kHeadViewHeight)];
    headView.backgroundColor = [UIColor whiteColor];

	cityFormLabel=[[UILabel alloc]initWithFrame:CGRectMake(kLeftGap, kTopGap, kItemWidth, 14)];
	cityFormLabel.text = @"城市";
	cityFormLabel.font = DefaultFont14;
	cityFormLabel.textColor = rgba(153, 153, 153, 1);
	cityFormLabel.textAlignment=NSTextAlignmentCenter;
	[headView addSubview:cityFormLabel];

	cityFormNumLabel=[[UILabel alloc]initWithFrame:CGRectMake(kLeftGap, cityFormLabel.bottom+10, kItemWidth, 21)];
	cityFormNumLabel.font = DefaultFont16;
	cityFormNumLabel.textColor = rgba(102, 102, 102, 1);
	cityFormNumLabel.textAlignment=NSTextAlignmentCenter;
	[headView addSubview:cityFormNumLabel];

    weddingTimeLabel=[[UILabel alloc]initWithFrame:CGRectMake(cityFormLabel.right + 2 *kLeftGap, kTopGap, kItemWidth, 14)];
    weddingTimeLabel.text = @"婚期";
    weddingTimeLabel.font = DefaultFont14;
    weddingTimeLabel.textColor = rgba(153, 153, 153, 1);
    weddingTimeLabel.textAlignment = NSTextAlignmentCenter;
    [headView addSubview:weddingTimeLabel];

    weddingTimeLabelOfNum=[[UILabel alloc]initWithFrame:CGRectMake(weddingTimeLabel.left, weddingTimeLabel.bottom+10, kItemWidth, 21)];
    weddingTimeLabelOfNum.font = DefaultFont16;
    weddingTimeLabelOfNum.textColor = rgba(102, 102, 102, 1);
    weddingTimeLabelOfNum.textAlignment=NSTextAlignmentCenter;
    [headView addSubview:weddingTimeLabelOfNum];
    
    budgetLabel=[[UILabel alloc]initWithFrame:CGRectMake(weddingTimeLabel.right + 2*kLeftGap, kTopGap, kItemWidth, 14)];
    budgetLabel.text=@"预算";
    budgetLabel.font = DefaultFont14;
    budgetLabel.textColor = rgba(153, 153, 153, 1);
    budgetLabel.textAlignment=NSTextAlignmentCenter;
    [headView addSubview:budgetLabel];
    
    budgetLabelOfNum=[[UILabel alloc]initWithFrame:CGRectMake(budgetLabel.left, budgetLabel.bottom+10, kItemWidth, 21)];
    budgetLabelOfNum.font = DefaultFont20;
    budgetLabelOfNum.textColor = WeddingTimeBaseColor;
	budgetLabelOfNum.adjustsFontSizeToFitWidth = YES;
    budgetLabelOfNum.textAlignment = NSTextAlignmentCenter;
    [headView addSubview:budgetLabelOfNum];
    
    UIImageView *lineView=[[UIImageView alloc]initWithFrame:CGRectMake(0, kHeadViewHeight-0.5, screenWidth, 0.5)];
    lineView.image = [UIImage imageWithColor:rgba(220, 220, 220, 1)];
    [headView addSubview:lineView];

	UIImageView *lineView1 =[[UIImageView alloc]initWithFrame:CGRectMake(kItemWidth + 2*kLeftGap, kTopGap + 2, 0.5, 40)];
	lineView1.image = [UIImage imageWithColor:rgba(220, 220, 220, 1)];
	[headView addSubview:lineView1];

	UIImageView *lineView2 =[[UIImageView alloc]initWithFrame:CGRectMake(2*(kItemWidth + 2*kLeftGap),kTopGap, 0.5, 40)];
	lineView2.image = [UIImage imageWithColor:rgba(220, 220, 220, 1)];
	[headView addSubview:lineView2];

    baseTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-64) style:UITableViewStylePlain];
    baseTableView.dataSource = self;
    baseTableView.delegate = self;
    baseTableView.backgroundColor=[UIColor whiteColor];
    baseTableView.showsVerticalScrollIndicator = NO;
    baseTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:baseTableView];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return bidsArray.count;
}

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 115;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	WTDemandCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WTDemandCell"];
	if(!cell)
	{
		cell = [[WTDemandCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WTDemandCell"];
	}
	cell.supplier = bidsArray[indexPath.row];
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (demand) {
		cityFormNumLabel.text = demand.city_name;
		NSDate *date = [NSDate dateWithTimeIntervalSince1970:demand.wedding_time];
		NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
		[dateFormatter setDateFormat:@"yy/MM/dd"];
		weddingTimeLabelOfNum.text=[dateFormatter stringFromDate:date];
		budgetLabelOfNum.text = demand.price_range_content;
	}
	return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kHeadViewHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	WTSupplier *supplier = bidsArray[indexPath.row];
	WTConversationType conversartionType = demand.service_id == WTWeddingTypeHotel ? WTConversationTypeHotelOrCustomer : WTConversationTypeSupplier;
	conversartionType = [supplier.supplier_user_id isEqualToString:kServerID] ? WTConversationTypeHotelOrCustomer :
	conversartionType ;
	[self conversationSelectType:conversartionType
					 supplier_id:supplier.supplier_user_id
				   sendToAskData:nil
							name:supplier.company
						   phone:supplier.phone
						  avatar:supplier.avatar];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

-(void)setNavWithHidden
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
@end
