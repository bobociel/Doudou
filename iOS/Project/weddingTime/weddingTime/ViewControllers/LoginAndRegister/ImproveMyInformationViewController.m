//
//  ImproveMyInformationViewController.m
//  weddingTime
//
//  Created by _Cuixin on 15/9/17.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "ImproveMyInformationViewController.h"
#import "FSMediaPicker.h"
#import "UserInfoManager.h"
#import "UserService.h"
#import "LWUtil.h"
#import "LWAssistUtil.h"
#import "CommPickView.h"
#import "WTProgressHUD.h"
#import "AlertViewWithBlockOrSEL.h"
#import "WTRegisterViewController.h"
#import "QiniuSDK.h"
#import "WTUploadManager.h"
#define topGap           30.f
#define lineViewLeftGap  8.f
@interface ImproveMyInformationViewController ()
<
    UITextFieldDelegate,UIActionSheetDelegate,
    CommPickViewDelegate,FSMediaPickerDelegate,
    LoginManagerDelegate,WTUploadDelegate
>
@property (nonatomic,copy) NSString  *phone;
@property (nonatomic,copy) NSString  *pass_word;
@property (nonatomic,copy) NSString  *token;
@end

@implementation ImproveMyInformationViewController
{
    UIImage *upLoadImage;
    NSString *upLoadImagekey;
    NSString *upLoadImagetoken;
    
    UIScrollView *scrollView;
    UITextField  *nameTextField;
    UIButton *chooseImageBtn;
    UITextField *identityTextField;
    NSArray *pickArr;
    CommPickView *pickView;
    UserGender userGender;

	WTUploadManager *uploadManager;
	id uploadInfo;
}

+ (instancetype)instanceVCWithPhone:(NSString *)phone pwd:(NSString *)pwd token:(NSString *)token
{
	ImproveMyInformationViewController *VC = [ImproveMyInformationViewController new];
	VC.phone = [LWUtil getString:phone andDefaultStr:@""];
	VC.token = [LWUtil getString:token andDefaultStr:@""];
	VC.pass_word = [LWUtil getString:pwd andDefaultStr:@""];
	return VC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    loginManager=[[LoginManager alloc]init];
    loginManager.delegate = self;

	uploadManager = [WTUploadManager manager];
	uploadManager.delegate = self;
}

-(void)initView{
    self.title = @"完善我的信息";
	_token = [LWUtil getString:_token andDefaultStr:@""];
    userGender = UserGenderUnknow;
	upLoadImagekey = @"";
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-64)];
    scrollView.contentSize         = CGSizeMake(scrollView.width,scrollView.height+0.5);
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:scrollView];
    
    chooseImageBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 100, 100)];
    chooseImageBtn.centerX = screenWidth/2.f;
    [chooseImageBtn setImage:[UIImage imageNamed :@"photo_icon" ] forState:UIControlStateNormal];
    chooseImageBtn.clipsToBounds=YES;
    chooseImageBtn.layer.cornerRadius=chooseImageBtn.width/2.f;
    [chooseImageBtn addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:chooseImageBtn];
    
    nameTextField             = [[UITextField alloc] init];
    nameTextField.left        =16;
    nameTextField.top         = 160;
    nameTextField.width       = screenWidth-nameTextField.left;
    nameTextField.height      = 30;
    nameTextField.delegate    = self;
    nameTextField.placeholder = @"我的姓名(必填)";
    nameTextField.returnKeyType=UIReturnKeyNext;
    [scrollView addSubview:nameTextField];
    
    identityTextField = [[UITextField alloc] init];
    identityTextField.left        =16;
    identityTextField.width       = screenWidth-identityTextField.left;
    identityTextField.height      = 30;
    identityTextField.top = nameTextField.bottom+topGap;
    identityTextField.placeholder =@"完善我的婚礼角色";
    [scrollView addSubview:identityTextField];
    
    UIButton *chooseIdentityBtn = [[UIButton alloc] initWithFrame:identityTextField.frame];
    chooseIdentityBtn.titleLabel.font=[WeddingTimeAppInfoManager fontWithSize:14];
    chooseIdentityBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    [scrollView addSubview:chooseIdentityBtn];
    [chooseIdentityBtn addTarget:self action:@selector(chooseIdentityEvent) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *finshBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    finshBtn.frame=CGRectMake(0, screenHeight-64-50, screenWidth, 50);
    [finshBtn setTitle:@"完成" forState:UIControlStateNormal];
    finshBtn.backgroundColor=[[WeddingTimeAppInfoManager instance] baseColor];
    [finshBtn addTarget:self action:@selector(finishEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finshBtn];
    
    for(int i=0;i<2;i++) {
        UIImageView *lineView  = [[UIImageView alloc] initWithFrame:CGRectMake(lineViewLeftGap, nameTextField.bottom+i*(topGap+nameTextField.height), screenWidth - lineViewLeftGap, 0.5f)];
        lineView.clipsToBounds=NO;
        lineView.image = [LWUtil imageWithColor:[UIColor grayColor] frame:CGRectMake(0, 0, screenWidth, 0.5)];
        [scrollView addSubview:lineView];
    }
    
    pickArr = @[@"新郎",@"新娘"];
    pickView= [CommPickView instanceWithStyle:PickViewStylePicker andTag:0 andArray:pickArr];
    pickView.delagate=self;
    UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackGround)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
}
- (void)tapBackGround {
    
    for(UITextField *textField in scrollView.subviews) {
        if ([textField isKindOfClass:[UITextField class]]) {
            [textField resignFirstResponder];
        }
    }
}
-(void)chooseIdentityEvent
{
	[self.view endEditing:YES];
    [pickView show];
}
- (void)didPickObjectWithIndex:(int)index andTag:(NSInteger)tag {
    userGender = index==0?UserGenderMale: UserGenderFemale;
    identityTextField.text = pickArr[index];
}

#pragma mark -先图片

- (void)takePhoto {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"选择您的头像"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"拍照",@"从相册中选" ,nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    FSMediaPicker *mediaPicker = [[FSMediaPicker alloc] init];
    mediaPicker.mediaType      = FSMediaTypePhoto;
    mediaPicker.editMode =FSEditModeCircular;
    mediaPicker.delegate       = self;
    if (buttonIndex==0) {
        [mediaPicker takePhotoFromCamera];
    }else if (buttonIndex==1) {
        [mediaPicker takePhotoFromPhotoLibrary];
    }
}

- (void)mediaPicker:(FSMediaPicker *)mediaPicker didFinishWithMediaInfo:(NSDictionary *)mediaInfo {
    upLoadImage=mediaPicker.editMode == FSEditModeNone?mediaInfo.originalImage:mediaInfo.editedImage;
    upLoadImage = [LWUtil OriginImage:upLoadImage scaleToSize:CGSizeMake(200, 200)];
	uploadInfo = UIImageJPEGRepresentation(upLoadImage, 1.0);
	[self uploadImage];
}

- (void)uploadImage
{
	[self showLoadingView];
	loadingHUD.mode = MBProgressHUDModeDeterminate;
	loadingHUD.progress=0.f;
	[uploadManager uploadFileWithFileInfo:uploadInfo fileType:WTFileTypeImage fileBucket:@"mt-avatar"];
}

- (void)uploadManager:(WTUploadManager *)uploadManager didChangeProgress:(CGFloat)percent
{
	loadingHUD.progress = percent;
}

- (void)uploadManager:(WTUploadManager *)uploadManager didFailedUpload:(NSError *)error
{
	AlertViewWithBlockOrSEL *alertView = [[AlertViewWithBlockOrSEL alloc] initWithTitle:@"无法连接服务器"
																				message:@"需要重试吗?"];
	[alertView addOtherButtonWithTitle:@"重新上传" onTapped:^{
		 [self uploadImage];
	 }];
	[alertView setCancelButtonWithTitle:@"取消" onTapped:nil];
	[alertView show];
}

- (void)uploadManager:(WTUploadManager *)uploadManager didFinishedUploadWithKey:(NSString *)key
{
	[self hideLoadingView];
	upLoadImagekey = key;
	[chooseImageBtn setImage:upLoadImage forState:UIControlStateNormal];
}

-(void)finishEvent
{
    if (![nameTextField.text isNotEmptyCtg]) {
        [WTProgressHUD ShowTextHUD:@"还没填写您的姓名哦" showInView:self.view];
        return;
    }

	[UserService updateUserInfomationWithAvata:upLoadImagekey andUserName:nameTextField.text andRole:userGender andToken:_token withBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
		[self doFinishUpdateWithResult:result andError:error];
    }];
}

- (void)doFinishUpdateWithResult:(NSDictionary *)result andError:(NSError *)error {
    if (error||!result||![result isKindOfClass:[NSDictionary class]]) {
        [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error defaultStr:@"出错啦,请稍后再试" noresultStr:@""] showInView:self.view];
    }else {
        [self showLoadingView];
        [loginManager loginWithPhone:self.phone andpassword:self.pass_word];
        [[UserInfoManager instance] saveToUserDefaults];
    }
}

- (void)back {
    AlertViewWithBlockOrSEL *alertView = [[AlertViewWithBlockOrSEL alloc] initWithTitle:@"返回" message:@"信息未保存,确定返回吗?"];
	alertView.delegate = self;
    [alertView addOtherButtonWithTitle:@"确定" onTapped:^{
         [super back];
     }];
    [alertView setCancelButtonWithTitle:@"留在此页" onTapped:nil];
    [alertView show];
}

-(void)addAnimation
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.35f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    transition.type = @"reveal";
    transition.subtype = kCATransitionFromBottom;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
}

- (void)logoutFaild:(NSString *)errInfo {
    [loadingHUD hide:NO];
    [WTProgressHUD ShowTextHUD:errInfo showInView:self.view];
}

- (void)loginSucceed:(NSDictionary*)result {
    [loadingHUD hide:YES];
    if([result[@"user_type"] isEqualToString:@"supplier"])
    {
        [WTProgressHUD ShowTextHUD:@"别调皮啦，您是商家用户～" showInView:self.view];
        return;
    }
    
    [LoginManager loginSucceedAfter:result];

    [self addAnimation];
	[LoginManager makeMainViewControllerWithAnimation:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}
@end
