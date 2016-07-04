//
//  YHRiChengTableViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/15.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHRiChengViewController.h"

@implementation YHRiChengLineCell

@end

@implementation YHRiChengCardCell

- (void)awakeFromNib {
	// Initialization code
	self.boardView.layer.cornerRadius = 15.0;
//	self.boardView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//	self.boardView.layer.borderWidth = 0.5;
//	self.boardView.layer.shadowRadius = 5.0;
//	self.boardView.layer.shadowColor = [UIColor blackColor].CGColor;
//	self.boardView.layer.shadowOffset = CGSizeMake(1,1);
//	self.boardView.layer.shadowOpacity = 1.0;
	
	self.boardBG.image = [[UIImage imageNamed:@"BoardBG"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
}

@end

@interface YHRiChengViewController ()

@end

@implementation YHRiChengViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.calendar = [[JTCalendar alloc] init];
	
	// All modifications on calendarAppearance have to be done before setMenuMonthsView and setContentView
	// Or you will have to call reloadAppearance
	{
		self.calendar.calendarAppearance.calendar.firstWeekday = 2; // Sunday == 1, Saturday == 7
		self.calendar.calendarAppearance.dayCircleRatio = 9. / 10.;
		self.calendar.calendarAppearance.ratioContentMenu = 1.;
	}
	
	[self.calendar setMenuMonthsView:self.calendarMenuView];
	[self.calendar setContentView:self.calendarContentView];
	[self.calendar setDataSource:self];
	
	self.isUsingCardView = YES;
}

- (void) viewWillAppear:(BOOL)animated
{
	[self.cardTableView reloadData];
	[self.tableViewForCalendar reloadData];
	[self.calendar reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.calendar setMenuMonthsView:nil];
	[self.calendar setContentView:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSwitch:(id)sender
{
	[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
		if ( self.isUsingCardView )
		{
			self.calendarView.alpha = 1.0;
			self.cardTableView.alpha = 0.0;
//			[self.view insertSubview:self.calendarView atIndex:0];
//			[self.cardTableView removeFromSuperview];
		}
		else
		{
			self.calendarView.alpha = 0.0;
			self.cardTableView.alpha = 1.0;
//			[self.view insertSubview:self.cardTableView atIndex:0];
//			[self.calendarView removeFromSuperview];
		}
	} completion:^(BOOL finished) {
	}];
	self.isUsingCardView = !self.isUsingCardView;
}

#pragma mark - Buttons callback

- (IBAction)didGoTodayTouch
{
	[self.calendar setCurrentDate:[NSDate date]];
}

- (IBAction)didChangeModeTouch
{
	self.calendar.calendarAppearance.isWeekMode = !self.calendar.calendarAppearance.isWeekMode;
	
	[self transitionExample];
}

#pragma mark - JTCalendarDataSource

- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date
{
	return (rand() % 10) == 1;
}

- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date
{
	NSLog(@"Date: %@", date);
}

#pragma mark - Transition examples

- (void)transitionExample
{
	CGFloat newHeight = 300;
	if(self.calendar.calendarAppearance.isWeekMode)
	{
		newHeight = 75.;
	}
	
	[UIView animateWithDuration:.5
					 animations:^{
						 self.calendarContentView.frame = CGRectMake(0,CGRectGetMaxY(self.calendarMenuView.frame),self.calendarContentView.bounds.size.width,newHeight);
					 }];
	
	[UIView animateWithDuration:.25
					 animations:^{
						 self.calendarContentView.layer.opacity = 0;
					 }
					 completion:^(BOOL finished) {
						 [self.calendar reloadAppearance];
						 
						 [UIView animateWithDuration:.25
										  animations:^{
											  self.calendarContentView.layer.opacity = 1;
										  }];
					 }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ( [self.cardTableView isEqual:tableView] )
	{
		//卡片列表
		return 4;
	}
	else
	{
		//日历列表
		return 4;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ( [self.cardTableView isEqual:tableView] )
	{
		YHRiChengCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YHRiChengCardCell" forIndexPath:indexPath];
		cell.richengIndex.text = [NSString stringWithFormat:@"%d",indexPath.row+1];
		return cell;
	}
	else
	{
		YHRiChengLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YHRiChengLineCell" forIndexPath:indexPath];
		cell.richengIndex.text = [NSString stringWithFormat:@"%d",indexPath.row+1];
		return cell;
	}
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ( [tableView isEqual:self.cardTableView] )
	{
		return 180;		
	}
	else
	{
		return 44;
	}
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
