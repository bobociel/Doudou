//
//  WTAboutBaoViewController.m
//  weddingTime
//
//  Created by wangxiaobo on 16/5/23.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTAboutBaoViewController.h"
#import "WTAboutBaoCell.h"
@interface WTAboutBaoViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *titleArray;
@property (nonatomic,strong) NSMutableArray *descArray;
@end

@implementation WTAboutBaoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"关于婚礼宝";
	
	_titleArray = [@[@"Q1: 什么是“婚礼宝”？",
					 @"Q2: 婚礼宝补贴有什么优惠？",
					 @"Q3: 谁可以享受“婚礼宝”的补贴？",
					 @"Q4: 婚礼宝补贴的使用方式？",
					 @"Q5: 使用婚礼宝补贴有什么要求？",
					 @"Q6: 婚礼宝补贴如何申请提现？",
					 @"Q7: 婚礼宝的提现方式？",
					 @"Q8: 不能成功提现的几种情况：",
					 @"Q9: 还不能解决我的疑问？",] mutableCopy];

	_descArray = [@[@"婚礼宝是婚礼时光推出的优惠服务，平台以补贴返现的形式将优惠带给用户。",
					@"用户到店签单的价格基础上，由平台再补贴返利给用户，是实实在在的终极优惠。",
					@"已经注册婚礼时光并且领取了婚礼宝补贴，到店成功消费的用户。",
					@"在婚礼时光平台提前领取商家的婚礼宝补贴券，到店并与商家成功签单，即可打开婚礼宝，找到对应的补贴二维码，让商家进行APP扫码确认，用户即可在婚礼宝进行提现。",
					@"以婚礼宝补贴描述为准：\n例如写明“消费满20000元，可以补贴1000元”等，则表示平台明确规定：在该商家消费单笔订单满多少金额，用户则可获得平台对应金额的现金补贴。同时，不能同享的服务内容或特殊情况，都会一并说明。",
					@"到店扫码成功后，现金补贴默认存入婚礼宝账户中，即可申请提现，当双方确认商家服务完成后， 7个工作日左右获得提现。",
					@"目前婚礼宝仅支持支付宝账号提现。",
					@"商家没有完成服务确认、申请的补贴与相应婚礼宝补贴描述不符、申请的补贴金额与实际消费金额要求不符、您填写的支付宝账号存在问题等。",
					@"亲可以拨打婚礼时光客服电话400-0376-820，或在线咨询客服。"] mutableCopy];

	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - kNavBarHeight)];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.tableFooterView = [[UIView alloc] init];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	[self.view addSubview:_tableView];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	WTAboutBaoCell *cell = [tableView WTAboutBaoCell];
	cell.titleLabel.text = _titleArray[indexPath.row];

	NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:_descArray[indexPath.row]];
	NSMutableParagraphStyle *paragra = [[NSMutableParagraphStyle alloc] init];
	paragra.lineSpacing = 4.0;
	desc.paragraphStyle = paragra;
	cell.descLabel.attributedText = desc;
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [WTAboutBaoCell cellHeightWithTitle:_titleArray[indexPath.row]
									   andDesc:_descArray[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
