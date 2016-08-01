//
//  BanquetViewController.m
//  weddingTime
//
//  Created by jakf_17 on 15/10/3.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import <UIImageView+WebCache.h>
#import "UIImageView+SDWebImage_M13ProgressSuite.h"
#import "WTBanquetViewController.h"
#import "WTImageDetailCell.h"
#import "GetService.h"
#import "BottomHotelView.h"
#define ImageWidth screenWidth
#define ImageHeight (360 * Height_ato)
@interface WTBanquetViewController ()<UITableViewDataSource, UITableViewDelegate,BottomHotelViewDelegate>
{
	UIImageView *topImage;
}
@property (nonatomic, strong) WTHotelBallRoom *ballroom;
@property (nonatomic, strong) BottomHotelView *bottomHotel;
@end

@implementation WTBanquetViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initView];
    [self loadData];
}

- (void)initView
{
    [self showLoadingView];
    [self setDataTableViewAsDefault:CGRectMake(0, 0, screenWidth, screenHeight-kBottomViewHeight)];
    self.dataTableView.delegate = self;
    self.dataTableView.dataSource = self;
    self.dataTableView.tableHeaderView = [self getHeader];
    [self.view addSubview:self.dataTableView];
    [self addTapButton];

	self.bottomHotel = [BottomHotelView bootomViewInView:self.view];
	_bottomHotel.mainDelegate = self;
	[self.view addSubview:_bottomHotel];
	_bottomHotel.supplier_name = _hotelDetail.hotel_name;
	_bottomHotel.supplier_avatar = _hotelDetail.hotel_avatar;
	_bottomHotel.tel_num = kServerPhone ;
}

- (void)loadData
{
	[GetService getBanquetWithballroomId:_ballroom_id Block:^(NSDictionary *dic, NSError *error) {
		[self hideLoadingView];
		_ballroom = [WTHotelBallRoom modelWithDictionary:dic];
		self.dataTableView.tableHeaderView = [self getHeader];
		[self.dataTableView reloadData];
		[LWAssistUtil getCodeMessage:error defaultStr:@"出错啦,请稍后再试" noresultStr:@""];
	}];
}

- (void)bottomHotelViewConversationSelected
{
	[self conversationSelectType:WTConversationTypeHotelOrCustomer
					 supplier_id:_hotel_id
				   sendToAskData:[_hotelDetail modelToJSONObject]
							name:_hotelDetail.hotel_name
						   phone:self.bottomHotel.tel_num
						  avatar:_hotelDetail.hotel_avatar];
}

- (void)bottomHotelViewCheckSelectedWithDateString:(NSString *)string
{
	[self conversationSelectType:WTConversationTypeHotelOrCustomer
					 supplier_id:_hotel_id
				   sendToAskData:string
							name:_hotelDetail.hotel_name
						   phone:self.bottomHotel.tel_num
						  avatar:_hotelDetail.hotel_avatar];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _ballroom.attach_path.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id info = _ballroom.attach_path[indexPath.row];
	WTImageDetailCell *cell = [tableView WTImageDetailCell];
	cell.hotelInfo = info;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [WTImageDetailCell cellHeight:nil];
}


- (UIView *)getHeader
{
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, (76 + 360 + 28 * _ballroom.ballroom_info.count) * Height_ato)];
	topImage = [UIImageView new];
	topImage.frame = CGRectMake(0, 0, screenWidth, 360 * Height_ato);
	[view addSubview:topImage];
	[topImage sd_setImageWithURL:[NSURL URLWithString:[_ballroom.ballroom_avatar stringByAppendingString:kSmall600]] placeholderImage:[UIImage imageNamed:@""]];

	UIImageView *avatarImage = [UIImageView new];
	avatarImage.layer.borderColor = WHITE.CGColor;
	avatarImage.layer.borderWidth = 3;
	avatarImage.layer.cornerRadius = 65 * Width_ato / 2.0;
	avatarImage.layer.masksToBounds = YES;
	[view addSubview:avatarImage];
	[avatarImage sd_setImageWithURL:[NSURL URLWithString:[_ballroom.hotel_avatar stringByAppendingString:kSmall600]] placeholderImage:[UIImage imageNamed:@"supplier"]];
	[avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.mas_equalTo(327 * Height_ato);
		make.centerX.equalTo(view);
		make.size.mas_equalTo(CGSizeMake(65 * Width_ato, 65 * Width_ato));
	}];

	for (int i = 0; i < _ballroom.ballroom_info.count; i++) {
		WTHotelExt *ext = _ballroom.ballroom_info[i];
		UILabel *label = [UILabel new];
		label.font = [WeddingTimeAppInfoManager fontWithSize:13];
		label.textAlignment = NSTextAlignmentCenter;
		label.textColor = rgba(102, 102, 102, 1);
		label.text = [NSString stringWithFormat:@"%@: %@",[LWUtil getString:ext.name andDefaultStr:@""] , [LWUtil getString:ext.value andDefaultStr:@""]];
		[view addSubview:label];
		[label mas_makeConstraints:^(MASConstraintMaker *make) {
			make.top.mas_equalTo((38 + 360+ 28 * i) * Height_ato);
			make.left.mas_equalTo(0);
			make.right.mas_equalTo(0);
			make.height.mas_equalTo(28 * Height_ato);
		}];
	}
	return view;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	CGFloat yOffset   = self.dataTableView.contentOffset.y;

	if (yOffset < 0)
	{
		CGFloat factor = ((ABS(yOffset)+ImageHeight)*ImageWidth)/ImageHeight;
		CGRect f = CGRectMake(-(factor-ImageWidth)/2, yOffset, factor, ImageHeight+ABS(yOffset));
		topImage.frame = f;
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
