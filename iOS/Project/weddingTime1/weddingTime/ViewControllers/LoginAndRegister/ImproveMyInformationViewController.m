//
//  ImproveMyInformationViewController.m
//  weddingTime
//
//  Created by _Cuixin on 15/9/17.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "ImproveMyInformationViewController.h"
#import "FSMediaPicker.h"
#import "GetService.h"
#import "UserInfoManager.h"
#import "UserService.h"
#import "LWUtil.h"
#import "LWAssistUtil.h"
#import "CommPickView.h"
#import "WTProgressHUD.h"
#import "AlertViewWithBlockOrSEL.h"
#import "WTRegisterViewController.h"
#import "QiniuSDK.h"
#import "WTBindingViewController.h"

#define topGap           30.f
#define lineViewLeftGap  8.f
@interface ImproveMyInformationViewController ()<UITextFieldDelegate,CommPickViewDelegate,FSMediaPickerDelegate,UIActionSheetDelegate,LoginManagerDelegate>

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

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    loginManager=[[LoginManager alloc]init];
    loginManager.delegate       = self;
}

-(void)initView{
    self.title = @"完善我的信息";
    userGender = UserGenderUnknow;
    self.view.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:[[UIView alloc] initWithFrame:CGRectZero]];
    
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
    nameTextField.placeholder = @"我的姓名";
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
    
    pickView= [[CommPickView alloc] initWithDataArr:pickArr];
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
-(void)chooseIdentityEvent{
    [pickView showWithTag:0];
}
- (void)didPickObjectWithIndex:(int)index andTag:(int)tag {
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
    } else{
        
    }
}


- (void)mediaPicker:(FSMediaPicker *)mediaPicker didFinishWithMediaInfo:(NSDictionary *)mediaInfo {
    upLoadImage=mediaPicker.editMode == FSEditModeNone?mediaInfo.originalImage:mediaInfo.editedImage;
    upLoadImage = [LWUtil OriginImage:upLoadImage scaleToSize:CGSizeMake(200, 200)];
    [self getQiniuToken];
}
- (void)getQiniuToken {
    [self showLoadingView];
    [GetService getQiniuTokenWithBucket:@"mt-avatar"  WithBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        if (error||![result[@"uptoken"] isNotEmptyCtg]) {
            AlertViewWithBlockOrSEL *alertView = [[AlertViewWithBlockOrSEL alloc]
                                                  initWithTitle:@"无法连接服务器"
                                                  message:@"需要重试吗?"];
            [alertView
             addOtherButtonWithTitle:@"重新上传"
             onTapped:^{
                 [self getQiniuToken];
             }];
            [alertView setCancelButtonWithTitle:
             @"取消" onTapped:^{
             }];
            [alertView show];
        }else {
            upLoadImagetoken = result[@"uptoken"];
            [self upLoadImageWithToken:result[@"uptoken"]];
        }
    }];
    
}
- (void)upLoadImageWithToken:(NSString *)token {
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    [self showLoadingView];
    loadingHUD.mode = MBProgressHUDModeDeterminate;
    loadingHUD.progress=0.f;
    QNUploadOption  *option = [[QNUploadOption alloc] initWithMime:@"image/png" progressHandler:^(NSString *key, float percent) {
        loadingHUD.progress=percent;
    } params:nil checkCrc:NO cancellationSignal:nil];
    
    int64_t timeSince  = [[NSDate date] timeIntervalSince1970];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeSince];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSString * dateStr = [dateFormatter stringFromDate:date];
    NSData *imageData = UIImageJPEGRepresentation(upLoadImage, 1.f);
    
    NSString *key = [NSString stringWithFormat:@"%@/%lu%@",dateStr,(unsigned long)[imageData hash],[LWUtil randomStringWithLength:15]];
    
    [upManager putData:imageData key:key token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        [self hideLoadingView];
        if (!resp) {
            
            AlertViewWithBlockOrSEL *alertView = [[AlertViewWithBlockOrSEL alloc]
                                                  initWithTitle:@"无法连接服务器"
                                                  message:@"需要重试吗?"];
            [alertView
             addOtherButtonWithTitle:@"重新上传"
             onTapped:^{
                 [self upLoadImageWithToken:upLoadImagetoken];
                 
             }];
            [alertView setCancelButtonWithTitle:
             @"取消" onTapped:^{
             }];
            [alertView show];
            
        }else {
            upLoadImagekey =  resp[@"key"];
            [chooseImageBtn setImage:upLoadImage forState:UIControlStateNormal];
        }
    } option:option];
}

-(void)finishEvent{
    if (![nameTextField.text isNotEmptyCtg]) {
        [WTProgressHUD ShowTextHUD:@"还没填写您的姓名哦" showInView:self.view];
        return;
    }
    if (userGender==UserGenderUnknow) {
        [WTProgressHUD ShowTextHUD:@"还没选择您的身份哦" showInView:self.view];
        return;
    }
    if(![upLoadImagekey isNotEmptyCtg]) {
        [WTProgressHUD ShowTextHUD:@"还没上传您的头像哦" showInView:self.view];
        return;
    }
    [UserService updateUserInfomationWithAvata:upLoadImagekey andUserName:nameTextField.text andRole:userGender withBlock:^(NSDictionary *result, NSError *error) {
        [self hideLoadingView];
        [self doFinishUpdateWithResult:result andError:error];
    }];

}

- (void)doFinishUpdateWithResult:(NSDictionary *)result andError:(NSError *)error {
    if (error||!result||![result isKindOfClass:[NSDictionary class]]) {
        [WTProgressHUD ShowTextHUD:[LWAssistUtil getCodeMessage:error defaultStr:@"出错啦,请稍后再试" noresultStr:@""] showInView:self.view];
    }else {
        [UserInfoManager instance].username_self = result[@"username"];
        [UserInfoManager instance].avatar_self   = result[@"avatar"];
        if ([result[@"gender"] isEqualToString:@"m"]) {
            [UserInfoManager instance].userGender = UserGenderMale;
        }else {
            [UserInfoManager instance].userGender = UserGenderFemale;
        }
        
        [self showLoadingView];
        [loginManager loginWithPhone:[UserInfoManager instance].phone_self andpassword:self.pass_word];
        [[UserInfoManager instance] saveToUserDefaults];
    }
}

- (void)back {
    AlertViewWithBlockOrSEL *alertView = [[AlertViewWithBlockOrSEL alloc]
                                          initWithTitle:@"返回"
                                          message:@"信息未保存,确定返回吗?"];
    [alertView
     addOtherButtonWithTitle:@"确定"
     onTapped:^{
         [super back];
     }];
    [alertView setCancelButtonWithTitle:
     @"留在此页" onTapped:^{
     }];
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
    
    if(![result[@"phone"] isNotEmptyCtg])
    {
        //进入绑定界面
        WTBindingViewController *next=[WTBindingViewController new];
        next.result=result;
        [self.navigationController pushViewController:next animated:YES];
        return;
    }

    [LoginManager loginSucceedAfter:result];
    
    [self addAnimation];
    if (self.navigationController) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
