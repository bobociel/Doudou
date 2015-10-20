//
//  PPInfoViewController.m
//  nihao
//
//  Created by HelloWorld on 8/11/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "PPInfoViewController.h"
#import "RadioButton.h"
#import "PPOthersViewController.h"
#import <JVFloatLabeledTextField.h>
#import "HttpManager.h"
#import "AppConfigure.h"
#import "BaseFunction.h"

typedef NS_ENUM(NSUInteger, UserIconUploadStatus) {
	UserIconUploadStatusNone = 0,
	UserIconUploadStatusUploading,
	UserIconUploadStatusSucceed,
	UserIconUploadStatusFailed,
};

@interface PPInfoViewController () <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
//@property (nonatomic, strong) UIButton *userIconButton;
@property (nonatomic, strong) UIControl *userIconRow;
@property (nonatomic, strong) UIImageView *userIconImageView;
@property (strong, nonatomic) JVFloatLabeledTextField *nickNameTextField;
@property (strong, nonatomic) RadioButton *maleButton;
@property (strong, nonatomic) RadioButton *femaleButton;
@property (strong, nonatomic) UIButton *nextBtn;

@end

@implementation PPInfoViewController {
	UserIconUploadStatus userIconUploadStatus;
	NSString *userIconURL;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.title = @"Personal Profile";
	
	self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
	self.scrollView.backgroundColor = ColorF4F4F4;
	self.scrollView.contentSize = CGSizeMake(0, 0);
	self.scrollView.alwaysBounceVertical = YES;
	self.scrollView.showsVerticalScrollIndicator = NO;
	self.scrollView.delegate = self;
	[self.view addSubview:self.scrollView];
	
	// 初始化白色背景 View
	UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 24, SCREEN_WIDTH, 180)];
	whiteView.backgroundColor = [UIColor whiteColor];
	[self.scrollView addSubview:whiteView];
	
	self.userIconRow = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
	self.userIconRow.backgroundColor = [UIColor whiteColor];
	[self.userIconRow addTarget:self action:@selector(selectIcon) forControlEvents:UIControlEventTouchUpInside];
	[whiteView addSubview:self.userIconRow];
	
//	self.userIconButton = [[UIButton alloc] initWithFrame:CGRectMake(24, 10, 60, 60)];
//	[self.userIconButton addTarget:self action:@selector(selectIcon) forControlEvents:UIControlEventTouchUpInside];
//	[whiteView addSubview:self.userIconButton];
	
	self.userIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(24, 10, 60, 60)];
	self.userIconImageView.image = [UIImage imageNamed:@"img_register_upload_photo"];
	self.userIconImageView.contentMode = UIViewContentModeScaleAspectFill;
	self.userIconImageView.clipsToBounds = YES;
	[self.userIconRow addSubview:self.userIconImageView];
	
	UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	hintLabel.font = FontNeveLightWithSize(16);
	hintLabel.text = @"Photo";
	hintLabel.textColor = NormalTextColor;
	[hintLabel sizeToFit];
	CGRect labelFrame = hintLabel.frame;
	labelFrame.origin.x = CGRectGetMaxX(self.userIconImageView.frame) + 15;
	labelFrame.origin.y = CGRectGetMidY(self.userIconImageView.frame) - CGRectGetHeight(hintLabel.frame) / 2;
	hintLabel.frame = labelFrame;
	[self.userIconRow addSubview:hintLabel];
	
	UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 15 - 8, (80 - 13) / 2, 8, 13)];
	arrow.image = [UIImage imageNamed:@"right_arrow_grey"];
	[self.userIconRow addSubview:arrow];
	
	UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, 80, SCREEN_WIDTH - 30, 0.5)];
	line.backgroundColor = SeparatorColor;
	[whiteView addSubview:line];
	
	// 初始化用户昵称输入框
	self.nickNameTextField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectMake(24, 82, SCREEN_WIDTH - 48, 46)];
	self.nickNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Nickname" attributes:@{NSForegroundColorAttributeName:HintTextColor}];
	self.nickNameTextField.floatingLabelFont = FontNeveLightWithSize(kJVFieldFloatingLabelFontSize);
	self.nickNameTextField.floatingLabelTextColor = AppBlueColor;
	self.nickNameTextField.font = FontNeveLightWithSize(16);
	self.nickNameTextField.clearButtonMode = UITextFieldViewModeAlways;
	[self.nickNameTextField setValue:@16 forKey:@"limit"];
	self.nickNameTextField.borderStyle = UITextBorderStyleNone;
	self.nickNameTextField.keyboardType = UIKeyboardTypeASCIICapable;
	[whiteView addSubview:self.nickNameTextField];
//	self.nickNameTextField.text = [AppConfigure valueForKey:REGISTER_USER_NICKNAME];
	
	UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(15, 130, SCREEN_WIDTH - 30, 0.5)];
	line1.backgroundColor = SeparatorColor;
	[whiteView addSubview:line1];
	
	NSInteger sexButtonWidth = (SCREEN_WIDTH - 30 - 15) / 2;
	self.maleButton = [[RadioButton alloc] initWithFrame:CGRectMake(15, 135, sexButtonWidth, 40)];
	self.maleButton.titleLabel.font = FontNeveLightWithSize(16);
	[self.maleButton setTitle:@"Male" forState:UIControlStateNormal];
	[self.maleButton setTitle:@"Male" forState:UIControlStateSelected];
	[self.maleButton setTitleColor:NormalTextColor forState:UIControlStateNormal];
	[self.maleButton setTitleColor:[UIColor colorWithRed:53 / 255.0 green:162 / 255.0 blue:255 / 255.0 alpha:1] forState:UIControlStateSelected];
	[self.maleButton setImage:[UIImage imageNamed:@"icon_male_normal"] forState:UIControlStateNormal];
	[self.maleButton setImage:[UIImage imageNamed:@"icon_male_selected"] forState:UIControlStateSelected];
	self.maleButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 13);
	[whiteView addSubview:self.maleButton];
	
	self.femaleButton = [[RadioButton alloc] initWithFrame:CGRectMake(15 + sexButtonWidth + 15, 135, sexButtonWidth, 40)];
	self.femaleButton.titleLabel.font = FontNeveLightWithSize(16);
	[self.femaleButton setTitle:@"Female" forState:UIControlStateNormal];
	[self.femaleButton setTitle:@"Female" forState:UIControlStateSelected];
	[self.femaleButton setTitleColor:NormalTextColor forState:UIControlStateNormal];
	[self.femaleButton setTitleColor:[UIColor colorWithRed:255 / 255.0 green:113 / 255.0 blue:136 / 255.0 alpha:1] forState:UIControlStateSelected];
	[self.femaleButton setImage:[UIImage imageNamed:@"icon_female_normal"] forState:UIControlStateNormal];
	[self.femaleButton setImage:[UIImage imageNamed:@"icon_female_selected"] forState:UIControlStateSelected];
	self.femaleButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 13);
	[whiteView addSubview:self.femaleButton];
	
	self.maleButton.groupButtons = @[self.maleButton, self.femaleButton];
	
	// 默认选中性别女
	self.femaleButton.selected = YES;
	
	// 初始化 Next 按钮
	self.nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(whiteView.frame) + 40, SCREEN_WIDTH - 40, 40)];
	self.nextBtn.backgroundColor = AppBlueColor;
	[self.nextBtn setTitle:@"Next" forState:UIControlStateNormal];
	[self.nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	self.nextBtn.titleLabel.font = FontNeveLightWithSize(18);
	[self.nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
	[self.scrollView addSubview:self.nextBtn];
	
	userIconUploadStatus = UserIconUploadStatusNone;
}

#pragma mark - Lifecycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Touch Events

- (void)selectIcon {
	[self showPickerActionSheet];
}

- (void)nextBtnClick {
//#warning Test
//	PPOthersViewController *othersViewController = [[PPOthersViewController alloc] init];
//	[self.navigationController pushViewController:othersViewController animated:YES];
	
	NSString *nickname = self.nickNameTextField.text;
	if (nickname.length == 0) {
		[self showHUDErrorWithText:@"Please enter your nickname"];
		return;
	}
	
	if (![BaseFunction validateNickname:nickname]) {
		[self showHUDErrorWithText:@"Error, nickname should contain only letters, numbers, - or _"];
		NSLog(@"Invalidate nickname");
		return;
	}
	
	// 验证用户昵称唯一性
	[self showWithLabelText:@"" executing:@selector(verifyUserNameUnique)];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self.view endEditing:YES];
}

#pragma mark - Private

// 显示照片选择菜单
- (void)showPickerActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose from Photos", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}

- (void)takePhotoFromCamera:(BOOL)isFromCamera {
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // 相机
        NSUInteger sourceType = isFromCamera ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        // 设置照片是否可编辑
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = sourceType;

        // 此处的delegate是上层的ViewController，如果你直接在ViewController使用，直接self就可以了
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }
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
        self.userIconImageView.image = editedImage;
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
	userIconUploadStatus = UserIconUploadStatusUploading;
	
	NSString *iconName = [NSString stringWithFormat:@"ios_userid_%@_%@.jpg", [AppConfigure objectForKey:REGISTER_USER_ID], [BaseFunction stringFromCurrent]];
	[HttpManager userIconUploadWithImageData:data parameters:nil iconName:iconName success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
		NSLog(@"用户头像上传返回结果：%@", resultDict);
		if (rtnCode == 0) {
			// 保存用户头像在服务器上的地址
			NSArray *fileArray = resultDict[@"result"][@"items"];
			if (fileArray.count > 0) {
				userIconURL = fileArray[0][@"picture_original_network_url"];
				[AppConfigure setObject:userIconURL ForKey:REGISTER_USER_ICON_URL];
				userIconUploadStatus = UserIconUploadStatusSucceed;
			} else {
				userIconUploadStatus = UserIconUploadStatusFailed;
				[self showHUDErrorWithText:@"Photo upload failed"];
			}
		} else {
			userIconUploadStatus = UserIconUploadStatusFailed;
			[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
		userIconUploadStatus = UserIconUploadStatusFailed;
		[self showHUDNetError];
	}];
}

#pragma mark 验证昵称唯一性
- (void)verifyUserNameUnique {
	NSString *nickname = self.nickNameTextField.text;
	NSString *userID = [AppConfigure valueForKey:REGISTER_USER_ID];
	[HttpManager verifyUserNameUnique:nickname userID:userID success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [[resultDict objectForKey:@"code"] integerValue];
//		{"code":"1","message":"该昵称已被使用"}
//		{"code":"0","message":"该昵称有效"}
		if (rtnCode == 0) {
			[self showWithLabelText:@"" executing:@selector(setUserInfo)];
		} else {
			if (rtnCode == 1) {
				[self showHUDErrorWithText:@"Nickname is already in use"];
			} else {
				[self processServerErrorWithCode:rtnCode andErrorMsg:[resultDict objectForKey:@"message"]];
			}
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
		[self showHUDNetError];
	}];
}

- (void)setUserInfo {
	NSString *nickname = self.nickNameTextField.text;
	NSString *userSex = self.maleButton.isSelected ? @"1" : @"0";
	
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:[AppConfigure valueForKey:REGISTER_USER_ID] forKey:REGISTER_USER_ID];
	[parameters setObject:nickname forKey:REGISTER_USER_NICKNAME];
	[parameters setObject:userSex forKey:REGISTER_USER_SEX];
	
	if (userIconUploadStatus == UserIconUploadStatusSucceed) {
		[parameters setObject:userIconURL forKey:REGISTER_USER_ICON_URL];
	}
	
	// 设置密码
	[HttpManager completeUserInfoByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSInteger rtnCode = [responseObject[@"code"] integerValue];
		if (rtnCode == 0) {
			[AppConfigure setObject:nickname ForKey:REGISTER_USER_NICKNAME];
			[AppConfigure setObject:userSex ForKey:REGISTER_USER_SEX];
			// 设置成功，进入下一个界面
			PPOthersViewController *othersViewController = [[PPOthersViewController alloc] init];
			[self.navigationController pushViewController:othersViewController animated:YES];
		} else {
			[self processServerErrorWithCode:rtnCode andErrorMsg:responseObject[@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
		[self showHUDNetError];
	}];
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
