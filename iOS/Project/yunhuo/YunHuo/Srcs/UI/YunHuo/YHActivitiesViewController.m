//
//  YHYunHuoActivitiesViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/13.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHActivitiesViewController.h"

@implementation YHActivityCell

- (void) awakeFromNib
{
	self.colorDot.layer.cornerRadius = self.colorDot.bounds.size.height/2;
}

- (void) layoutSubviews
{
	[super layoutSubviews];
	if ( self.isFirst && self.isLast )
	{
		self.timeLine.frame = CGRectZero;
	}
	else if ( self.isFirst )
	{
		self.timeLine.frame = CGRectMake(self.timeLine.frame.origin.x, self.bounds.size.height/2, self.timeLine.frame.size.width, self.bounds.size.height/2);
	}
	else if ( self.isLast )
	{
		self.timeLine.frame = CGRectMake(self.timeLine.frame.origin.x, 0, self.timeLine.frame.size.width, self.bounds.size.height/2);
	}
	else
	{
		self.timeLine.frame = CGRectMake(self.timeLine.frame.origin.x, 0, self.timeLine.frame.size.width, self.bounds.size.height);
	}
}
@end

@interface YHActivitiesViewController ()
@property (nonatomic) NSDateFormatter	*activityTimeFormater;

@end

@implementation YHActivitiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.activityTimeFormater = [[NSDateFormatter alloc] init];
	[self.activityTimeFormater setDateFormat:@"YY.MM.DD HH:mm"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated
{
	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	static NSString *titles[] = {@"今天",@"昨天",@"前一周"};
	return titles[section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YHActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YHActivityCell" forIndexPath:indexPath];
	cell.activityAvatar.image = [UIImage imageNamed:[NSString stringWithFormat:@"DefaultAvatar%d",2+rand()%5]];
	cell.activityTime.text = [self.activityTimeFormater stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-(rand()%1000+indexPath.row*3600)]];
	
	NSString *tasktokens1[] = {@"新建了",@"更新了",@"完成了"};
	cell.activityDetail.text = [NSString stringWithFormat:@"张三%@任务%04d",tasktokens1[rand()%3],rand()%10000];

	cell.isFirst = NO;
	cell.isLast = NO;
	if ( indexPath.row == 0 )
	{
		cell.isFirst = YES;
	}
	//TBD
	if ( indexPath.row == 3 )
	{
		cell.isLast = YES;
	}
	
    return cell;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 70;
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
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
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

- (IBAction)startWork:(id)sender
{
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainScreen" bundle:nil];
	UIViewController *mainscreen = [storyboard instantiateInitialViewController];
	[UIApplication sharedApplication].keyWindow.rootViewController = mainscreen;
}
@end
