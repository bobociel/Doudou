//
//  PostViewController.m
//  nihao
//
//  Created by HelloWorld on 6/12/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "PostViewController.h"
#import "PlaceholderTextView.h"
#import "BaseFunction.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import "UIImage+FixOrientation.h"
#import <CTAssetsPickerController.h>
#import "MWPhotoBrowser.h"
#import "PicCell.h"
#import "ShareWithViewController.h"
#import <math.h>
#import <AFNetworking/AFURLConnectionOperation.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import "HttpManager.h"
#import "AppConfigure.h"
#import <JDStatusBarNotification.h>
#import "DTCoreText.h"
#import "UserPost.h"
#import <MJExtension.h>
#import <CoreLocation/CoreLocation.h>

#define AUTH_CAMERA_ERR @"Please go to Settings - Privacy - Camera to allow Nihao to acess your Camera"
#define AUTH_LOCATE_ERR @"Recommend you to open location services(Settings > Privacy > Location services > Open NiHao location services)"

#define MAX_PIC_COUNT 9
#define COLLECTION_CELL_VERTICAL_MARGIN 3
#define MAX_TEXT_NUM 300

//uiactionsheet tag
#define TAG_ADD_PHOTO_SHEET 0
#define TAG_DELETE_PHOTO_SHEET 1

//uialertview tag
#define TAG_AUTH_CAMERA_ALERT 0
#define TAG_AUTH_LOCATE_ALERT 1

@interface PostViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UITextViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CTAssetsPickerControllerDelegate,MWPhotoBrowserDelegate,UIAlertViewDelegate,CLLocationManagerDelegate>{
    NSMutableArray *_imgs;
    NSInteger _collectionCellWidth;
    NSInteger _orginTopViewHeight;
    MWPhotoBrowser *_photoBrowser;
    //发布动态类型，
    NSUInteger _userVisibilityType;
    //发布按钮
    UIButton *_postButton;
    
    CLLocationManager *_locationManager;
    BOOL _isLocating;
    CLGeocoder *_geocoder;
    NSString *_locateCity;
    
    CGFloat _cancelLocationButtonWidth;
}

//滚动容器
@property (weak, nonatomic) IBOutlet UIScrollView *scrollContainer;
//内容view
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *topEditView;
@property (weak, nonatomic) IBOutlet DTAttributedLabel *wordsCountLabel;
@property (weak, nonatomic) IBOutlet PlaceholderTextView *postTextView;
- (IBAction)atFriends:(id)sender;
- (IBAction)choosePic:(id)sender;

@property (weak, nonatomic) IBOutlet UIControl *locationControl;
@property (weak, nonatomic) IBOutlet UICollectionView *picCollection;
@property (weak, nonatomic) IBOutlet UILabel *visibilityLabel;
@property (weak, nonatomic) IBOutlet UIControl *visibilityControl;
@property (weak, nonatomic) IBOutlet UILabel *locateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *locateIcon;
@property (weak, nonatomic) IBOutlet UIView *cancelLocation;
- (IBAction)cancelLocation:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locateLabelRightConstraint;

@end

@implementation PostViewController

static NSString *cellIdentifier = @"picCollectionCellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self dontShowBackButtonTitle];
    [self addNavPostButton];
    [self initViews];
    [self initCollectionView];
    [self initLocation];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
}

- (void) addNavPostButton {
    _postButton = [self createNavBtnByTitle:@"Post" icon:nil action:@selector(postBtnClick)];
    [_postButton setTitleColor:ColorWithRGB(165, 220, 255) forState:UIControlStateNormal];
    _postButton.userInteractionEnabled = NO;
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithCustomView:_postButton];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    fixedSpace.width = -15; // To balance action button
    self.navigationItem.rightBarButtonItems = @[fixedSpace,menuItem];
}

/**
 *  只有当有图片或者有文字输入时，post按钮才可以点击
 *
 *  @return post按钮是否可点击
 */
- (BOOL) postButtonClickable {
    NSString *postContent = _postTextView.text;
    if((IsStringEmpty(postContent) && _imgs.count == 0) || [postContent length] > MAX_TEXT_NUM) {
        [_postButton setTitleColor:ColorWithRGB(165, 220, 255) forState:UIControlStateNormal];
        _postButton.userInteractionEnabled = NO;
        return NO;
    } else {
        [_postButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _postButton.userInteractionEnabled = YES;
        return YES;
    }
}

/**
 *  初始化控件显示
 */
- (void) initViews {
    _scrollContainer.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    _contentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [_scrollContainer addSubview:_contentView];
    _scrollContainer.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    
    UIView *lineSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
    lineSeperator.backgroundColor = SeparatorColor;

    _postTextView.placeholder = @"What's up?";
    _postTextView.delegate = self;
    _postTextView.returnKeyType = UIReturnKeyDone;
    
    NSString *html = [NSString stringWithFormat:@"<p><font face=\"HelveticaNeue-Light\" color=\"Rgb(158,158,158)\">(300/300)</font></p>"];
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithHTMLData:data documentAttributes:NULL];
    _wordsCountLabel.attributedString = attrString;
    
    _cancelLocationButtonWidth = CGRectGetWidth(_cancelLocation.frame);
    _locateLabelRightConstraint.constant = _locateLabelRightConstraint.constant - _cancelLocationButtonWidth;
    
    [BaseFunction setCornerRadius:17.0 view:_locationControl];
    [BaseFunction setCornerRadius:17.0 view:_visibilityControl];
    [BaseFunction setBorderWidth:0.5 color:SeparatorColor view:_locationControl];
    [BaseFunction setBorderWidth:0.5 color:SeparatorColor view:_visibilityControl];
    
    [_visibilityControl addTarget:self action:@selector(changePostVisibility) forControlEvents:UIControlEventTouchUpInside];
    [_locationControl addTarget:self action:@selector(locate) forControlEvents:UIControlEventTouchUpInside];
    
    //全部人可见
    _userVisibilityType = 0;
}

- (void) initCollectionView {
    _imgs = [NSMutableArray array];
    _orginTopViewHeight = _topViewHeightConstraint.constant;
    _collectionCellWidth = (SCREEN_WIDTH - 8 * 2 ) / 3 - 5;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(_collectionCellWidth, _collectionCellWidth);
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    layout.minimumLineSpacing = COLLECTION_CELL_VERTICAL_MARGIN;
    layout.minimumInteritemSpacing = COLLECTION_CELL_VERTICAL_MARGIN;
    [_picCollection setCollectionViewLayout:layout];
    [_picCollection registerNib:[UINib nibWithNibName:@"PicCell" bundle:nil] forCellWithReuseIdentifier:cellIdentifier];
    _picCollection.backgroundColor = [UIColor whiteColor];
    _picCollection.showsHorizontalScrollIndicator = NO;
    _picCollection.showsVerticalScrollIndicator = NO;
    _picCollection.delegate = self;
    _picCollection.dataSource = self;
}

#pragma mark - uitextview delegate
- (void)textViewDidChange:(UITextView *)textView {
    NSString *text = textView.text;
    if([text length] < MAX_TEXT_NUM) {
        NSString *html = [NSString stringWithFormat:@"<p><font face=\"HelveticaNeue-Light\" color=\"Rgb(158,158,158)\">(%ld/300)</font></p>", MAX_TEXT_NUM - [text length]];
        NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithHTMLData:data documentAttributes:NULL];
        _wordsCountLabel.attributedString = attrString;
    } else {
        NSString *html = [NSString stringWithFormat:@"<p><font face=\"HelveticaNeue-Light\" color=\"Rgb(158,158,158)\">(</font><font color=\"red\" face=\"HelveticaNeue-Light\">%ld</font><font face=\"HelveticaNeue-Light\" color=\"Rgb(158,158,158)\">/300)</font></p>", MAX_TEXT_NUM - [text length]];
        NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithHTMLData:data documentAttributes:NULL];
        _wordsCountLabel.attributedString = attrString;
    }
    [self postButtonClickable];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [_postTextView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - click events

/**
 *  改变post可见类型
 */
- (void) changePostVisibility {
    if(_userVisibilityType == 0) {
        _userVisibilityType = 1;
        _visibilityLabel.text = @"Visible to Friends";
    } else {
        _userVisibilityType = 0;
        _visibilityLabel.text = @"Public";
    }
    CGFloat labelOriginWidth = CGRectGetWidth(_visibilityLabel.frame);
    [_visibilityLabel sizeToFit];
    CGFloat labelNewWidth = CGRectGetWidth(_visibilityLabel.frame);
    int deltaWidth = labelNewWidth - labelOriginWidth;
    _visibilityControl.frame = CGRectMake(CGRectGetMinX(_visibilityControl.frame) - deltaWidth, CGRectGetMinY(_visibilityControl.frame), CGRectGetWidth(_visibilityControl.frame) + deltaWidth, CGRectGetHeight(_visibilityControl.frame));
}

/**
 *  添加发布post的地理位置
 */
- (void) locate {
    if(!IsStringEmpty(_locateCity)) {
        return;
    }
    [self requestLocation];
    [self updateLocateControlFrame:@"Locating..."];
}

- (void)postBtnClick {
    //先上传图片
    [JDStatusBarNotification showWithStatus:@"Posting..." dismissAfter:1.5 styleName:JDStatusBarStyleDark];
    if(_imgs.count > 0) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
        [manager POST:COMMON_FILE_UPLOAD parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            for(ALAsset *obj in _imgs) {
                UIImage *img = [UIImage imageWithCGImage:obj.defaultRepresentation.fullScreenImage
                                                   scale:2.0
                                             orientation:UIImageOrientationUp];
                NSData *data = UIImageJPEGRepresentation(img,0.5);
                [formData appendPartWithFileData:data name:@"jpeg" fileName:((ALAsset *)obj).defaultRepresentation.filename mimeType:@"image/jpeg"];
                }
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *result = responseObject[@"result"][@"items"];
            
            NSMutableArray *pictures = [NSMutableArray array];
            //拼接图片的url字符串和名字名字符串，多张图片之间用","隔开
            NSMutableString *picIDs = [[NSMutableString alloc] init];
            for(NSInteger i = 0; i < result.count;i++) {
                NSDictionary *item = result[i];
                NSString *picID = [NSString stringWithFormat:@"%ld",[item[@"picture_id"] integerValue]];
                [picIDs appendString:picID];
                if(i != result.count - 1) {
                    [picIDs appendString:@","];
                }
                
                [pictures addObject:[Picture objectWithKeyValues:result[i]]];
            }
            
            NSString *postContent = _postTextView.text;
            NSString *uid = [AppConfigure objectForKey:LOGINED_USER_ID];
            NSString *lat = @"0";
            NSString *lon = @"0";
            NSDictionary *params = @{@"cd_ci_id":uid,@"cd_info":postContent,@"picture_id_s":picIDs,
                                     @"cd_gpslat":lat,@"cd_gpslong":lon,@"cd_view_permissions":[NSString stringWithFormat:@"%ld",_userVisibilityType],@"cd_address":_locateCity};
            [HttpManager postDynamic:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if([responseObject[@"code"] integerValue] == 0) {
                    //post成功
                    [JDStatusBarNotification showWithStatus:@"Send Successfully!" dismissAfter:1.5 styleName:JDStatusBarStyleDark];
                    //返回主页更新数据
                    NSDictionary *result = responseObject[@"result"];
                    UserPost *post = [[UserPost alloc] init];
                    post.cd_id = [result[@"cd_id"] intValue];
                    post.ci_nikename = [AppConfigure objectForKey:LOGINED_USER_NICKNAME];
                    post.cd_date = result[@"cd_date"];
                    post.cd_ci_id = [result[@"cd_ci_id"] intValue];
                    post.ci_header_img = [AppConfigure objectForKey:LOGINED_USER_ICON_URL];
                    post.cd_info = result[@"cd_info"];
                    post.ci_sex = [[AppConfigure objectForKey:LOGINED_USER_SEX] intValue];
                    post.cd_sum_pii_count = 0;
                    post.cd_sum_cmi_count = 0;
                    post.cd_sum_fwi_count = 0;
                    post.pii_is_praise = 0;
                    post.cd_address = _locateCity;
                    post.pictures = pictures;
                    if(self.post) {
                        self.post(post);
                    }
                }
            } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                //post失败
                [JDStatusBarNotification showWithStatus:@"Send fail!" dismissAfter:1.5 styleName:JDStatusBarStyleDark];
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //图片上传失败
            [JDStatusBarNotification showWithStatus:@"Send fail!" dismissAfter:1.5 styleName:JDStatusBarStyleDark];
        }];
    } else {
        //只上传文字
		NSString *postContent = _postTextView.text;// [BaseFunction encodeToPercentEscapeString:_postTextView.text];
        NSString *uid = [AppConfigure objectForKey:LOGINED_USER_ID];
        NSString *lat = @"0";
        NSString *lon = @"0";
        NSDictionary *params = @{@"cd_ci_id":uid,@"cd_info":postContent,@"picture_real_name_s":@"",@"picture_network_url_s":@"",
                                 @"cd_gpslat":lat,@"cd_gpslong":lon,@"cd_view_permissions":[NSString stringWithFormat:@"%ld",(unsigned long)_userVisibilityType],@"cd_address":_locateCity};
        [HttpManager postDynamic:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if([responseObject[@"code"] integerValue] == 0) {
                //文字post成功
                [JDStatusBarNotification showWithStatus:@"Send Successfully!" dismissAfter:1.5 styleName:JDStatusBarStyleDark];
                //返回主页更新数据
                NSDictionary *result = responseObject[@"result"];
                UserPost *post = [[UserPost alloc] init];
                post.cd_id = [result[@"cd_id"] intValue];
                post.ci_nikename = [AppConfigure objectForKey:LOGINED_USER_NICKNAME];
                post.cd_date = result[@"cd_date"];
                post.cd_ci_id = [result[@"cd_ci_id"] intValue];
                post.ci_header_img = [AppConfigure objectForKey:LOGINED_USER_ICON_URL];
                post.cd_info = result[@"cd_info"];
                post.ci_sex = [[AppConfigure objectForKey:LOGINED_USER_SEX] intValue];
                post.cd_sum_pii_count = 0;
                post.cd_sum_cmi_count = 0;
                post.cd_sum_fwi_count = 0;
                post.pii_is_praise = 0;
                post.cd_address = _locateCity;
                post.pictures = nil;
                if(self.post) {
                    self.post(post);
                }
            }
        } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            //文字post失败
            [JDStatusBarNotification showWithStatus:@"Send fail!" dismissAfter:1.5 styleName:JDStatusBarStyleDark];
        }];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)atFriends:(id)sender {
}

- (IBAction)choosePic:(id)sender {
    if(_imgs.count == 9) {
        [self showHUDErrorWithText:@"Maximum of 9 photos"];
    } else {
        [self takePhoto];
    }
}


- (IBAction)cancelLocation:(id)sender {
    _cancelLocation.hidden = YES;
    [self updateLocateControlFrame:@"Add Location"];
    _locateLabelRightConstraint.constant = _locateLabelRightConstraint.constant - _cancelLocationButtonWidth;
    _locateLabel.textColor = ColorWithRGB(87, 87, 87);
    _locateIcon.image = ImageNamed(@"icon_locate");
    _isLocating = NO;
    _locateCity = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - uicollectionview datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(_imgs.count == 0) {
        return 0;
    } else {
        NSInteger count = _imgs.count < 9 ? _imgs.count + 1 : 9;
        return count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if(indexPath.row == _imgs.count) {
        cell.image.image = [UIImage imageNamed:@"icon_add_pic"];
    } else {
        ALAsset *img = _imgs[indexPath.row];
        cell.image.image = [UIImage imageWithCGImage:img.defaultRepresentation.fullScreenImage
                                        scale:1.0
                                  orientation:UIImageOrientationUp];
    }
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

#pragma mark - uicollectionview delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if(indexPath.row == _imgs.count) {
        //点击加号的逻辑
        [self takePhoto];
    } else {
        //浏览图片gallery
        [self showPhotoBrowerAtIndex:indexPath.row];
    }
}

#pragma mark - 拍照
/**
 *  检查相机的使用权限
 *
 *  @return yes表示app有拍照权限，no表示没有
 */
- (BOOL) checkCameraAuthStatus {
    //判断相机权限
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType :AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusDenied) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can not access to your Camera" message:AUTH_CAMERA_ERR delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Activate", nil];
            alert.tag = TAG_AUTH_CAMERA_ALERT;
            [alert show];
            return NO;
        } else {
            return YES;
        }
    }
    return YES;
}

#pragma mark - uialert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == TAG_AUTH_LOCATE_ALERT) {
        if(buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Camera"]];
        }
    } else {
        if(buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
        }
    }
}

#pragma mark - uiactionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag == TAG_DELETE_PHOTO_SHEET && buttonIndex == 0) {
        //delete photo
        NSInteger showIndex = _photoBrowser.currentIndex;
        [_imgs removeObjectAtIndex:showIndex];
        if(_imgs.count == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [_photoBrowser reloadData];
        }
        [_picCollection reloadData];
        [self postButtonClickable];
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

- (void) takePhoto {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo",@"Choose from Photos", nil];
    sheet.tag = TAG_ADD_PHOTO_SHEET;
    sheet.actionSheetStyle = UIBarStyleBlackOpaque;
    [sheet showInView:self.view];
}

- (void) chooseFromPhotos {
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.childNavigationController.navigationBar.barTintColor = AppBlueColor;
    picker.childNavigationController.navigationBar.tintColor = [UIColor whiteColor];
    [picker.childNavigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    picker.delegate = self;
    //只显示图片
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - 拍照delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    //获取拍照图片
    UIImage *image = [info valueForKey:@"UIImagePickerControllerOriginalImage"];
    //调整图片的方向,防止图片上传至服务器后方向不正确
    UIImage *fixedImage = [image fixOrientation];
    //将图片显示在uicollectionview上
    image = nil;
    //保存图片
    ALAssetsLibrary *library = [PostViewController defaultAssetsLibrary];
    [library writeImageToSavedPhotosAlbum:[fixedImage CGImage] orientation:(ALAssetOrientation)[fixedImage imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
        if (error) {
            NSLog(@"error");
        } else {
            ALAssetsLibrary *lib = [PostViewController defaultAssetsLibrary];
            [lib assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                //在这里使用asset来获取图片
                [_imgs addObject:asset];
                [self postButtonClickable];
                //计算uicollectionview的高度
                [self calculateCollectionViewHeight];
            }
            failureBlock:^(NSError *error) {
            }
            ];
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
- (NSString *) saveImage : (UIImage *) image {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *imageName = [NSString stringWithFormat:@"%0.0f",[[NSDate date] timeIntervalSince1970]];
    NSString *imagePath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]];
    [UIImageJPEGRepresentation(image, 0.2) writeToFile:imagePath options:NSAtomicWrite error:nil];
    return imagePath;
}

#pragma mark - CTAssetsPickerControllerDelegate
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [_imgs addObjectsFromArray:assets];
    [self postButtonClickable];
    [self calculateCollectionViewHeight];
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset
{
    // Allow 9 assets to be picked
    return (picker.selectedAssets.count < (MAX_PIC_COUNT - _imgs.count));
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldShowAssetsGroup:(ALAssetsGroup *)group
{
    // Do not show empty albums
    return group.numberOfAssets > 0;
}

#pragma mark - 计算uicollectionview的高度
- (void) calculateCollectionViewHeight {
    //计算uicollectionview的高度
    NSInteger collectionViewRows = (NSInteger)(_imgs.count / 3) + (_imgs.count == MAX_PIC_COUNT ? 0 : 1);
    if(_imgs.count == 0) {
        collectionViewRows = 0;
    }
    NSInteger picCollectionHeight = collectionViewRows * (_collectionCellWidth + 5);
    _topViewHeightConstraint.constant = _orginTopViewHeight + picCollectionHeight ;
    _picCollection.frame = CGRectMake(CGRectGetMinX(_picCollection.frame), CGRectGetMinY(_picCollection.frame), CGRectGetWidth(_picCollection.frame), picCollectionHeight);
    [_picCollection reloadData];
    //如果最下面的控件已超出屏幕，这时需重新计算uiscrollview的contentSize
    CGFloat viewHeight = _topViewHeightConstraint.constant + CGRectGetHeight(_locationControl.frame) + 15;
    if(viewHeight >= (SCREEN_HEIGHT - 64)) {
        _scrollContainer.contentSize = CGSizeMake(SCREEN_WIDTH, CGRectGetHeight(_scrollContainer.frame) + (viewHeight - CGRectGetHeight(_scrollContainer.frame)) + 15);
    }
}

#pragma mark - 浏览图片gallery
- (void) showPhotoBrowerAtIndex : (NSInteger) index {
    _photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    //设置浏览图片的navigationbar为蓝色
    _photoBrowser.navigationController.navigationBar.barTintColor = AppBlueColor;
    _photoBrowser.displayActionButton = NO;
    _photoBrowser.enableGrid = NO;
    [_photoBrowser setCurrentPhotoIndex:index];
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

#pragma mark - mwphotobrowser delegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _imgs.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _imgs.count) {
        ALAsset *img = _imgs[index];
        MWPhoto *photo = [[MWPhoto alloc] initWithImage:[UIImage imageWithCGImage:img.defaultRepresentation.fullScreenImage
                                                                      scale:1.0
                                                                 orientation:UIImageOrientationUp]];
        return photo;
    }
    
    return nil;
}

/**
 *  删除图片
 */
- (void) delPhoto {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Delete this photo?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete", nil];
    sheet.tag = TAG_DELETE_PHOTO_SHEET;
    [sheet showInView:_photoBrowser.view];
}

+ (ALAssetsLibrary *) defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

#pragma mark - request location
- (void) initLocation {
    _locateCity = @"";
    _isLocating = NO;
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    
    _locationManager.delegate = self;
    // 用来控制定位精度，精度越高耗电量越大，当前设置定位精度为最好的精度
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _geocoder = [[CLGeocoder alloc] init];
}

- (void)requestLocation {
    if(_isLocating) {
        return;
    }
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [_locationManager requestAlwaysAuthorization]; // 永久授权
        [_locationManager startUpdatingLocation];
        _isLocating = YES;
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location service is not available" message:AUTH_LOCATE_ERR delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Activate", nil];
        alert.tag = TAG_AUTH_LOCATE_ALERT;
        [alert show];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [manager stopUpdatingLocation];
    CLLocation *location = [locations lastObject];
    NSLog(@"latitude = %lf, longitude = %lf", location.coordinate.latitude, location.coordinate.longitude);
    [self getCityInfoByLocation:location];
}

/*
 * @param coordinate 经纬度
 *
 */
- (void) getCityInfoByLocation : (CLLocation *) location {
    //反向地理编码
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error && [placemarks count] > 0) {
            NSDictionary *dict = [[placemarks objectAtIndex:0] addressDictionary];
            _locateCity = dict[@"City"];
            [self updateLocateControlFrame:_locateCity];
            _locateLabel.textColor = ColorWithRGB(47, 88, 112);
            _locateIcon.image = ImageNamed(@"icon_post_locate");
            _isLocating = NO;
            
            _cancelLocation.hidden = NO;
            _locateLabelRightConstraint.constant = _locateLabelRightConstraint.constant + _cancelLocationButtonWidth;
        } else {
            [self updateLocateControlFrame:@"Locate fail"];
            _locateLabel.textColor = ColorWithRGB(87, 87, 87);
            _locateIcon.image = ImageNamed(@"icon_locate");
            _isLocating = NO;
            _locateCity = @"";
        }}];
}

- (void) updateLocateControlFrame : (NSString *) locateString {
    _locateLabel.text = locateString;
    [_locateLabel sizeToFit];
}
@end
