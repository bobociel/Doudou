//
//  YHChatSearchViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/19.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHChatSearchViewController.h"

@interface YHChatSearchViewController ()

@end

@implementation YHChatSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.searchBar becomeFirstResponder];
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

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 0;
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	UITableViewCell *cell = nil;
//	cell = [tableView dequeueReusableCellWithIdentifier:@"ChatHistoryCell" forIndexPath:indexPath];
//	return cell;
//}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 58;
}

//- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	return UITableViewCellEditingStyleDelete;
//}
//
//- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	if ( indexPath.row < YunLiaoCellTypeCount )
//	{
//		return NO;
//	}
//	else
//	{
//		return YES;
//	}
//}
//
//- (void) tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
//{
//	
//}
@end
