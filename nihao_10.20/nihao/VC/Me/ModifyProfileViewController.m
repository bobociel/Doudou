//
//  ModifyProfileViewController.m
//  nihao
//
//  Created by HelloWorld on 7/30/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "ModifyProfileViewController.h"
#import "ProfileCell.h"
#import "ProfileUserIconCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppConfigure.h"
#import "BaseFunction.h"
#import "HttpManager.h"
#import "ModifyViewController.h"
#import "NationalityViewController.h"
#import "Nationality.h"
#import "RegionViewController.h"

@interface ModifyProfileViewController () <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ModifyViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

static NSString *UserIconCellIdentifier = @"ProfileUserIconCell";
static NSString *UserProfileCellIdentifier = @"ProfileCell";

@implementation ModifyProfileViewController {
//	NSMutableDictionary *profileRows;
	NSArray *profileDescriptions;
//	BOOL isChangedPhoto;
	// 保存修改成功之后的用户信息
//	NSMutableDictionary *myProfile;
	// 保存用户修改的信息，但是还没有更新到服务器
	NSMutableDictionary *myModifiedProfile;
	// 选择修改的信息所在的位置
	NSIndexPath *selectedIndexPath;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.title = @"My Profile";
	[self dontShowBackButtonTitle];
	
	profileDescriptions = @[@[@"Icon", @"Nickname", @"Phone"],
							@[@"Nationality",@"Region",@"Birthday", @"Gender"]];// @[@"Profession", @"Hobbies"]
	
	myModifiedProfile = [[NSMutableDictionary alloc] initWithDictionary:[AppConfigure loginUserProfile]];
	selectedIndexPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
	
	[self initViews];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.hidesBottomBarWhenPushed = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[AppConfigure setObject:@"YES" ForKey:ME_SHOULD_REFRESH];
}

#pragma mark - Lifecycle

- (void)dealloc {
	self.tableView.delegate = nil;
	self.tableView.dataSource = nil;
	[self.tableView removeFromSuperview];
	self.tableView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)initViews {
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.tableFooterView = [[UIView alloc] init];
	self.tableView.sectionHeaderHeight = 0;
	self.tableView.sectionFooterHeight = 15;
	self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
	[self.tableView registerNib:[UINib nibWithNibName:@"ProfileUserIconCell" bundle:nil] forCellReuseIdentifier:UserIconCellIdentifier];
	[self.tableView registerNib:[UINib nibWithNibName:@"ProfileCell" bundle:nil] forCellReuseIdentifier:UserProfileCellIdentifier];
	self.tableView.backgroundColor = self.view.backgroundColor;
	[self.view addSubview:self.tableView];
}

- (NSString *)getProfileAtIndexPath:(NSIndexPath *)indexPath {
	NSString *value = @"";
	NSInteger row = indexPath.row;
	if (indexPath.section == 0) {
		switch (row) {
			case 0:// 修改头像
				value = [myModifiedProfile objectForKey:LOGINED_USER_ICON_URL];
				break;
			case 1:// 修改用户名
				value = [myModifiedProfile objectForKey:LOGINED_USER_NICKNAME];
				break;
			case 2:// 修改手机号
				value = [myModifiedProfile objectForKey:LOGINED_USER_PHONE];
				break;
		}
	} else if (indexPath.section == 1) {
		switch (row) {
			case 0:// 修改国籍
				value = [myModifiedProfile objectForKey:LOGINED_USER_COUNTRY_NAME_EN];
				break;
            case 1://修改居住区域
                value = [myModifiedProfile objectForKey:REGISTER_USER_CITY_ID];
                break;
			case 2:// 修改年龄
				value = [myModifiedProfile objectForKey:LOGINED_USER_BIRTHDAY];
				break;
			case 3:// 修改性别
				value = [[myModifiedProfile objectForKey:LOGINED_USER_SEX] integerValue] == UserSexTypeMale ? @"Male" : @"Female";
				break;
		}
	} else if (indexPath.section == 2) {
		switch (row) {
			case 0:// 修改职位
				value = [myModifiedProfile objectForKey:LOGINED_USER_JOB];
				break;
			case 1:// 修改爱好
				value = [myModifiedProfile objectForKey:LOGINED_USER_HOBBIES];
				break;
		}
	}
	
	return value;
}

- (NSString *)getProfileDescriptionAtIndexPath:(NSIndexPath *)indexPath {
	return profileDescriptions[indexPath.section][indexPath.row];
}

// 显示照片选择菜单
- (void)showPickerActionSheet {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose from Photos", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:self.view];
}

- (void)takePhotoFromCamera:(BOOL)isFromCamera {
	// 判断是否支持相机
//	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		// 相机
		NSUInteger sourceType = isFromCamera ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypeSavedPhotosAlbum;
		// 跳转到相机或相册页面
		UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
		imagePickerController.delegate = self;
		// 设置照片是否可编辑
		imagePickerController.allowsEditing = YES;
		imagePickerController.sourceType = sourceType;
		// 此处的 delegate 是上层的 ViewController，如果你直接在 ViewController 使用，直接 self 就可以了
		[self presentViewController:imagePickerController animated:YES completion:^{}];
//	}
}

- (void)openModifyTypeViewControllerByType:(ModifyType)type atIndexPath:(NSIndexPath *)indexPath {
	ModifyViewController *modifyViewController = [[ModifyViewController alloc] init];
	modifyViewController.modifyType = type;
	modifyViewController.delegate = self;
	if (indexPath.section == 0 && indexPath.row == 1) {
		UINavigationController *nav = [self navigationControllerWithRootViewController:modifyViewController navBarTintColor:AppBlueColor];
		[self presentViewController:nav animated:YES completion:^{}];
	} else {
		[self.navigationController pushViewController:modifyViewController animated:YES];
	}
}

#pragma mark - ModifyViewControllerDelegate

- (void)modifyFinishedWithType:(ModifyType)modifyType modifiedValue:(NSString *)value {
//	NSLog(@"value = %@", value);
	
	switch (modifyType) {
		case ModifyTypeNickname:
			[myModifiedProfile setValue:value forKey:LOGINED_USER_NICKNAME];
			break;
		case ModifyTypeBirthday:
		case ModifyTypeAge:
			[myModifiedProfile setValue:value forKey:LOGINED_USER_BIRTHDAY];
			break;
		case ModifyTypeGender:
			[myModifiedProfile setValue:value forKey:LOGINED_USER_SEX];
			break;
		case ModifyTypeOccupation:
			break;
		case ModifyTypeHobbies:
			break;
	}
	
	[self.tableView reloadRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
	[self updateUserProfile];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {// 拍照
		[self takePhotoFromCamera:YES];
	} else if (buttonIndex == 1) {// 从相册选择
		[self takePhotoFromCamera:NO];
	}
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
		// 获取编辑后的照片
		UIImage *editedImage = [info valueForKey:@"UIImagePickerControllerEditedImage"];
//		self.userIconImageView.image = editedImage;
		NSData *imageData = UIImageJPEGRepresentation(editedImage, kImageCompressionQualityDefault);
		[self uploadUserIconwithData:imageData];
	}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}

#pragma mark - networking
#pragma mark 上传用户头像
- (void)uploadUserIconwithData:(NSData *)data {
	[self showHUDWithText:@"Uploading..."];
	NSString *iconName = [NSString stringWithFormat:@"ios_userid_%@_%@.jpg", [AppConfigure objectForKey:LOGINED_USER_ID], [BaseFunction stringFromCurrent]];
	[HttpManager userIconUploadWithImageData:data parameters:nil iconName:iconName success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
		//        NSLog(@"用户头像上传返回结果：%@", resultDict);
		if (rtnCode == 0) {
			// 保存用户头像在服务器上的地址
			NSArray *fileArray = resultDict[@"result"][@"items"];
			if (fileArray.count > 0) {
				[self hideHud];
				NSString *fileServerPath = fileArray[0][@"picture_original_network_url"];
				// 上传图片成功之后，更新修改的用户信息
				[myModifiedProfile setValue:fileServerPath forKey:LOGINED_USER_ICON_URL];
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGO_CHANGED object:self];
				[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
				[self updateUserProfile];
			} else {
				[self showHUDErrorWithText:@"Failed"];
			}
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
		[self showHUDNetError];
	}];
}

- (void)updateUserProfile {
//	NSLog(@"complete user info myModifiedProfile = %@", myModifiedProfile);
	[HttpManager completeUserInfoByParameters:myModifiedProfile success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
		if (rtnCode == 0) {
			// 更新本地保存的用户信息
			[AppConfigure saveUserProfile:myModifiedProfile];
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
		[self showHUDNetError];
	}];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger numberOfRows = 0;
	switch (section) {
		case 0:
            numberOfRows = 3;
            break;
		case 1:
			numberOfRows = 4;
			break;
		case 2:
			numberOfRows = 4;
			break;
	}
	
	return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 0) {
		return 80;
	} else {
		return 50;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 0) {
		ProfileUserIconCell *cell = (ProfileUserIconCell *)[tableView dequeueReusableCellWithIdentifier:UserIconCellIdentifier];
		NSInteger userSex = [[NSString stringWithFormat:@"%@", [AppConfigure objectForKey:LOGINED_USER_SEX]] integerValue];
		NSString *iconURLString = [myModifiedProfile objectForKey:LOGINED_USER_ICON_URL];
		if (IsStringEmpty(iconURLString)) {
			if (userSex == UserSexTypeFemale) {
				cell.originalIconImageView.image = [UIImage imageNamed:@"default_icon_female"];
			} else {
				cell.originalIconImageView.image = [UIImage imageNamed:@"default_icon_male"];
			}
		} else {
			[cell.originalIconImageView sd_setImageWithURL:[NSURL URLWithString:[BaseFunction convertServerImageURLToURLString:iconURLString]] placeholderImage:[UIImage imageNamed:@"img_is_loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
				if (!error) {
					cell.originalIconImageView.image = image;
				} else {
					cell.originalIconImageView.image = [UIImage imageNamed:@"img_is_load_failed"];
					NSLog(@"imageURL = %@", imageURL);
				}
			}];
		}
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		return cell;
	} else {
		ProfileCell *cell = (ProfileCell *)[tableView dequeueReusableCellWithIdentifier:UserProfileCellIdentifier forIndexPath:indexPath];
		if (indexPath.section == 0 && indexPath.row == 2) {// Phone
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		} else {
			cell.selectionStyle = UITableViewCellSelectionStyleDefault;
		}
		cell.cellDescriptionLabel.text = [self getProfileDescriptionAtIndexPath:indexPath];
		
		NSString *profileString = [self getProfileAtIndexPath:indexPath];
		if (indexPath.section == 1 && indexPath.row == 2) {
			cell.cellValueLabel.text = [profileString componentsSeparatedByString:@" "][0];
		} else {
			cell.cellValueLabel.text = profileString;
		}
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		return cell;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return @"";
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == 0 && indexPath.row == 0) {// 修改头像
		[self showPickerActionSheet];
	} else {
		selectedIndexPath = indexPath;
		
		NSInteger row = indexPath.row;
		if (indexPath.section == 0) {
			switch (row) {
				case 1:// 修改用户名
					[self openModifyTypeViewControllerByType:ModifyTypeNickname atIndexPath:indexPath];
					break;
				case 2:// 修改手机号
//					[self showHUDWithText:@"If you want to change your phone number, please send us your request by email." delay:1.5];
					break;
			}
		} else if (indexPath.section == 1) {
			switch (row) {
				case 0: {// 修改国籍
					NationalityViewController *controller = [[NationalityViewController alloc] initWithNibName:@"NationalityViewController" bundle:nil];
					__weak typeof(self) weakSelf = self;
					controller.nationChoosed = ^(Nationality *nation) {
						NSString *nationalityIDString = [NSString stringWithFormat:@"%ld", nation.country_id];
						[myModifiedProfile setObject:nationalityIDString forKey:LOGINED_USER_COUNTRY_ID];
						[myModifiedProfile setObject:nation.country_name_en forKey:LOGINED_USER_COUNTRY_NAME_EN];
						[weakSelf modifyFinishedWithType:NSIntegerMax modifiedValue:@""];
					};
					[self.navigationController pushViewController:controller animated:YES];
				}
					break;
                case 1://修改用户居住地
                    [self modifyUserRegionController];
                    break;
				case 2:// 修改年龄
					[self openModifyTypeViewControllerByType:ModifyTypeBirthday atIndexPath:indexPath];
					break;
				case 3:// 修改性别
					[self openModifyTypeViewControllerByType:ModifyTypeGender atIndexPath:indexPath];
					break;
			}
		} else if (indexPath.section == 2) {
			switch (row) {
				case 0:// 修改职位
					[self openModifyTypeViewControllerByType:ModifyTypeOccupation atIndexPath:indexPath];
					break;
				case 1:// 修改爱好
					[self openModifyTypeViewControllerByType:ModifyTypeHobbies atIndexPath:indexPath];
					break;
			}
		}
	}
}

- (void) modifyUserRegionController {
    RegionViewController *controller = [[RegionViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    controller.regionSelected = ^(NSString *region){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [myModifiedProfile setObject:region forKey:REGISTER_USER_CITY_ID];
        [strongSelf.tableView reloadData];
        [strongSelf updateUserProfile];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
