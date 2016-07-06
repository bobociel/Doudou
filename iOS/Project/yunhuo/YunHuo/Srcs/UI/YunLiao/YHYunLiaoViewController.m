 //
//  YHYunLiaoViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/10.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHYunLiaoViewController.h"
#import "ZBarReaderViewController.h"
#import "KxMenu.h"

typedef NS_ENUM(NSInteger, YunLiaoCellType)
{
	YunLiaoCellTypeGroupNotif		= 0,
	YunLiaoCellTypeCloudSecretary,
	YunLiaoCellTypeFileTransfer,
	YunLiaoCellTypeCount,
};

@implementation YHChatHistoryCell

- (void) awakeFromNib
{
	self.badageLabel.layer.cornerRadius = self.badageLabel.bounds.size.height/2;
}

@end

@interface YHYunLiaoViewController ()<ZBarReaderDelegate>

@end

@implementation YHYunLiaoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
//	self.tableView.editing = YES;
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

- (IBAction)addAction:(id)sender
{
	NSArray *menuItems =
	@[
	  [KxMenuItem menuItem:@"Join a meeting" image:[UIImage imageNamed:@"JoinMeetingIcon"] target:self action:@selector(onJoin)],
	  [KxMenuItem menuItem:@"Schedule a meeting" image:[UIImage imageNamed:@"ScheduleMeetingIcon"] target:self action:@selector(onSchedule)],
	  [KxMenuItem menuItem:@"Friend" image:[UIImage imageNamed:@"BtnAdd"] target:self action:@selector(onFriend)],
	  [KxMenuItem menuItem:@"Group" image:[UIImage imageNamed:@"BtnAdd"] target:self action:@selector(onGroup)],
	  [KxMenuItem menuItem:@"Scan" image:[UIImage imageNamed:@"BtnAdd"] target:self action:@selector(onScan)],
	  ];
//	((KxMenuItem*)menuItems[0]).foreColor = BROWN_TEXT_COLOR;
//	((KxMenuItem*)menuItems[1]).foreColor = BROWN_TEXT_COLOR;
	CGRect frame = ((UIButton*)sender).frame;
	frame.origin.y += 20;
	[KxMenu showMenuInView:[UIApplication sharedApplication].keyWindow fromRect:frame menuItems:menuItems];
}

- (void) onJoin
{
	[self performSegueWithIdentifier:@"showJoin" sender:nil];
}

- (void) onSchedule
{
	[self performSegueWithIdentifier:@"showSchedule" sender:nil];
}

- (void) onFriend
{
	[self performSegueWithIdentifier:@"showFriend" sender:nil];
}

- (void) onGroup
{
	[self performSegueWithIdentifier:@"showGroup" sender:nil];	
}

- (void) onScan
{
	ZBarReaderViewController *reader = [[ZBarReaderViewController alloc] init];
	reader.hidesBottomBarWhenPushed = YES;
	reader.showsZBarControls = NO;
	//	reader.tracksSymbols = YES;
	reader.readerDelegate = self;
	reader.supportedOrientationsMask = ZBarOrientationMaskAll;
	
	ZBarImageScanner *scanner = reader.scanner;
	
	[scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
	//	[self presentModalViewController: reader animated: YES];
	[self.navigationController pushViewController:reader animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	if ( indexPath.row == YunLiaoCellTypeGroupNotif )
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"GroupNotifCell" forIndexPath:indexPath];
	}
	else if ( indexPath.row == YunLiaoCellTypeCloudSecretary )
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"CloudSecretaryCell" forIndexPath:indexPath];
	}
	else if ( indexPath.row == YunLiaoCellTypeFileTransfer )
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"FileTransferCell" forIndexPath:indexPath];
	}
	else
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"ChatHistoryCell" forIndexPath:indexPath];
	}
	return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//	if ( indexPath.row < YunLiaoCellTypeCount )
//	{
//		return 44;
//	}
//	else
//	{
		return 58;
//	}
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
//	if ( indexPath.row < YunLiaoCellTypeCount )
//	{
//		return NO;
//	}
//	else
//	{
		return YES;
//	}
}

- (void) tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
	
}

@end
