//
//  YHYunQuanSearchViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/22.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHYunQuanSearchViewController.h"
#import "HYSegmentedControl.h"

@interface YHYunQuanSearchViewController ()

@end

@implementation YHYunQuanSearchViewController

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

- (void) viewDidAppear:(BOOL)animated
{
	[self.searchBar becomeFirstResponder];
}

#pragma mark - UISearchBarDelegate
- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 0;
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

#pragma mark - HYSegmentedControlDelegate
- (void) hySegmentedControlSelectAtIndex:(NSInteger)index
{
//	NSString *controllerStr = self.pageControllersClass[index];
//	if ( self.pageControllers[controllerStr] == nil )
//	{
//		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainScreen" bundle:nil];
//		self.pageControllers[controllerStr] = [storyboard instantiateViewControllerWithIdentifier:controllerStr];
//		[self addChildViewController:self.pageControllers[controllerStr]];
//	}
//	[self.pageControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//		UIViewController *vc = (UIViewController*)obj;
//		[vc.view removeFromSuperview];
//	}];
//	UIView *view = [self.pageControllers[controllerStr] view];
//	view.frame = self.pageContainer.bounds;
//	[self.pageContainer addSubview:view];
}

#pragma mark - HYSegmentedControlDataSource
- (NSArray*) titlesForSegmentControl:(HYSegmentedControl*)segmentControl
{
	return @[@"找人",@"动态",@"八卦",@"职位"];
}
@end
