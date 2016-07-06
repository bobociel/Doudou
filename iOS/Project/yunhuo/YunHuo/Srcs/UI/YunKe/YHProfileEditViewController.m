//
//  YHProfieViewController.m
//  YunHuo
//
//  Created by yuyunfeng on 15/1/16.
//  Copyright (c) 2015年 yuyunfeng. All rights reserved.
//

#import "YHProfileEditViewController.h"

@interface YHProfileEditViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation YHProfileEditViewController

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

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

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

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ( indexPath.row == 0 )
	{
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																 delegate:self
														cancelButtonTitle:@"取消"
												   destructiveButtonTitle:nil
														otherButtonTitles:@"拍照",@"从手机相册选择", nil];
		[actionSheet showInView:self.view];
	}
}


#pragma make UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	//	UIImage *photo = info[UIImagePickerControllerEditedImage];
	//TBD,做缩放
	//	self.userInfo.photo = [photo scaleToSize:CGSizeMake(50, 50)];
	//	[FYConfig instance].user.userInfo.photo = self.userInfo.photo;
	//	self.myPhoto.image = self.userInfo.photo;
	//	[[FYServerAgent instance] userPhotoSet:self.userInfo.photo];
	
	//TBD,上传,缓存
	//	[YHDataCache instance].profile.avatar = photo;
	//	[self updateAvatar];
	[picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma make UIActionSheetDelegate
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ( buttonIndex == actionSheet.cancelButtonIndex )
	{
		return;
	}
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	
	picker.allowsEditing = YES;
	[self presentViewController:picker animated:YES completion:^{
	}];
	
	if ( buttonIndex == 0 )
	{
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	}
	else if ( buttonIndex == 1 )
	{
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	}
}
@end
