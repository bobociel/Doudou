//
//  YHKaoQinViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/21.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHKaoQinViewController.h"
#import "YHDataCache.h"
#import "NSDate+Category.h"
#import "LocationMgr.h"

@implementation YHKaoQinCell

- (void) setKaoqin:(YHKaoQin *)kaoqin
{
	_kaoqin = kaoqin;
	self.timeLabel.text = [NSString stringWithFormat:@"%02d/%02d %02d:%02d",kaoqin.time.month,kaoqin.time.day,kaoqin.time.hour,kaoqin.time.minute];
	self.addressLabel.text = kaoqin.address;
	if ( kaoqin.type == YHKaoQinTypeCheckIn )
	{
		self.kaoqinEventLabel.text = @"已签到";
		self.kaoqinEventLabel.textColor = [UIColor blueColor];
	}
	else
	{
		self.kaoqinEventLabel.text = @"已签退";
		self.kaoqinEventLabel.textColor = [UIColor redColor];
	}
}

@end

@interface YHKaoQinViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic) NSMutableArray *kaoqins;

@end

@implementation YHKaoQinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.kaoqins = [YHDataCache instance].kaoqinRecords;
	[self.tableView reloadData];
	
	NSDate *time = [NSDate date];
	self.timeLabel.text = [NSString stringWithFormat:@"今天 %02d:%02d",time.hour,time.minute];
	[self updateQDBtn];
}

- (void) updateQDBtn
{
	if ( [YHDataCache instance].hasCheckedInToday )
	{
		[self.kaoqinBtn setTitle:@"签退" forState:UIControlStateNormal];
	}
	else
	{
		[self.kaoqinBtn setTitle:@"签到" forState:UIControlStateNormal];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.kaoqins.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	YHKaoQinCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YHKaoQinCell" forIndexPath:indexPath];
	cell.kaoqin = self.kaoqins[indexPath.row];
	return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 44;
}

- (IBAction)onCheck:(id)sender {
	YHKaoQin *kaoqin = [[YHKaoQin alloc] init];
	kaoqin.time	= [NSDate date];
	//确认今天是否已签到
	if ( [YHDataCache instance].hasCheckedInToday )
	{
		//签退
		[YHDataCache instance].hasCheckedInToday = NO;
		kaoqin.type = YHKaoQinTypeCheckOut;
	}
	else
	{
		//签到
		[YHDataCache instance].hasCheckedInToday = YES;
		kaoqin.type = YHKaoQinTypeCheckIn;
	}
	kaoqin.location = [LocationMgr instance].location;
	
	__block YHKaoQin *__kq = kaoqin;
	[[LocationMgr instance].geoCoder reverseGeocodeLocation:kaoqin.location completionHandler:^(NSArray *placemarks, NSError *error) {
		if ( placemarks.count > 0 )
		{
			CLPlacemark *place = placemarks[0];
			NSString *addr = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@",place.country,place.administrativeArea,place.locality,place.subLocality,place.thoroughfare,place.name];
			__kq.address = addr;
			[[YHDataCache instance] save];
			[self.tableView reloadData];
		}
	}];
	[self updateQDBtn];
	
	[self.kaoqins addObject:kaoqin];
	[self.kaoqinBtn setTitle:@"签退" forState:UIControlStateNormal];
	[[YHDataCache instance] save];
	
	[self.tableView reloadData];
	//TBD,使用insert？
}
@end
