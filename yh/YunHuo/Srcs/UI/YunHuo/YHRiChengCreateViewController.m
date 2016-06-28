//
//  YHRiChengCreateViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/15.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHRiChengCreateViewController.h"

#define kStartDateCellTag		1000
#define kEndDateCellTag			1001

@interface YHRiChengCreateViewController ()
@property (nonatomic) UITableViewCell	*datePickerCell;

@end

@implementation YHRiChengCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onBack:(id)sender {
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onAdd:(id)sender {
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//	// Return the number of sections.
//	return 3;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//	return 4;
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//	static NSString *titles[] = {@"今天",@"昨天",@"前一周"};
//	return titles[section];
//}
//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//	YHActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YHActivityCell" forIndexPath:indexPath];
//	cell.activityAvatar.image = [UIImage imageNamed:[NSString stringWithFormat:@"DefaultAvatar%d",2+rand()%5]];
//	cell.activityTime.text = [self.activityTimeFormater stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-(rand()%1000+indexPath.row*3600)]];
//	
//	NSString *tasktokens1[] = {@"新建了",@"更新了",@"完成了"};
//	cell.activityDetail.text = [NSString stringWithFormat:@"张三%@任务%04d",tasktokens1[rand()%3],rand()%10000];
//	
//	return cell;
//}
//
//
//- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	return 70;
//}

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


 #pragma mark - Table view delegate
 
 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
// - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//	NSIndexPath *pickerIndexPath = [tableView indexPathForCell:self.datePickerCell];
//	if ( cell.tag == kStartDateCellTag )
//	{
//		if ( self.datePickerCell != nil && pickerIndexPath != nil && pickerIndexPath.row == 1 )
//		{
//			[tableView beginUpdates];
//			[tableView deleteRowsAtIndexPaths:@[pickerIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//			[tableView endUpdates];
//		}
//		else
//		{
//			[tableView beginUpdates];
//			[tableView insertRowsAtIndexPaths:<#(NSArray *)#> withRowAnimation:<#(UITableViewRowAnimation)#>]
//			[tableView deleteRowsAtIndexPaths:@[pickerIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//			[tableView endUpdates];
//		}
//	}
//}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (UITableViewCell*) datePickerCell
{
	if ( _datePickerCell == nil )
	{
		_datePickerCell = [[UITableViewCell alloc] init];
		UIDatePicker *picker = [[UIDatePicker alloc] init];
		_datePickerCell.frame = picker.bounds;
		[_datePickerCell.contentView addSubview:picker];
	}
	return _datePickerCell;
}
@end
