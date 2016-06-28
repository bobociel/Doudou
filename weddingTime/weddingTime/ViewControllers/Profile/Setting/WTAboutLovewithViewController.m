//
//  AboutLovewithViewController.m
//  weddingTime
//
//  Created by _Cuixin on 15/9/24.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTAboutLovewithViewController.h"
#import "WTAddressCell.h"
#define kCellHeight 50.0
#define kLabelColor [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.8]
@interface WTAboutLovewithViewController () <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *sinaLabel;
@property (weak, nonatomic) IBOutlet UILabel *tencentLabel;
@property (weak, nonatomic) IBOutlet UILabel *wechatLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (strong, nonatomic) IBOutlet UIView *headView;
@property (strong, nonatomic) IBOutlet UIView *footView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *cellInfo;
@end

@implementation WTAboutLovewithViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)setNavWithHidden
{
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)initView{
    self.title=@"关于婚礼时光";

	_sinaLabel.textColor=kLabelColor;
	_sinaLabel.font=[WeddingTimeAppInfoManager fontWithSize:10];
	_sinaLabel.text=@"新浪微博:婚礼时光";

    _versionLabel.textColor = kLabelColor;
    _versionLabel.font=[WeddingTimeAppInfoManager fontWithSize:10];
    _versionLabel.text=[NSString stringWithFormat:@"版本:%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ];

    _tencentLabel.textColor=kLabelColor;
    _tencentLabel.font = [WeddingTimeAppInfoManager fontWithSize:10];
    _tencentLabel.text = @"腾讯微博:婚礼时光";

    _wechatLabel.textColor=kLabelColor;
    _wechatLabel.font=[WeddingTimeAppInfoManager fontWithSize:10];
    _wechatLabel.text=@"微信号:lovewith_me";

    _companyLabel.textColor=kLabelColor;
    _companyLabel.font=[WeddingTimeAppInfoManager fontWithSize:11];
    _companyLabel.text= @"Copyright © 2012-2016 Lovewith.Me All Rights Reserved";

	_cellInfo = [@[@"去评论",@"服务条款",@"隐私政策",@"联系我们"] mutableCopy];

	_footView.frame = CGRectMake(0, 0, screenWidth, 30);
    _headView.frame = CGRectMake(0, 0, screenWidth, 280);
	_tableView.tableHeaderView = _headView;
	_tableView.tableFooterView = _footView;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _cellInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellID=@"cellID";
	UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
	if (cell==nil) {
		cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.backgroundColor=[UIColor whiteColor];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(15, 0, 104, kCellHeight)];
		label.backgroundColor=[UIColor clearColor];
		label.textAlignment=NSTextAlignmentLeft;
		label.font=[WeddingTimeAppInfoManager fontWithSize:16];
		label.textColor=rgba(102, 102, 102, 1);
		label.alpha=0.9;
		label.text = self.cellInfo[indexPath.row];
		[cell.contentView addSubview:label];
	}
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.row){
		case WTAboutCellTypeComment:
		{
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/id1005404187"]];
		} break;
		case WTAboutCellTypeProtocol:
		{
			[[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.lovewith.me/site/service_term"]];
		} break;
		case WTAboutCellTypePlicy:
		{
			[[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.lovewith.me/site/privacy_term"]];
		} break;
		case WTAboutCellTypeContact:
		{
			WTAlertView *alertView = [[WTAlertView alloc]initWithText:@"是否拨打电话?" centerImage:nil];
			[alertView setButtonTitles:@[@"取消",@"确定"]];
			[alertView setOnButtonTouchUpInside:^(WTAlertView *alertView, int buttonIndex) {
				[alertView close];
				if(buttonIndex == 1)
				{
					NSString *urlStr = [NSString stringWithFormat:@"tel://%@", kServerPhone];
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
				}
			}];
			[alertView show];
		} break;
		default:break;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

@end
