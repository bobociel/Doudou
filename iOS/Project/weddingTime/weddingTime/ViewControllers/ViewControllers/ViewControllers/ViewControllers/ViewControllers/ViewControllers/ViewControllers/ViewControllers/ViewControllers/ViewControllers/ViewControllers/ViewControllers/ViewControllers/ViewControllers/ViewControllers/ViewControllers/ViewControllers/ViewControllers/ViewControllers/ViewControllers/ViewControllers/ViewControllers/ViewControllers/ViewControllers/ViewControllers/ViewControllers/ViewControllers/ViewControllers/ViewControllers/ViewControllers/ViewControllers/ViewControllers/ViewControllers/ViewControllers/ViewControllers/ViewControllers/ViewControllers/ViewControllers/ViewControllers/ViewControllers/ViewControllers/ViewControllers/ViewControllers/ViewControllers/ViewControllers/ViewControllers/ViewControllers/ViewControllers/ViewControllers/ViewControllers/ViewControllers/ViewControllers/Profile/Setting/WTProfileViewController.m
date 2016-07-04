
//
//  WDInformationViewController.m
//  lovewith
//
//  Created by imqiuhang on 15/5/13.
//  Copyright (c) 2015年 lovewith.me. All rights reserved.
//

#import "WTProfileViewController.h"
#import "WTLocationViewController.h"
#import "CommDatePickView.h"
#import "CommPickView.h"
#import "AlertViewWithBlockOrSEL.h"
#import "FSMediaPicker.h"
#import "QiniuSDK.h"
#import "UserService.h"
#import "WTAlertView.h"
#import "PostDataService.h"
#import "LWAssistUtil.h"
#import "LWUtil.h"
#import "WeddingTimeAppInfoManager.h"
#import "WTSettingViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "WTUploadManager.h"
#import "UIImage+YYAdd.h"
#define kButtonHeight    44.f
#define lineViewLeftGap  15
#define textFieldleft    100
#define leftLableLeftGap 15
#define ButtomGap        10
#define dominLableWith   90

@interface WTProfileViewController ()
<
    UITextFieldDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,
    CommDatePickViewDelegate,CommPickViewDelegate,
    FSMediaPickerDelegate,WTUploadDelegate
>
@property(nonatomic)CGFloat keyBoardHeight;

@end

@implementation WTProfileViewController
{
    TPKeyboardAvoidingScrollView *contentScrollView;
    UITextField *nameInput;
    UITextField *parterInput;
    UITextField *domainNameInput;
    UIButton *chooseDateBtn;
    UIButton *chooseRoleBtn;
    UIImageView *myHeadImageView;
    UIImageView *partnerHeadImageView;
    UIView      *tableViewHeadView ;
    UILabel     * weddingAddressLabel;
    UIButton    *weddingAdressButton;

    UserGender role;
    CommPickView *pickView;
	CommDatePickView *datePickView;

	WTUploadManager *uploadManager;
	id uploadInfo;

    NSArray *pickArr;
	int64_t weddingDay_time;
    
    NSString *avataKeySelf;
    NSString *avataKeyPartner;
	NSString *weddingMapPoint;
    UIImage *upLoadImage;
    int avataTag;
    
    BOOL haveChangeAvatar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[[SDImageCache sharedImageCache] initWithNamespace:@"Person"] storeImage:nil forKey:nil];
    [self initView];
    [self initContentView];

	uploadManager = [WTUploadManager manager];
	uploadManager.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[[SDImageCache sharedImageCache] initWithNamespace:@"Person"] storeImage:nil forKey:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[[SDImageCache sharedImageCache] initWithNamespace:@"default"] storeImage:nil forKey:nil];
}

- (void)didPickDataWithDate:(NSDate *)date andType:(PickerViewType)tag {
	weddingDay_time = [date timeIntervalSince1970];
	[self resetBtnWhileChooseTime];

	if(tag == PickerViewTypeDate){
		[datePickView setCurrentTimeWith:weddingDay_time];
		[datePickView showWithType:PickerViewTypeDateAndTime];
	}
}

- (void)didPickObjectWithIndex:(int)index andTag:(int)tag {
    role = index==0?UserGenderMale: UserGenderFemale;
    [chooseRoleBtn setTitle:pickArr[index] forState:UIControlStateNormal];
}

- (void)resetBtnWhileChooseTime
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    if (weddingDay_time>0) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:weddingDay_time];
        NSString * dateStr = [dateFormatter stringFromDate:date];
        [chooseDateBtn setTitle:dateStr forState:UIControlStateNormal];
    }
}

- (void)dateBtnEvent {
    [self.view endEditing:YES];
	[datePickView setCurrentTimeWith:0];
    [datePickView showWithType:PickerViewTypeDate];
}

- (void)chooseIdentityEvent {
	[self.view endEditing:YES];
    [pickView showWithTag:0];
}

- (void)saveUserInfo
{
    if (![nameInput.text isNotEmptyCtg]) {
        WTAlertView *alertView=[[WTAlertView alloc]initWithText:@"还没有填写您的名字哦" centerImage:nil];
        [alertView show];
        return;
    }
    if (![parterInput.text isNotEmptyCtg]) {
        WTAlertView *alertView=[[WTAlertView alloc]initWithText:@"还没有填写另一半的名字哦" centerImage:nil];
        [alertView show];
        return;
    }
    
    if (role ==UserGenderUnknow) {
        WTAlertView *alertView=[[WTAlertView alloc]initWithText:@"还没有选择您的角色哦" centerImage:nil];
        [alertView show];
        return;
    }

    [self showLoadingView];
    
    [PostDataService postWeddingHomePageUpadateInfomationWithName:nameInput.text
                                                     andLoverName:parterInput.text
                                                          androle:role
                                              andweddingTimestamp:weddingDay_time
                                                        anddomain:domainNameInput.text
                                                andWeddingAddress:weddingAddressLabel.text
                                                  andWeddingPoint:weddingMapPoint
                                                       andMyAvata:avataKeySelf
                                                  andPartnerAvata:avataKeyPartner
                                                        withBlock:^(NSDictionary *result, NSError *error)
	{
		[self hideLoadingView];
        if (error) {
            WTAlertView *alertView=[[WTAlertView alloc] initWithText:[LWAssistUtil getCodeMessage:error andDefaultStr:@""] centerImage:nil];
            [alertView show];
        }else {
			if([result[@"status"] integerValue] == 2001 || [result[@"status"] integerValue] == 2002 ){
				if([result[@"status"] integerValue] == 2002 && domainNameInput.text.length > 0){
					[[[WTAlertView alloc]initWithText:@"婚礼域名重复" centerImage:nil] show];
				}else{
					[[[WTAlertView alloc]initWithText:@"保存成功" centerImage:nil] show];

					NSMutableDictionary *mudata = [[NSMutableDictionary alloc] initWithCapacity:10];
					for (id key in [result[@"data"] allKeys]) {
						mudata[key] = [LWUtil getString:result[@"data"][key] andDefaultStr:@""];
					}
					[UserInfoManager instance].weddingTime = weddingDay_time;
					[UserInfoManager instance].wedding_map_point = weddingMapPoint ;
					[LoginManager loginSucceedAfter:mudata];
					[self.navigationController popViewControllerAnimated:YES];
				}
			}

			[[NSNotificationCenter defaultCenter] postNotificationName:HomePageWebShouldBeReloadNotify object:nil];
        }
    }];
}

-(BOOL)haveChangeInfo
{
    if (![nameInput.text isEqualToString:[UserInfoManager instance].username_self] && nameInput.text) {
        return YES;
    }
    
    if (![parterInput.text isEqualToString:[UserInfoManager instance].username_partner] && parterInput.text) {
        return YES;
    }
    
    if (![domainNameInput.text isEqualToString:[UserInfoManager instance].domainName] && domainNameInput.text) {
        return YES;
    }
    
    if (![weddingAddressLabel.text isEqualToString:[UserInfoManager instance].wedding_address] && weddingAddressLabel.text) {
        return YES;
    }
    
    if (role!=[UserInfoManager instance].userGender) {
        return YES;
    }
    
    if (weddingDay_time!=[UserInfoManager instance].weddingTime&&weddingDay_time!=-1) {
        return YES;
    }
    
    if (haveChangeAvatar) {
         return YES;
    }
    
    return NO;
}

-(void)back
{
    if (![self haveChangeInfo]) { [super back]; }
    else
    {
        AlertViewWithBlockOrSEL *alert = [[AlertViewWithBlockOrSEL alloc] initWithTitle:@"" message:@"修改的资料尚未保存，是否保存" ];
		alert.delegate = self;
        [alert addOtherButtonWithTitle:@"保存" onTapped:^{
            [self saveUserInfo];
        }];
        [alert setCancelButtonWithTitle:@"取消" onTapped:^{
			[super back];
        }];
        [alert show];
    }
}

- (void)rightNavBtnEvent
{
	if([[UserInfoManager instance].userId_partner isNotEmptyCtg])
	{
		AlertViewWithBlockOrSEL *alertView = [[AlertViewWithBlockOrSEL alloc] initWithTitle:@"解除绑定" message:@"确定要与另一半解除绑定吗?"];
		alertView.delegate = self;
		[alertView addOtherButtonWithTitle:@"解除绑定" onTapped:^{
			[self showLoadingView];
			[UserService postDrapReleshipWithBlock:^(NSDictionary *result, NSError *error) {
				if (error) {
					[self showLoadingViewTitle:@"出错啦,请稍后再试"];
				}else {
					[[UserInfoManager instance] clearConversations];
					[[UserInfoManager instance] updateUserInfoFromServer];
					[self showLoadingViewTitle:@"解除绑定成功"];
					[self setRightBtnWithTitle:@"绑定"];
					[[NSNotificationCenter defaultCenter] postNotificationName:UserDidRebindSucceedNotify object:nil];
					[[NSNotificationCenter defaultCenter] postNotificationName:HomePageWebShouldBeReloadNotify object:nil];
				}
				[self hideLoadingViewAfterDelay:1.0f];
			}];
		}];
		[alertView setCancelButtonWithTitle:@"取消" onTapped:^{

		}];
		[alertView show];
	}
	else
	{
		[UserInfoManager instance].showBling = YES;
		[[UserInfoManager instance] saveOtherToUserDefaults];
		[self.navigationController popToRootViewControllerAnimated:NO];
	}
}

- (void)initView {
    self.title = @"完善我和另一半";
    [self.view addSubview:[[UIView alloc] initWithFrame:CGRectZero]];
    
    contentScrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - kNavBarHeight - kButtonHeight)];
    [contentScrollView setContentSize:CGSizeMake(contentScrollView.frame.size.width, contentScrollView.height+1)];
    contentScrollView.showsVerticalScrollIndicator = NO;
    contentScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:contentScrollView];
    
    datePickView = [CommDatePickView viewWithStyle:PickerViewStyleDefault];
    datePickView.delagate=self;
    datePickView.dataPickView.minimumDate = [NSDate dateWithTimeIntervalSince1970:0];

    pickArr = @[@"新郎",@"新娘"];
    
    pickView= [[CommPickView alloc] initWithDataArr:pickArr];
    pickView.delagate=self;
    
	weddingDay_time = [UserInfoManager instance].weddingTime ? : -1 ;
    role = UserGenderUnknow;

    UIButton * saveBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, screenHeight -kNavBarHeight - kButtonHeight, screenWidth,kButtonHeight)];
	saveBtn.backgroundColor = [[WeddingTimeAppInfoManager instance] baseColor];
	saveBtn.titleLabel.font = DefaultFont16;
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBtn setTitle:@"确定" forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveUserInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];

	[self setRightBtnWithTitle:[[UserInfoManager instance].userId_partner isNotEmptyCtg] ? @"解绑" : @"绑定"];
}

- (void)initContentView
{
    myHeadImageView = [[UIImageView alloc] initWithFrame:CGRectMake((screenWidth-80)/2, 46, 80, 80)];
    myHeadImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    myHeadImageView.layer.borderWidth = 3;
    myHeadImageView.layer.cornerRadius = myHeadImageView.height/2.f;
    myHeadImageView.clipsToBounds = YES;
    myHeadImageView.tag                         = 0;
    myHeadImageView.userInteractionEnabled      = YES;
    myHeadImageView.contentMode=UIViewContentModeScaleToFill;
    UITapGestureRecognizer *mytap               = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseHeadImage:)];
    [myHeadImageView addGestureRecognizer:mytap];
    
    {
        [[UserInfoManager instance] setMyAvatar:myHeadImageView];
    }

    [contentScrollView addSubview:tableViewHeadView];
    
    UILabel *nameLable         = [[UILabel alloc] initWithFrame:CGRectMake(leftLableLeftGap, myHeadImageView.bottom+17, 64,40 )];
    nameLable.text             = @"我的名字";
    nameLable.textColor        = subTitleLableColor;
    nameLable.font=[WeddingTimeAppInfoManager fontWithSize:16];
    [contentScrollView addSubview:nameLable];
    nameInput                  = [[UITextField alloc] initWithFrame:CGRectMake(textFieldleft, myHeadImageView.bottom+17, screenWidth-textFieldleft-20, 40)];
    nameInput.textAlignment=NSTextAlignmentRight;
    nameLable.textColor    =[UIColor blackColor];
    nameInput.font=[WeddingTimeAppInfoManager fontWithSize:16];
    [contentScrollView addSubview:nameInput];
    UIImageView *firstLineView = [[UIImageView alloc] initWithFrame:CGRectMake(lineViewLeftGap,nameInput.bottom-3,screenWidth-lineViewLeftGap , 0.5f)];
    firstLineView.backgroundColor = rgba(230, 230, 230, 1.0);
    [contentScrollView addSubview:firstLineView];
    
    UILabel *roleLable         = [[UILabel alloc] initWithFrame:CGRectMake(leftLableLeftGap, firstLineView.bottom+5, textFieldleft-leftLableLeftGap,40 )];
    roleLable.text             = @"我的角色";
    roleLable.textColor=subTitleLableColor;
    roleLable.font=[WeddingTimeAppInfoManager fontWithSize:16];
    [contentScrollView addSubview:roleLable];
    UIImageView *secondLineView = [[UIImageView alloc] initWithFrame:CGRectMake(lineViewLeftGap,roleLable.bottom,screenWidth-lineViewLeftGap , 0.5f)];
    secondLineView.backgroundColor = rgba(230, 230, 230, 1.0);
    [contentScrollView addSubview:secondLineView];
    chooseRoleBtn                            = [[UIButton alloc] initWithFrame:CGRectMake(textFieldleft, roleLable.top, screenWidth-textFieldleft-20, 40)];
    chooseRoleBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [chooseRoleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    chooseRoleBtn.titleLabel.font            = [WeddingTimeAppInfoManager fontWithSize:16];
    [chooseRoleBtn addTarget:self action:@selector(chooseIdentityEvent) forControlEvents:UIControlEventTouchUpInside];
    [contentScrollView addSubview:chooseRoleBtn];
    
    partnerHeadImageView                        = [[UIImageView alloc] initWithFrame:CGRectMake((screenWidth-80)/2, secondLineView.bottom+30, 80, 80)];
    
    partnerHeadImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    partnerHeadImageView.layer.borderWidth = 3;
    partnerHeadImageView.contentMode=UIViewContentModeScaleToFill;
    partnerHeadImageView.layer.cornerRadius     = partnerHeadImageView.height/2.f;
    partnerHeadImageView.clipsToBounds          = YES;
    partnerHeadImageView.userInteractionEnabled = YES;
    partnerHeadImageView.tag                    = 1;
    UITapGestureRecognizer *partnertap          = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseHeadImage:)];
    [partnerHeadImageView addGestureRecognizer:partnertap];
    [contentScrollView addSubview:partnerHeadImageView];
    [contentScrollView addSubview:myHeadImageView];
    {
        [[UserInfoManager instance]setPartnerAvatar:partnerHeadImageView];
    }
    
    UILabel *partnerNameLable  = [[UILabel alloc] initWithFrame:CGRectMake(leftLableLeftGap, partnerHeadImageView.bottom+10, textFieldleft-leftLableLeftGap,40 )];
    partnerNameLable.text      = @"另一半姓名";
    partnerNameLable.textColor=subTitleLableColor;
    partnerNameLable.font=[WeddingTimeAppInfoManager fontWithSize:16];
    [contentScrollView addSubview:partnerNameLable];
    UIImageView *thirdLineView = [[UIImageView alloc] initWithFrame:CGRectMake(lineViewLeftGap,partnerNameLable.bottom-1,screenWidth-lineViewLeftGap , 0.5f)];
    thirdLineView.backgroundColor = rgba(230, 230, 230, 1.0);
    [contentScrollView addSubview:thirdLineView];
    parterInput  = [[UITextField alloc] initWithFrame:CGRectMake(textFieldleft, partnerNameLable.top, screenWidth-textFieldleft-20, 40)];
    parterInput.textAlignment=NSTextAlignmentRight;
    parterInput.font=[WeddingTimeAppInfoManager fontWithSize:16];
    parterInput.textColor=[UIColor blackColor];
    [contentScrollView addSubview:parterInput];
   
    
    UILabel *timeLable = [[UILabel alloc] initWithFrame:CGRectMake(leftLableLeftGap, thirdLineView.bottom+5, textFieldleft-leftLableLeftGap,40 )];
    timeLable.textColor = subTitleLableColor;
    timeLable.font = DefaultFont16;
	timeLable.text = @"我们的婚期";
    [contentScrollView addSubview:timeLable];

    UIImageView *fourthLineView = [[UIImageView alloc] initWithFrame:CGRectMake(lineViewLeftGap,timeLable.bottom-1,screenWidth-lineViewLeftGap , 0.5f)];
    fourthLineView.backgroundColor = rgba(230, 230, 230, 1.0);;
    [contentScrollView addSubview:fourthLineView];

    chooseDateBtn = [[UIButton alloc] initWithFrame:CGRectMake(textFieldleft, timeLable.top, screenWidth-textFieldleft-20, 40)];
    chooseDateBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    chooseDateBtn.titleLabel.font = DefaultFont16;
	[chooseDateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [chooseDateBtn addTarget:self action:@selector(dateBtnEvent) forControlEvents:UIControlEventTouchUpInside];
    [contentScrollView addSubview:chooseDateBtn];
	[self resetBtnWhileChooseTime];

    UILabel *addressLable = [[UILabel alloc] initWithFrame:CGRectMake(leftLableLeftGap, fourthLineView.bottom+5, textFieldleft-leftLableLeftGap,40 )];
    addressLable.textColor = subTitleLableColor;
    addressLable.font = DefaultFont16;
    addressLable.text = @"婚礼举办地";
    [contentScrollView addSubview:addressLable];

    UIImageView *fifthLineView = [[UIImageView alloc] initWithFrame:CGRectMake(lineViewLeftGap,addressLable.bottom-1,screenWidth-lineViewLeftGap , 0.5f)];
    fifthLineView.backgroundColor = rgba(230, 230, 230, 1.0);
    [contentScrollView addSubview:fifthLineView];

    weddingAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(textFieldleft, addressLable.top, screenWidth-textFieldleft-20, 40)];
    weddingAddressLabel.textAlignment = NSTextAlignmentRight;
    weddingAddressLabel.textColor = [UIColor blackColor];
    weddingAddressLabel.font = DefaultFont16;
    [contentScrollView addSubview:weddingAddressLabel];

    weddingAdressButton = [[UIButton alloc] initWithFrame:CGRectMake(lineViewLeftGap, addressLable.top, screenWidth-20, 40)];
    [contentScrollView addSubview:weddingAdressButton];
    [weddingAdressButton addTarget:self action:@selector(showLocation:) forControlEvents:UIControlEventTouchUpInside];


    UILabel *domainNameLable   = [[UILabel alloc] initWithFrame:CGRectMake(leftLableLeftGap, fifthLineView.bottom+5, textFieldleft-leftLableLeftGap,40 )];
	domainNameLable.textColor = subTitleLableColor;
    domainNameLable.font = DefaultFont16;
    domainNameLable.text = @"婚礼域名";
    [contentScrollView addSubview:domainNameLable];

    UIImageView *sixthLineView = [[UIImageView alloc] initWithFrame:CGRectMake(lineViewLeftGap,domainNameLable.bottom-1,screenWidth-lineViewLeftGap , 0.5f)];
    sixthLineView.backgroundColor = rgba(230, 230, 230, 1.0);
    [contentScrollView addSubview:sixthLineView];

    domainNameInput  = [[UITextField alloc] initWithFrame:CGRectMake(textFieldleft, domainNameLable.top, screenWidth - textFieldleft - 20 - dominLableWith - 20, 40)];
    domainNameInput.textAlignment=NSTextAlignmentRight;
    domainNameInput.textColor=[UIColor blackColor];
    domainNameInput.font = DefaultFont16;
    [contentScrollView addSubview:domainNameInput];
    
    UILabel *domainSuffix = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth -  70, domainNameLable.top-5,dominLableWith+20 ,50 )];
	domainSuffix.right = screenWidth - 15;
	domainSuffix.textAlignment = NSTextAlignmentRight;
	domainSuffix.textColor=[UIColor blackColor];
	domainSuffix.font = DefaultFont16;
    domainSuffix.text = @".lovewith.me";
    [contentScrollView addSubview:domainSuffix];

    contentScrollView.contentSize=CGSizeMake(screenWidth, domainNameInput.bottom+20);
    for(UILabel *lable in contentScrollView.subviews) {
        if(![lable isEqual:weddingAddressLabel] && ![lable isEqual:domainSuffix] && [lable isKindOfClass:[UILabel class]])
		{
                lable.font      = [WeddingTimeAppInfoManager fontWithSize:16];
                lable.textColor = subTitleLableColor;
                lable.textAlignment=NSTextAlignmentLeft;
                domainSuffix.textColor=[UIColor blackColor];
        }
    }

    for(UITextField *textfield in contentScrollView.subviews)
	{
        if ([textfield isKindOfClass:[UITextField class]]) {
            textfield.font            = [WeddingTimeAppInfoManager fontWithSize:16];
            textfield.textColor       = [UIColor blackColor];
            textfield.delegate        = self;
            textfield.clearButtonMode = UITextFieldViewModeWhileEditing;
        }
    }

    nameInput.text =[UserInfoManager instance].username_self;
    parterInput.text =[UserInfoManager instance].username_partner;

    if ([[UserInfoManager instance].domainName isNotEmptyCtg]) {
        domainNameInput.text =[UserInfoManager instance].domainName;
    }
    
    if ([[UserInfoManager instance].wedding_address isNotEmptyCtg]) {
        weddingAddressLabel.text =[UserInfoManager instance].wedding_address ;
    }

    if([[UserInfoManager instance].wedding_map_point isNotEmptyCtg]){
        weddingMapPoint = [UserInfoManager instance].wedding_map_point;
    }

    if ([UserInfoManager instance].weddingTime > NSTimeIntervalSince1970) {
        int64_t time = [UserInfoManager instance].weddingTime;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
		datePickView.dataPickView.date = date;
    }
    
    [self didPickObjectWithIndex:[UserInfoManager instance].userGender ==UserGenderMale?0:1 andTag:0];

}

- (void)chooseHeadImage:(UITapGestureRecognizer *)tap
{
    avataTag = (int)tap.view.tag;
    [self showChooseImage];
}

- (void)showLocation:(UITextField *)textField
{
    WTLocationViewController *locationVC = [[WTLocationViewController alloc] init];
    locationVC.address = weddingAddressLabel.text;
    locationVC.weddingMapPoint = weddingMapPoint;
    [locationVC setLocationBlock:^(NSString *weddingAddress, NSString *weddingMapP) {
        weddingAddressLabel.text = weddingAddress;
		weddingMapPoint = weddingMapP;
    }];
    [self.navigationController pushViewController:locationVC animated:YES];
}

- (void)showChooseImage {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择头像"
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
    mediaPicker.delegate       = self;
    mediaPicker.editMode = FSEditModeCircular;
    if (buttonIndex==0) {
        [mediaPicker takePhotoFromCamera];
    }else if (buttonIndex==1) {
        [mediaPicker takePhotoFromPhotoLibrary];
    }
}

- (void)mediaPicker:(FSMediaPicker *)mediaPicker didFinishWithMediaInfo:(NSDictionary *)mediaInfo {
    upLoadImage = mediaPicker.editMode == FSEditModeNone?mediaInfo.originalImage:mediaInfo.editedImage;

	upLoadImage = [upLoadImage imageByResizeToSize:CGSizeMake(200, 200) contentMode:UIViewContentModeScaleAspectFill];
	uploadInfo = UIImageJPEGRepresentation(upLoadImage,1.0);

	if(uploadInfo) { [self uploadWithFileOrData]; }
}

#pragma mark - WTUploadDelegate Upload
- (void)uploadWithFileOrData
{
	[self showLoadingView];
	self.loadingHUD.mode = MBProgressHUDModeDeterminate;
	self.loadingHUD.progress=0.f;
	[uploadManager uploadFileWithFileInfo:uploadInfo fileType:WTFileTypeImage fileBucket:@"mt-avatar"];
}

- (void)uploadManager:(WTUploadManager *)uploadManager didChangeProgress:(CGFloat)percent
{
	self.loadingHUD.progress = percent;
}

- (void)uploadManager:(WTUploadManager *)uploadManager didFailedUpload:(NSError *)error
{
	AlertViewWithBlockOrSEL *alertView = [[AlertViewWithBlockOrSEL alloc] initWithTitle:@"无法连接服务器"
																				message:@"需要重试吗?"];
	[alertView addOtherButtonWithTitle:@"重新上传" onTapped:^{
		[self uploadWithFileOrData];
	}];

	[alertView setCancelButtonWithTitle:@"取消" onTapped:nil];
	[alertView show];
}

- (void)uploadManager:(WTUploadManager *)uploadManager didFinishedUploadWithKey:(NSString *)key
{
	[self hideLoadingView];
	[self upLoadImageSucceed:key];
}

- (void)upLoadImageSucceed:(NSString *)key {
    if (avataTag == 0)
	{
        avataKeySelf = key;
        myHeadImageView.image = upLoadImage;
		[LWUtil writeImage:upLoadImage toFileAtPath:[LWUtil documentPath:avataKeySelf]];
    }
	else
	{
		[LWUtil writeImage:upLoadImage toFileAtPath:[LWUtil documentPath:avataKeyPartner]];
        avataKeyPartner = key;
        partnerHeadImageView.image=upLoadImage;
    }
    
    haveChangeAvatar = YES;
}

@end
