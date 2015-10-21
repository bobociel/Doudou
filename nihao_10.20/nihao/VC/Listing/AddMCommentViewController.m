//
//  AddMCommentViewController.m
//  nihao
//
//  Created by HelloWorld on 8/17/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "AddMCommentViewController.h"
#import "TPFloatRatingView.h"
#import "PlaceholderTextView.h"
#import <CTAssetsPickerController.h>
#import "MWPhotoBrowser.h"
#import "HttpManager.h"
#import "AppConfigure.h"
#import "BaseFunction.h"
#import "LimitInput.h"
#import "PicCell.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+FixOrientation.h"
#import "Picture.h"
#import <MJExtension/MJExtension.h>

// UIActionSheet 的 TAG
#define TAG_ADD_PHOTO_SHEET 0
#define TAG_DELETE_PHOTO_SHEET 1

#define MAX_PIC_COUNT 9

#define AUTH_CAMERA_ERR @"Please go to Settings - Privacy - Camera to allow Nihao to acess your Camera"

@interface AddMCommentViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CTAssetsPickerControllerDelegate, MWPhotoBrowserDelegate, UIAlertViewDelegate,UIScrollViewDelegate> {
	MWPhotoBrowser *_photoBrowser;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet TPFloatRatingView *rateView;
@property (weak, nonatomic) IBOutlet PlaceholderTextView *commentTextView;
@property (weak, nonatomic) IBOutlet UILabel *wordsCountLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;
@property (weak, nonatomic) IBOutlet UITextField *conPerPersonTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *editView;

@end

static NSString *CellIdentifier = @"picCollectionCellIdentifier";

@implementation AddMCommentViewController {
	NSMutableArray *photos;
	NSInteger orginEditViewHeight;
	NSInteger photoCellSize;
	NSString *photosID;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//	self.title = self.merchantName;
	
	photos = [[NSMutableArray alloc] init];
	
	[self setUpViews];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.hidesBottomBarWhenPushed = YES;
}

#pragma mark = Lifecycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)setUpViews {
	self.mainView.frame = CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(self.mainView.frame));
	self.scrollView.contentSize = self.mainView.frame.size;
	[self.scrollView addSubview:self.mainView];
	
	if (!self.rateView.emptySelectedImage) {
		self.rateView.emptySelectedImage = [UIImage imageNamed:@"star_normal"];
	}
	if (!self.rateView.fullSelectedImage) {
		self.rateView.fullSelectedImage = [UIImage imageNamed:@"star_highlight"];
	}
	self.rateView.contentMode = UIViewContentModeScaleAspectFill;
	self.rateView.minRating = 1;
	self.rateView.minImageSize = CGSizeMake(25, 25);
	self.rateView.rating = 1;
	self.rateView.editable = YES;
	self.rateView.halfRatings = YES;
	
	self.commentTextView.placeholderFont = FontNeveLightWithSize(14);
	self.commentTextView.placeholderColor = HintTextColor;
	self.commentTextView.placeholder = @"How is the food taste, the environment, service satisfaction?";
	self.commentTextView.delegate = self;
	[self.commentTextView setValue:@300 forKey:@"limit"];
	
	[self setButtonState:ButtonStateDisable];
	
	orginEditViewHeight = self.editViewHeightConstraint.constant;
	photoCellSize = (SCREEN_WIDTH - 8 * 2) / 3 - 6;
	UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
	layout.itemSize = CGSizeMake(photoCellSize, photoCellSize);
	layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
	layout.minimumLineSpacing = 3;
	layout.minimumInteritemSpacing = 3;
	[self.photosCollectionView setCollectionViewLayout:layout];
	[self.photosCollectionView registerNib:[UINib nibWithNibName:@"PicCell" bundle:nil] forCellWithReuseIdentifier:CellIdentifier];
	self.photosCollectionView.backgroundColor = [UIColor whiteColor];
	self.photosCollectionView.showsHorizontalScrollIndicator = NO;
	self.photosCollectionView.showsVerticalScrollIndicator = NO;
	self.photosCollectionView.bounces = NO;
	self.photosCollectionView.delegate = self;
	self.photosCollectionView.dataSource = self;
	
	[self calculateCollectionViewHeight];
}

- (void)setButtonState:(ButtonState)state {
	if(state == ButtonStateClickable) {
		self.submitButton.backgroundColor = BUTTON_ENABLED_COLOR;
		self.submitButton.userInteractionEnabled = YES;
	} else {
		self.submitButton.backgroundColor = BUTTON_DISABLED_COLOR;
		self.submitButton.userInteractionEnabled = NO;
	}
}

#pragma mark 计算 UICollectionView 的高度

- (void)calculateCollectionViewHeight {
	// 计算 UICollectionView 的高度
	NSInteger collectionViewRows = (NSInteger)(photos.count / 3) + (photos.count == MAX_PIC_COUNT ? 0 : 1);
	if(photos.count == 0) {
		collectionViewRows = 1;
	}
//	NSLog(@"collectionViewRows = %ld", collectionViewRows);
	NSInteger picCollectionHeight = collectionViewRows * (photoCellSize + 5) + (collectionViewRows - 1) * 3;
//	NSLog(@"picCollectionHeight = %ld", picCollectionHeight);
	
	CGRect pcvFrame = self.photosCollectionView.frame;
	pcvFrame.size.height = picCollectionHeight;
	self.photosCollectionView.frame = pcvFrame;
	[self.photosCollectionView reloadData];
	
	self.editViewHeightConstraint.constant = orginEditViewHeight + picCollectionHeight;
//	NSLog(@"self.editViewHeightConstraint.constant = %lf", self.editViewHeightConstraint.constant);
	
	NSInteger editViewMaxY = CGRectGetMinY(self.editView.frame) + orginEditViewHeight + picCollectionHeight;
//	NSLog(@"editViewMaxY = %ld", editViewMaxY);
	CGRect mainViewFrame = self.mainView.frame;
	mainViewFrame.size.height = editViewMaxY + 15 + 50 + 40 + 40 + 8;
//	NSLog(@"mainViewFrame.size.height  = %lf", mainViewFrame.size.height);
	self.mainView.frame = mainViewFrame;
    self.scrollView.delegate = self;
	self.scrollView.contentSize = self.mainView.frame.size;
//	NSLog(@"self.scrollView.contentSize = %@", NSStringFromCGSize(self.scrollView.contentSize));
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
	if (textView.text.length > 0) {
		[self setButtonState:ButtonStateClickable];
	} else {
		[self setButtonState:ButtonStateDisable];
	}
	
	self.wordsCountLabel.text = [NSString stringWithFormat:@"%ld/300", (unsigned long)textView.text.length];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	NSInteger pCount = photos.count;
	return pCount < 9 ? pCount + 1 : pCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	PicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
	
	if(indexPath.row == photos.count) {
		cell.image.image = [UIImage imageNamed:@"icon_add_pic"];
	} else {
		ALAsset *img = photos[indexPath.row];
		cell.image.image = [UIImage imageWithCGImage:img.defaultRepresentation.fullScreenImage scale:1.0 orientation:UIImageOrientationUp];
	}
	
	return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	[collectionView deselectItemAtIndexPath:indexPath animated:YES];
	
	if(indexPath.row == photos.count) {
		// 点击添加照片
		[self takePhoto];
	} else {
		// 查看照片
		[self showPhotoBrowerAtIndex:indexPath.row];
	}
}

#pragma mark - Photos

- (void)takePhoto {
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose from Photos", nil];
	sheet.tag = TAG_ADD_PHOTO_SHEET;
	[sheet showInView:self.view];
}

- (void)chooseFromPhotos {
	CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
	picker.childNavigationController.navigationBar.barTintColor = AppBlueColor;
	picker.childNavigationController.navigationBar.tintColor = [UIColor whiteColor];
	[picker.childNavigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
	picker.delegate = self;
	//只显示图片
	picker.assetsFilter = [ALAssetsFilter allPhotos];
	[self presentViewController:picker animated:YES completion:nil];
}

#pragma mark 检查相机的使用权限
- (BOOL)checkCameraAuthStatus {
	// 判断相机权限
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
		AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType :AVMediaTypeVideo];
		if (authStatus == AVAuthorizationStatusDenied) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can not access to your Camera" message:AUTH_CAMERA_ERR delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Activate", nil];
			[alert show];
			
			return NO;
		} else {
			return YES;
		}
	}
	
	return YES;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[self dismissViewControllerAnimated:YES completion:nil];
	// 获取拍照图片
	UIImage *image = [info valueForKey:@"UIImagePickerControllerOriginalImage"];
	// 调整图片的方向,防止图片上传至服务器后方向不正确
	UIImage *fixedImage = [image fixOrientation];
	//保存图片
	ALAssetsLibrary *library = [AddMCommentViewController defaultAssetsLibrary];
	[library writeImageToSavedPhotosAlbum:[fixedImage CGImage] orientation:(ALAssetOrientation)[fixedImage imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
		if (error) {
			NSLog(@"error = %@", error);
		} else {
			ALAssetsLibrary *lib = [AddMCommentViewController defaultAssetsLibrary];
			[lib assetForURL:assetURL resultBlock:^(ALAsset *asset) {
				//在这里使用asset来获取图片
				[photos addObject:asset];
				//计算uicollectionview的高度
				[self calculateCollectionViewHeight];
			} failureBlock:^(NSError *error) {
				
			}];
		}
	}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  将uiimage对象保存成jpg文件放在本地，并返回图片的存放地址
 *
 *  @param image
 *  @return 保存的图片路径
 */
- (NSString *)saveImage:(UIImage *)image {
	NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *imageName = [NSString stringWithFormat:@"%0.0f",[[NSDate date] timeIntervalSince1970]];
	NSString *imagePath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]];
	[UIImageJPEGRepresentation(image, 0.2) writeToFile:imagePath options:NSAtomicWrite error:nil];
	return imagePath;
}

#pragma mark - CTAssetsPickerControllerDelegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
	[picker.presentingViewController dismissViewControllerAnimated:YES completion:^{
		
	}];
	
	[photos addObjectsFromArray:assets];
	[self calculateCollectionViewHeight];
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset {
	// Allow 9 assets to be picked
	return (picker.selectedAssets.count < (MAX_PIC_COUNT - photos.count));
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldShowAssetsGroup:(ALAssetsGroup *)group {
	// Do not show empty albums
	return group.numberOfAssets > 0;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(actionSheet.tag == TAG_DELETE_PHOTO_SHEET && buttonIndex == 0) {
		// delete photo
		NSInteger showIndex = _photoBrowser.currentIndex;
		[photos removeObjectAtIndex:showIndex];
		if(photos.count == 0) {
			[self.navigationController popViewControllerAnimated:YES];
		} else {
			[_photoBrowser reloadData];
		}
		
		[self.photosCollectionView reloadData];
		[self calculateCollectionViewHeight];
	} else {
		switch (buttonIndex) {
			case 0: {
				if([self checkCameraAuthStatus]) {
					// 判断是否支持相机
					if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
						NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
						// 相机
						sourceType = UIImagePickerControllerSourceTypeCamera;
						// 跳转到相机或相册页面
						UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
						imagePickerController.delegate = self;
						// 设置照片是否可编辑
						imagePickerController.allowsEditing = NO;
						imagePickerController.sourceType = sourceType;
						//此处的delegate是上层的ViewController，如果你直接在ViewController使用，直接self就可以了
						[self presentViewController:imagePickerController animated:YES completion:^{}];
					}
				}
			}
				break;
			case 1: {
				[self chooseFromPhotos];
			}
				break;
			default:
				break;
		}
	}
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 1) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Camera"]];
	}
}

#pragma mark - 浏览图片gallery
- (void)showPhotoBrowerAtIndex:(NSInteger)index {
	_photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
	//设置浏览图片的navigationbar为蓝色
	_photoBrowser.navigationController.navigationBar.barTintColor = AppBlueColor;
	_photoBrowser.displayActionButton = NO;
	_photoBrowser.enableGrid = NO;
	[_photoBrowser setCurrentPhotoIndex:index];
	[_photoBrowser setCurrentPhotoIndex:0];
	// Manipulate
	[_photoBrowser showNextPhotoAnimated:YES];
	[_photoBrowser showPreviousPhotoAnimated:YES];
	
	UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
	fixedSpace.width = -20; // To balance action button
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setImage:[UIImage imageNamed:@"icon_del_photo"] forState:UIControlStateNormal];
	[button setFrame:CGRectMake(0, 0, 60, 40)];
	[button addTarget:self action:@selector(delPhoto) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *delItem = [[UIBarButtonItem alloc] initWithCustomView:button];
	_photoBrowser.navigationItem.rightBarButtonItems = @[fixedSpace,delItem];
	// Present
	[self.navigationController pushViewController:_photoBrowser animated:YES];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
	return photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
	if (index < photos.count) {
		ALAsset *img = photos[index];
		MWPhoto *photo = [[MWPhoto alloc] initWithImage:[UIImage imageWithCGImage:img.defaultRepresentation.fullScreenImage scale:1.0 orientation:UIImageOrientationUp]];
		
		return photo;
	}
	
	return nil;
}

/**
 *  删除图片
 */
- (void)delPhoto {
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Delete this photo?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete", nil];
	sheet.tag = TAG_DELETE_PHOTO_SHEET;
	[sheet showInView:_photoBrowser.view];
}

+ (ALAssetsLibrary *)defaultAssetsLibrary {
	static dispatch_once_t pred = 0;
	static ALAssetsLibrary *library = nil;
	dispatch_once(&pred, ^{
		library = [[ALAssetsLibrary alloc] init];
	});
	
	return library;
}

#pragma mark - Touch Events

- (IBAction)submitComment:(id)sender {
	[self showWithLabelText:@"Submit..." executing:@selector(waitSubmitComment)];
}

- (void)waitSubmitComment {
	// 是否有图片
	if(photos.count > 0) {
//		NSLog(@"Have Photo count = %ld", photos.count);
		AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
		manager.responseSerializer = [AFJSONResponseSerializer serializer];
		manager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
		[manager POST:COMMON_FILE_UPLOAD parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
			for(ALAsset *obj in photos) {
				UIImage *img = [UIImage imageWithCGImage:obj.defaultRepresentation.fullScreenImage
												   scale:2.0
											 orientation:UIImageOrientationUp];
				NSData *data = UIImageJPEGRepresentation(img, kImageCompressionQualityDefault);
				[formData appendPartWithFileData:data name:@"jpeg" fileName:((ALAsset *)obj).defaultRepresentation.filename mimeType:@"image/jpeg"];
			}
		} success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSArray *result = responseObject[@"result"][@"items"];
//			NSLog(@"upload photos responseObject = %@", responseObject);
//			NSMutableArray *pictures = [NSMutableArray array];
			// 拼接图片的url字符串和名字名字符串，多张图片之间用","隔开
			NSMutableString *photoIDs = [[NSMutableString alloc] init];
			for(NSInteger i = 0; i < result.count; i++) {
				NSDictionary *item = result[i];
				NSString *picID = [NSString stringWithFormat:@"%ld", [item[@"picture_id"] integerValue]];
				[photoIDs appendString:picID];
				if(i != result.count - 1) {
					[photoIDs appendString:@","];
				}
//				[pictures addObject:[Picture objectWithKeyValues:result[i]]];
			}
			photosID = photoIDs;
			[self showWithLabelText:@"Submit..." executing:@selector(submit)];
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			// 图片上传失败
			NSLog(@"error = %@", error);
		}];
	} else {
//		NSLog(@"NO Photo");
		photosID = @"";
		[self submit];
	}
}

- (void)submit {
//	NSLog(@"photosID = %@", photosID);
	NSString *commentContent = self.commentTextView.text;
	NSString *currentUserID = [NSString stringWithFormat:@"%@", [AppConfigure objectForKey:LOGINED_USER_ID]];
	NSString *conPerPersonString = self.conPerPersonTextField.text;
	NSString *rateString = [NSString stringWithFormat:@"%ld", (NSInteger)(self.rateView.rating * 2)];
	
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	
	[parameters setObject:commentContent forKey:@"cmi_info"];
	[parameters setObject:currentUserID forKey:@"cmi_ci_id"];
	
	if (IsStringNotEmpty(photosID)) {
		[parameters setObject:photosID forKey:@"picture_id_s"];
	}
	
	[parameters setObject:rateString forKey:@"mhi_score"];
	[parameters setObject:self.merchantID forKey:@"cmi_source_id"];
	[parameters setObject:@"5" forKey:@"cmi_source_type"];
	//[parameters setObject:self.merchantID forKey:@"cmi_two_source_id"];
	//[parameters setObject:@"2" forKey:@"cmi_two_source_type"];
    [parameters setObject:self.merchantID forKey:@"cmi_final_source_id"];
    [parameters setObject:@"5" forKey:@"cmi_final_source_type"];
    
	if (conPerPersonString.length > 0) {
		[parameters setObject:conPerPersonString forKey:@"mhi_consume"];
	}
	
	NSLog(@"submit comment parameters = %@", parameters);
	
	[HttpManager commitUserCommentByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"code"] integerValue] == 0) {
			if (self.submitReviewSuccess) {
				self.submitReviewSuccess();
			}
//			NSLog(@"submit comment responseObject = %@", responseObject);
			[self.navigationController popViewControllerAnimated:YES];
		} else {
			[self processServerErrorWithCode:[responseObject[@"code"] integerValue] andErrorMsg:[responseObject objectForKey:@"message"]];
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"error = %@", error);
		[self showHUDErrorWithText:BAD_NETWORK];
	}];
}

#pragma mark - uiscrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
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
