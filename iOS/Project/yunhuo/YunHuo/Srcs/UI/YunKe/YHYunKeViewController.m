//
//  YHYunKeViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/10.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHYunKeViewController.h"

@interface YHYunKeViewController ()

@end

@implementation YHYunKeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self updateAvatar];
}

//- (void) viewDidAppear:(BOOL)animated
//{
//	TBD?
//	[self.view bringSubviewToFront:self.addBtn];
//	[self.view bringSubviewToFront:self.addToolbar];
//	[self.view bringSubviewToFront:self.editToolbar];
//}

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

- (void) updateAvatar
{
	self.avatar.image = [YHDataCache instance].profile.avatar;
	self.avatar.image = [UIImage imageNamed:@"DefaultAvatar"];	//TBD
}

//- (IBAction)onFavAddImage
//{
//	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
//															 delegate:self
//													cancelButtonTitle:@"取消"
//											   destructiveButtonTitle:nil
//													otherButtonTitles:@"拍照",@"从手机相册选择", nil];
//	[actionSheet showInView:self.view];
//}
//
//- (IBAction)onEdit:(id)sender {
//	self.isInEdit = !self.isInEdit;
//	UIButton *editBtn = (UIButton*)sender;
//	if ( self.isInEdit )
//	{
//		[editBtn setTitle:@"Cancel" forState:UIControlStateNormal];
//		[self.tabBarController.tabBar setHidden:YES];
//		[UIView animateWithDuration:0.25 animations:^{
//			self.addBtn.center = CGPointMake(CGRectGetMidX(self.view.bounds),CGRectGetMaxY(self.view.bounds) + 30);
//			self.editToolbar.center = CGPointMake(CGRectGetMidX(self.view.bounds),CGRectGetMaxY(self.view.bounds) - 22);
//		}];
//	}
//	else
//	{
//		[editBtn setTitle:@"Edit" forState:UIControlStateNormal];
//		[self.tabBarController.tabBar setHidden:NO];
//		[UIView animateWithDuration:0.25 animations:^{
//			self.addBtn.center = CGPointMake(CGRectGetMidX(self.view.bounds),CGRectGetMaxY(self.view.bounds) - 75);
//			self.editToolbar.center = CGPointMake(CGRectGetMidX(self.view.bounds),CGRectGetMaxY(self.view.bounds) + 22);
//		}];
//	}
//	[self.selectStatus removeAllObjects];
//	[self.tableView reloadData];
//}
//
//- (IBAction)onShare:(id)sender
//{
//	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
//															 delegate:self
//													cancelButtonTitle:@"取消"
//											   destructiveButtonTitle:nil
//													otherButtonTitles:@"分享给QQ好友",@"分享给微信好友", nil];
//	[actionSheet showInView:self.view];
//}
//
//- (IBAction)onAdd:(id)sender
//{
//	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"对不起" message:@"来不及做了，请等下一版本" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//	[alertView show];
//	self.isShowAddMenu = !self.isShowAddMenu;
//	if ( self.isShowAddMenu )
//	{
//		[self.tabBarController.tabBar setHidden:YES];
//		[UIView animateWithDuration:0.25 animations:^{
//			self.addBtn.transform = CGAffineTransformMakeRotation(M_PI_4);
//			self.addToolbar.center = CGPointMake(CGRectGetMidX(self.view.bounds),CGRectGetMaxY(self.view.bounds) - 142);
//		}];
//	}
//	else
//	{
//		[self.tabBarController.tabBar setHidden:NO];
//		[UIView animateWithDuration:0.25 animations:^{
//			self.addBtn.transform = CGAffineTransformIdentity;
//			self.addToolbar.center = CGPointMake(CGRectGetMidX(self.view.bounds),CGRectGetMaxY(self.view.bounds) + 22);
//		}];
//	}
//}
//
//#pragma mark UITextFieldDelegate
//- (BOOL) textFieldShouldReturn:(UITextField *)textField
//{
//	return YES;
//}
//
//#pragma make UIImagePickerControllerDelegate
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
////	UIImage *photo = info[UIImagePickerControllerEditedImage];
//	//TBD,做缩放
////	self.userInfo.photo = [photo scaleToSize:CGSizeMake(50, 50)];
////	[FYConfig instance].user.userInfo.photo = self.userInfo.photo;
////	self.myPhoto.image = self.userInfo.photo;
////	[[FYServerAgent instance] userPhotoSet:self.userInfo.photo];
//	
//	//TBD,上传,缓存
////	[YHDataCache instance].profile.avatar = photo;
////	[self updateAvatar];
//	[picker dismissViewControllerAnimated:YES completion:nil];
//}
//
//#pragma make UIActionSheetDelegate
//- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//	if ( buttonIndex == actionSheet.cancelButtonIndex )
//	{
//		return;
//	}
//	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//	picker.delegate = self;
//	
//	picker.allowsEditing = YES;
//	[self presentViewController:picker animated:YES completion:^{
//	}];
//	
//	if ( buttonIndex == 0 )
//	{
//		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//	}
//	else if ( buttonIndex == 1 )
//	{
//		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//	}
//}
//
//#pragma mark UITableViewDataSource
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//	return 10;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	YHFavCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YHFavCell" forIndexPath:indexPath];
//	cell.isSelectableMode = self.isInEdit;
//	cell.isSelected = [self.selectStatus indexOfObject:@(indexPath.row)] != NSNotFound;
//	return cell;
//}
//
//#pragma mark UITableViewDelegate
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	return 90;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//	return 0;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//	return 0;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//	return nil;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//	return nil;
//}
//
//- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	YHFavCell *cell = (YHFavCell*)[tableView cellForRowAtIndexPath:indexPath];
//	if ( self.isInEdit )
//	{
//		if ( [self.selectStatus indexOfObject:@(indexPath.row)] == NSNotFound )
//		{
//			[self.selectStatus addObject:@(indexPath.row)];
//			cell.isSelected = YES;
//		}
//		else
//		{
//			[self.selectStatus removeObject:@(indexPath.row)];
//			cell.isSelected = NO;;
//		}
////		[cell setNeedsDisplay];
////		[self.tableView reloadData];
//	}
//	else
//	{
//		[self performSegueWithIdentifier:@"showDetail" sender:cell];
//	}
//}

@end
