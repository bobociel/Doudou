//
//  ExpandViewController.m
//  weddingTime
//
//  Created by 默默 on 15/9/17.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTExpandViewController.h"
#import "ExpandControllerCell.h"
#import "WTKissViewController.h"
#import "WTDrawViewController.h"
#import "WTHomeViewController.h"
#import "WTCardListViewController.h"
#import "WTWeddingShopViewController.h"
#import "WTDeskViewController.h"
#import "WTProcessViewController.h"
#import "WTDemandListViewController.h"
#import "WTInspirationCategoryViewController.h"
#import "SetDefaultWeddingTimeViewController.h"
#import "WeddingPlanContainerViewController.h"
#import "UserInfoManager.h"
#import "CommDatePickView.h"
@interface WTExpandViewController ()<UITableViewDataSource,UITableViewDelegate,CommDatePickViewDelegate>
@property (nonatomic,strong) CAGradientLayer *gradientLayer;
@property (nonatomic,strong) CommDatePickView *datePicker;
@end

@implementation WTExpandViewController
{
    UITableView *baseTableView;
    NSArray *btnList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setupView];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

-(void)setNavWithHidden
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)makeCard
{
    if([LWAssistUtil isLogin]){
        [self.navigationController pushViewController:[WTHomeViewController new] animated:YES];
    }
}

- (void)shopCard
{
	[self.navigationController pushViewController:[WTCardListViewController new] animated:YES];
}

- (void)weddingShop
{
	[self.navigationController pushViewController:[WTWeddingShopViewController new] animated:YES];
}

- (void)weddingProcess
{
	if([LWAssistUtil isLogin]){
		[self.navigationController pushViewController:[WTProcessViewController instanceWithShow:NO] animated:YES];
	}
}

- (void)weddingSeat
{
	if([LWAssistUtil isLogin]){
		[self.navigationController pushViewController:[WTDeskViewController instanceWithShow:NO] animated:YES];
	}
}

- (void)inspirationAction
{
	WTInspirationCategoryViewController *next = [[WTInspirationCategoryViewController alloc]initWithNibName:@"WTInspirationCategoryViewController" bundle:nil];
	[self.navigationController pushViewController:next animated:YES];
	[PostDataService postAccessLogWithServiceID:WTWeddingTypeInspiration andCityID:nil andID:nil andLogType:WTLogTypeNone];
}

-(void)createNeed
{
	if([LWAssistUtil isLogin]){
		[self.navigationController pushViewController:[WTDemandListViewController new] animated:YES];
	}
}

- (void)createPlan
{
	if([LWAssistUtil isLogin]){
		if([UserInfoManager instance].weddingTime > 0){
			[self.navigationController pushViewController:[WeddingPlanContainerViewController new] animated:YES];
		}else{
			[self.navigationController pushViewController:[SetDefaultWeddingTimeViewController new] animated:YES];
		}
	}
}

-(void)draw
{
	if([LWAssistUtil isLogin])
		[WTDrawViewController pushViewControllerWithRootViewController:self isFromJoin:NO isFromChat:NO];
}

-(void)kiss
{
	if([LWAssistUtil isLogin])
		[WTKissViewController pushViewControllerWithRootViewController:self isFromJoin:NO];
}

- (void)assistantAction
{
	if([LWAssistUtil isLogin]){
		_datePicker = [CommDatePickView viewWithStyle:PickerViewStyleRedSureCate];
		_datePicker.delagate = self;
		[_datePicker showWithType:PickerViewTypeCate];
	}
}

- (void)didPickDataWithDate:(NSDate *)date andType:(PickerViewType)type
{
	if(type == PickerViewTypeCate)
	{
		[self conversationSelectType:WTConversationTypeHotelOrCustomer
						 supplier_id:kServerID
					   sendToAskData:_datePicker.resultString
								name:kServerName
							   phone:kServerPhone
							  avatar:kServerAvatar];
	}
}

-(void)setupView
{
	[self showBlurBackgroundView];

	_gradientLayer = [CAGradientLayer layer];
	_gradientLayer.frame = CGRectMake(0, 0, screenWidth, screenHeight);
	_gradientLayer.opacity = 0.61;
	_gradientLayer.colors = @[(id)[LWUtil colorWithHexString:@"FF891F"].CGColor,
							  (id)[LWUtil colorWithHexString:@"FF6499"].CGColor];
	[self.view.layer addSublayer:_gradientLayer];

	btnList = @[
				@{@"image":@"icon_home_expand",@"title":@"制作电子请柬",@"subTitle":@"拥有独立婚礼域名，把婚礼邀请分享给亲朋好友",@"action":@"makeCard"},
				@{@"image":@"icon_shop_card",@"title":@"纸质请柬",@"subTitle":@"\"不纸\"是来自婚礼时光的个性请柬纸品，独家设计",@"action":@"shopCard"},
				@{@"image":@"icon_wedding_process",@"title":@"婚礼当日流程",@"subTitle":@"新郎新娘及婚礼当日的具体行程安排",@"action":@"weddingProcess"},
				@{@"image":@"icon_wedding_seat",@"title":@"宾客座位表",@"subTitle":@"安排受邀来宾的桌位，可以在电子请柬中查询",@"action":@"weddingSeat"},
				@{@"image":@"icon_shop_wedding",@"title":@"新娘商店",@"subTitle":@"最优质的婚礼服务商，最实惠的婚礼宝折扣",@"action":@"weddingShop"},
				@{@"image":@"icon_need",@"title":@"发起婚礼需求",@"subTitle":@"帮你匹配最合适的商家，服务更好，价格透明",@"action":@"createNeed"},
				@{@"image":@"icon_assistant",@"title":@"婚礼顾问",@"subTitle":@"免费推荐合适的商家，婚礼筹备在线小管家",@"action":@"assistantAction"},
				@{@"image":@"icon_inspiration",@"title":@"婚礼灵感",@"subTitle":@"40万婚礼灵感，满足对婚礼的所有想法",@"action":@"inspirationAction"},
				@{@"image":@"icon_plan",@"title":@"婚礼计划",@"subTitle":@"根据自己的婚期，定制你的结婚计划",@"action":@"createPlan"},
				@{@"image":@"icon_draw",@"title":@"一起画",@"subTitle":@"虽然要结婚了，情调依然不能少",@"action":@"draw"},
				@{@"image":@"icon_kiss",@"title":@"指纹kiss",@"subTitle":@"亲爱的你不在我身边，但是还想么么哒！",@"action":@"kiss"},];

    baseTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - kTabBarHeight) style:UITableViewStylePlain];
	baseTableView.backgroundColor = [UIColor clearColor];
    baseTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    baseTableView.delegate = self;
    baseTableView.dataSource = self;
	baseTableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    [self.view addSubview:baseTableView];
}

-(void)animationBegin
{
    if (baseTableView) {
        [baseTableView reloadData];
    }
}

#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return btnList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ExpandControllerCell *cell=[tableView ExpandControllerCell];
    if (indexPath.row>=btnList.count) {
        return nil;
    }
    [cell setInfo:btnList[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row>=btnList.count) {
        return;
    }
    NSDictionary *dic=btnList[indexPath.row];
    SEL target=NSSelectorFromString([LWUtil getString: dic[@"action"] andDefaultStr:@""]) ;
    if (target&&[self respondsToSelector:target]) {
        IMP imp = [self methodForSelector:target];
        void (*func)(id, SEL) = (void *)imp;
        func(self, target);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CellHeight;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		cell.layer.shadowColor = [[UIColor blackColor]CGColor];
		cell.layer.shadowOffset = CGSizeMake(10, 10);
		cell.alpha = 0;
		cell.left=-screenWidth;

		NSTimeInterval time=0.3+indexPath.row*0.1;
		[UIView beginAnimations:@"rotation" context:NULL];
		[UIView setAnimationDuration:time];
		cell.left=0;
		cell.alpha = 1;
		cell.layer.shadowOffset = CGSizeMake(0, 0);
		[UIView commitAnimations];
	});
}
@end
