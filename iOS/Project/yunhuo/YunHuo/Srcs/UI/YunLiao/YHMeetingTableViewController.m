//
//  YHMeetingTableViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/14.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHMeetingTableViewController.h"
#import "YHMeetingInfo.h"

@implementation YHMeetingCell

- (void)awakeFromNib
{
	self.boardBG.image = [[UIImage imageNamed:@"BoardBG"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
}

@end

@interface YHMeetingTableViewController ()
@property (nonatomic) NSMutableArray	*meetings;

@end

@implementation YHMeetingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self loadTestData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadTestData
{
	self.meetings = [NSMutableArray array];
	
	YHMeetingInfo *info = [[YHMeetingInfo alloc] init];
	info.meetingTime = [NSDate dateWithTimeIntervalSinceNow:3600*rand()%8];
	info.topics = [NSMutableArray arrayWithArray:@[@"讨论任务1的情况"]];
	[self.meetings addObject:info];

	info = [[YHMeetingInfo alloc] init];
	info.meetingTime = [NSDate dateWithTimeIntervalSinceNow:3600*(rand()%8+24)];
	info.topics = [NSMutableArray arrayWithArray:@[@"讨论任务1的情况"]];
	[self.meetings addObject:info];
	
	info = [[YHMeetingInfo alloc] init];
	info.meetingTime = [NSDate dateWithTimeIntervalSinceNow:3600*(rand()%8+48)];
	info.topics = [NSMutableArray arrayWithArray:@[@"讨论任务1的情况"]];
	[self.meetings addObject:info];
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.meetings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
	YHMeetingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MeetingCell"];
	YHMeetingInfo *info = self.meetings[indexPath.row];
	cell.meetingIndex.text = [NSString stringWithFormat:@"%d",indexPath.row+1];
	cell.meetingTime.text = [NSString stringWithFormat:@"%@",info.meetingTime];
	cell.meetingTopic.text = [NSString stringWithFormat:@"%@",info.topics[0]];
	//更新与会人士头像，名字
	
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 177;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
