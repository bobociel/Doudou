//
//  FeedbackViewController.m
//  nihao
//
//  Created by YW on 15/7/6.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "FeedbackViewController.h"
#import <CTAssetsPickerController.h>
#import "MWPhotoBrowser.h"
#import "PlaceholderTextView.h"
#import "DTAttributedLabel.h"
#import "DTCoreText.h"
#import <JDStatusBarNotification.h>
#import <AFNetworking/AFURLConnectionOperation.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import "HttpManager.h"
#import "AppConfigure.h"
#import "PicCell.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import "UIImage+FixOrientation.h"
#import <math.h>
#import "ShareWithViewController.h"
#import "BaseFunction.h"

#define MAX_TEXT_NUM 140
#define AUTH_CAMERA_ERR @"Please go to Settings - Privacy - Camera to allow Nihao to acess your Camera"
#define MAX_PIC_COUNT 5
#define COLLECTION_CELL_VERTICAL_MARGIN 3

//uiactionsheet的tag
#define TAG_ADD_PHOTO_SHEET 0
#define TAG_DELETE_PHOTO_SHEET 1

@interface FeedbackViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UITextViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CTAssetsPickerControllerDelegate,MWPhotoBrowserDelegate,UIAlertViewDelegate>{
    NSMutableArray *_imgs;
    NSInteger _collectionCellWidth;
    NSInteger _orginTopViewHeight;
    MWPhotoBrowser *_photoBrowser;
    //发布动态类型，
    NSInteger _userVisibilityType;
    //发布按钮
    UIButton *_submitButton;
}
@property (weak, nonatomic) IBOutlet PlaceholderTextView *feedbackTextView;
@property (weak, nonatomic) IBOutlet DTAttributedLabel *wordsCountLable;
@property (weak, nonatomic) IBOutlet UICollectionView *picCollection;
@property (weak, nonatomic) IBOutlet UIView *toopEditView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollContainer;
- (IBAction)choosePic:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toopViewHeightConstraint;
@property (strong, nonatomic) IBOutlet UIView *contentView;


@end

@implementation FeedbackViewController

static NSString *cellIdentifier = @"picCollectionCellIdentifier";


- (void)viewDidLoad {
    [super viewDidLoad];
    [self dontShowBackButtonTitle];
    self.title = @"Feedback";
    [self initViews];
    [self addNavSubmitButton];
    [self initCollectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) addNavSubmitButton {
    _submitButton = [self createNavBtnByTitle:@"Submit" icon:nil action:@selector(submitBtnClick)];
    [_submitButton setTitleColor:ColorWithRGB(165, 220, 255) forState:UIControlStateNormal];
    _submitButton.userInteractionEnabled = NO;
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithCustomView:_submitButton];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    fixedSpace.width = -15; // To balance action button
    self.navigationItem.rightBarButtonItems = @[fixedSpace,menuItem];
}

/**
 *  只有当有图片或者有文字输入时，submit按钮才可以点击
 *
 *  @return submit按钮是否可点击
 */
- (BOOL) submitButtonClickable {
    NSString *feedbackContent = _feedbackTextView.text;
    if((IsStringEmpty(feedbackContent) && _imgs.count == 0) || [feedbackContent length] > 140) {
        [_submitButton setTitleColor:ColorWithRGB(165, 220, 255) forState:UIControlStateNormal];
        _submitButton.userInteractionEnabled = NO;
        return NO;
    } else {
        [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _submitButton.userInteractionEnabled = YES;
        return YES;
    }
}

-(void)initViews{
    _scrollContainer.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    _contentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [_scrollContainer addSubview:_contentView];
    _scrollContainer.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    
    _feedbackTextView.placeholder = @"Please send us your Feedback.";
    _feedbackTextView.delegate = self;
    _feedbackTextView.returnKeyType = UIReturnKeyDone;
    
    NSString *html = [NSString stringWithFormat:@"<p><font face=\"HelveticaNeue-Light\" color=\"Rgb(158,158,158)\">(140/140)</font></p>"];
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithHTMLData:data documentAttributes:NULL];
    _wordsCountLable.attributedString = attrString;
}

- (void) initCollectionView {
    _imgs = [NSMutableArray array];
    _orginTopViewHeight = _toopViewHeightConstraint.constant;
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
        NSString *html = [NSString stringWithFormat:@"<p><font face=\"HelveticaNeue-Light\" color=\"Rgb(158,158,158)\">(%ld/140)</font></p>", MAX_TEXT_NUM - [text length]];
        NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithHTMLData:data documentAttributes:NULL];
        _wordsCountLable.attributedString = attrString;
    } else {
        NSString *html = [NSString stringWithFormat:@"<p><font face=\"HelveticaNeue-Light\" color=\"Rgb(158,158,158)\">(</font><font color=\"red\" face=\"HelveticaNeue-Light\">%ld</font><font face=\"HelveticaNeue-Light\" color=\"Rgb(158,158,158)\">/140)</font></p>", MAX_TEXT_NUM - [text length]];
        NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithHTMLData:data documentAttributes:NULL];
        _wordsCountLable.attributedString = attrString;
    }
    [self submitButtonClickable];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [_feedbackTextView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - click events
- (void)submitBtnClick {
    //先上传图片
    [self showHUDWithText:@"Submiting..."];
    if(_imgs.count > 0) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
        NSLog(@"%@",COMMON_FILE_UPLOAD);
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
            //拼接图片的url字符串和名字名字符串，多张图片之间用","隔开
            NSMutableString *picIDs = [[NSMutableString alloc] init];
            for(NSInteger i = 0; i < result.count;i++) {
                NSDictionary *item = result[i];
                NSString *picID = [NSString stringWithFormat:@"%ld",[item[@"picture_id"] integerValue]];
                [picIDs appendString:picID];
                if(i != result.count - 1) {
                    [picIDs appendString:@","];
                }
            }
            
            NSString *feedbackContent = _feedbackTextView.text;
            NSString *uid = [AppConfigure objectForKey:LOGINED_USER_ID];
            NSDictionary *params = @{@"ctr_ci_id":uid,@"ctr_context":feedbackContent,@"picture_id_s":picIDs};
            [HttpManager userFeedBackByParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if([responseObject[@"code"] integerValue] == 0) {
                    //post成功
                    [self showHUDDoneWithText:@"Feedback Successfully!"];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                //post失败
                [self showHUDNetError];
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //图片上传失败
            [self showHUDNetError];
        }];
    } else {
        //只上传文字
        NSString *feedbackContent = _feedbackTextView.text;
        NSString *uid = [AppConfigure objectForKey:LOGINED_USER_ID];
        NSDictionary *params = @{@"ctr_ci_id":uid,@"ctr_context":feedbackContent};
        [HttpManager userFeedBackByParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if([responseObject[@"code"] integerValue] == 0) {
                //文字post成功
                [self showHUDDoneWithText:@"Feedback Successfully!"];
                [self.navigationController popViewControllerAnimated:YES];
            }
        } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            //文字post失败
            [self showHUDNetError];
        }];
    }
}

#pragma mark - uicollectionview datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(_imgs.count == 0) {
        return 0;
    } else {
        NSInteger count = _imgs.count < 5 ? _imgs.count + 1 : 5;
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
    if(buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Camera"]];
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
        [self submitButtonClickable];
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
    ALAssetsLibrary *library = [FeedbackViewController defaultAssetsLibrary];
    [library writeImageToSavedPhotosAlbum:[fixedImage CGImage] orientation:(ALAssetOrientation)[fixedImage imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
        if (error) {
            NSLog(@"error");
        } else {
            ALAssetsLibrary *lib = [FeedbackViewController defaultAssetsLibrary];
            [lib assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                //在这里使用asset来获取图片
                [_imgs addObject:asset];
                [self submitButtonClickable];
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


#pragma mark - CTAssetsPickerControllerDelegate
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [_imgs addObjectsFromArray:assets];
    [self submitButtonClickable];
    [self calculateCollectionViewHeight];
}


- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset
{
    // Allow 5 assets to be picked
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
    NSInteger collectionViewRows = (NSInteger)(_imgs.count / 3) + 1;
    if(_imgs.count == 0) {
        collectionViewRows = 0;
    }
    NSInteger picCollectionHeight = collectionViewRows * (_collectionCellWidth + 5);
    _toopViewHeightConstraint.constant = _orginTopViewHeight + picCollectionHeight ;
    _picCollection.frame = CGRectMake(CGRectGetMinX(_picCollection.frame), CGRectGetMinY(_picCollection.frame), CGRectGetWidth(_picCollection.frame), picCollectionHeight);
    [_picCollection reloadData];
    //如果最下面的控件已超出屏幕，这时需重新计算uiscrollview的contentSize
    CGFloat viewHeight = _toopViewHeightConstraint.constant + 15;
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


-(IBAction)choosePic:(id)sender{
    if(_imgs.count == 5) {
        [self showHUDErrorWithText:@"Select a maximum of 5 photos"];
    } else {
        [self takePhoto];
    }
}


@end
