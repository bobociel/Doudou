//
//  YHTasksViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/15.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHTasksViewController.h"

@implementation YHTaskCell

- (void) awakeFromNib
{
	NSMutableArray *rightbtns = [NSMutableArray array];
	[rightbtns addUtilityButtonWithColor:[UIColor orangeColor] title:@"置顶"];
	[rightbtns addUtilityButtonWithColor:[UIColor greenColor] title:@"完成"];
	[rightbtns addUtilityButtonWithColor:[UIColor redColor] title:@"删除"];
	self.rightUtilityButtons = rightbtns;
	[self doInitWithRightBtns:rightbtns];
}


@end

@interface YHTasksViewController ()

@end

@implementation YHTasksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	YHTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YHTaskCell" forIndexPath:indexPath];
//	cell.project = [YHDataCache instance].projects[indexPath.row];
	return cell;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

//- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	return UITableViewCellEditingStyleDelete;
//}
//
//- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	//	if ( indexPath.row < YunLiaoCellTypeCount )
//	//	{
//	//		return NO;
//	//	}
//	//	else
//	//	{
//	return YES;
//	//	}
//}
//
//- (void) tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
//{
//	
//}

#pragma mark - SWTableViewCellDelegate
//- (void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index;
//- (void)swippableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state;

- (void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
	switch (index)
	{
		case 0:
			break;
		case 1:
			break;
		case 2:
			break;
		default:
			break;
	}
}


@end
