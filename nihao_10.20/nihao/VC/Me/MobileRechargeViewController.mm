//
//  MobileRechargeViewController.m
//  nihao
//
//  Created by 刘志 on 15/8/10.
//  Copyright (c) 2015年 jiazhong. All rights reserved.
//

#import "MobileRechargeViewController.h"
#import "AppConfigure.h"
#import "HttpManager.h"
#import "MBProgressHUD.h"
#import "MobileChargeCollectionViewCell.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "MobileRechargeOrder.h"
#import <MJExtension.h>
#import "UPPayPlugin.h"
#import "ChargeFailViewController.h"
#import "ChargeSuccessViewController.h"
#import "AppDelegate.h"

@interface MobileRechargeViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,ABPeoplePickerNavigationControllerDelegate,UIScrollViewDelegate,UPPayPluginDelegate>{
    UIButton *_netErrButton;
    NSUInteger _cellWidth;
    NSUInteger _cellHeight;
    NSIndexPath *_selectedIndexPath;
    UICollectionView *_collectionView;
    UITextField *_phoneTextField;
    
    NSMutableArray *_data;
    NSMutableData *_responseData;
    
    //循环查询服务器话费是否充值成功的时间点，若查询的时间超过5秒，将计时器停止
    NSTimeInterval _askTime;
    //充值话费订单号
    NSString *_orderNo;
    //充值电话号码
    NSString *_chargePhone;
    //充值费用
    NSString *_chargeFee;
}

@property (nonatomic) ABPeoplePickerNavigationController *peoplePicker;

@end

@implementation MobileRechargeViewController

//collection cell之间的间距
static const NSInteger CELL_MARGIN = 13;
static NSString *const IDENTIFIER = @"cellIdentifier";

//循环查询时间不能超过5秒
static const NSUInteger MAX_ASK_TIME = 15;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Mobile Recharge(China Only)";
    [self dontShowBackButtonTitle];

    _netErrButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 135) / 2, (SCREEN_HEIGHT - 64 - 87) / 2, 135, 87)];
    [_netErrButton setImage:[UIImage imageNamed:@"common_icon_neterr"] forState:UIControlStateNormal];
    [_netErrButton addTarget:self action:@selector(retryNetWork) forControlEvents:UIControlEventTouchUpInside];
    _netErrButton.hidden = YES;
    [self.view addSubview:_netErrButton];
    
    _data = [NSMutableArray array];
    [self requestMobileRechargeGoodsList];
    
    [[UINavigationBar appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : FontWithSize(16.0)}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) initViews {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    scrollView.backgroundColor = ColorWithRGB(244, 244, 244);
    scrollView.delegate = self;
    
    UILabel *chinaOnlyLabel = [[UILabel alloc] init];
    chinaOnlyLabel.text = @"China Only";
    chinaOnlyLabel.textColor = ColorWithRGB(120, 120, 120);
    chinaOnlyLabel.font = FontNeveLightWithSize(14.0);
    [chinaOnlyLabel sizeToFit];
    chinaOnlyLabel.frame = CGRectMake(15, 15, CGRectGetWidth(chinaOnlyLabel.frame), CGRectGetHeight(chinaOnlyLabel.frame));
    [scrollView addSubview:chinaOnlyLabel];
    
    //手机号码输入父控件
    UIView *phoneNumView = [[UIView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(chinaOnlyLabel.frame) + 15, SCREEN_WIDTH, 50)];
    phoneNumView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:phoneNumView];
    
    //手机联系人点击
    UIControl *mobileContactControl = [[UIControl alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 50, 0, 50, 50)];
    mobileContactControl.backgroundColor = [UIColor whiteColor];
    [phoneNumView addSubview:mobileContactControl];
    [mobileContactControl addTarget:self action:@selector(viewContacts) forControlEvents:UIControlEventTouchUpInside];
    [phoneNumView addSubview:mobileContactControl];
    //手机联系人图标
    UIImageView *mobileContactImage = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(mobileContactControl.frame) - 20) / 2, (CGRectGetHeight(mobileContactControl.frame) - 23) / 2, 20, 23)];
    mobileContactImage.image = ImageNamed(@"icon_mobile_contact");
    [mobileContactControl addSubview:mobileContactImage];
    mobileContactImage.userInteractionEnabled = NO;
    //手机号码输入框
    _phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(25, (CGRectGetHeight(mobileContactControl.frame) - 30) / 2, SCREEN_WIDTH - 25 - 50 - 15, 30)];
    _phoneTextField.backgroundColor = [UIColor whiteColor];
    _phoneTextField.keyboardType = UIKeyboardTypePhonePad;
    _phoneTextField.font = FontNeveLightWithSize(16);
    _phoneTextField.textColor = [UIColor blackColor];
    _phoneTextField.placeholder = @"Phone";
    //默认显示当前登录用户的手机号码
    NSDictionary *userInfo = [AppConfigure loginUserProfile];
    NSString *loginedUserPhoneNumber = [userInfo objectForKey:LOGINED_USER_PHONE];
    if(!IsStringEmpty(loginedUserPhoneNumber)) {
        if([loginedUserPhoneNumber hasPrefix:@"+86"]) {
           loginedUserPhoneNumber = [loginedUserPhoneNumber stringByReplacingOccurrencesOfString:@"+86" withString:@""];
        }
        _phoneTextField.text = loginedUserPhoneNumber;
    }
    [phoneNumView addSubview:_phoneTextField];
    
    //充值话费商品
    _cellWidth = (SCREEN_WIDTH - 20 * 2 - CELL_MARGIN * 2) / 3;
    _cellHeight = _cellWidth * 2 / 5;
    NSUInteger row = _data.count / 3 + ((_data.count % 3 == 0) ? 0 : 1);
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(phoneNumView.frame) + 20, SCREEN_WIDTH - 20 * 2, _cellHeight * row + CELL_MARGIN * (row - 1)) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.scrollEnabled = NO;
    [_collectionView registerNib:[UINib nibWithNibName:@"MobileChargeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:IDENTIFIER];
    layout.minimumInteritemSpacing = 13;
    layout.minimumLineSpacing = 13;
    [scrollView addSubview:_collectionView];
    
    //支付按钮
    UIButton *payButton = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_collectionView.frame) + 20, SCREEN_WIDTH - 20 * 2, 40)];
    [payButton setTitle:@"Confirm" forState:UIControlStateNormal];
    [payButton setBackgroundColor:ColorWithRGB(64, 183, 250)];
    payButton.titleLabel.font = FontNeveLightWithSize(18.0);
    [payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [payButton addTarget:self action:@selector(pay) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:payButton];
    
    CGFloat maxY;
    if(CGRectGetMaxY(payButton.frame) >= CGRectGetMaxY(scrollView.frame)) {
        maxY = CGRectGetMaxY(payButton.frame);
    } else {
        maxY = CGRectGetMaxY(scrollView.frame);
    }
    
    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, maxY);
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    
    [self.view addSubview:scrollView];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - click events
/**
 *  进入手机联系人页面
 */
- (void) viewContacts {
    _peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    // place the delegate of the picker to the controll
    _peoplePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    _peoplePicker.modalInPopover = YES;
    _peoplePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    _peoplePicker.peoplePickerDelegate = self;
    _peoplePicker.navigationBar.barTintColor = AppBlueColor;
    _peoplePicker.navigationBar.tintColor = [UIColor whiteColor];
    
    [self presentViewController:_peoplePicker animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}

- (void) pay {
    if(!IsStringEmpty(_phoneTextField.text)) {
        [self checkIfChargePhoneNumberValid];
    } else {
        [self showHUDErrorWithText:@"Phone number is empty"];
    }
}

- (void) retryNetWork {
    [self requestMobileRechargeGoodsList];
}

#pragma mark - net work
- (void) requestMobileRechargeGoodsList {
    _netErrButton.hidden = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [HttpManager requestMobileContactGoodsList:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if([responseObject[@"code"] integerValue] == 0) {
            NSArray *orders = responseObject[@"result"][@"items"];
            for(NSDictionary *item in orders) {
                MobileRechargeOrder *order = [MobileRechargeOrder objectWithKeyValues:item];
                [_data addObject:order];
            }
            [self initViews];
            [_collectionView reloadData];
        } else {
            [self showHUDNetError];
            _netErrButton.hidden = NO;
        }
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        [self showHUDNetError];
        _netErrButton.hidden = NO;
    }];
}

- (void) checkIfChargePhoneNumberValid {
    MobileRechargeOrder *order = _data[_selectedIndexPath.row];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *phoneNum = _phoneTextField.text;
    if([phoneNum rangeOfString:@"-"].length > 0) {
        phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    if([phoneNum hasPrefix:@" "]) {
        phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    _chargePhone = phoneNum;
    _chargeFee = [NSString stringWithFormat:@"%ld",order.pi_real_price];
    [HttpManager checkChargePhoneNumberIfValid:phoneNum money:[NSString stringWithFormat:@"%ld",order.pi_real_price] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([responseObject[@"error_code"] integerValue] == 0) {
            //创建订单
            NSString *pi_param = @"充值号码:%@";
            [HttpManager makeYinlianOrder:order.pi_id od_pi_count:1 pi_params:[NSString stringWithFormat:pi_param,phoneNum] oi_introduction:@"话费充值" oi_source:@"20" ci_id:[NSString stringWithFormat:@"%ld",[AppConfigure integerForKey:LOGINED_USER_ID]] payType:@"1" success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *tn = responseObject[@"result"][@"unionpayInfo"][@"tn"];
                _orderNo = responseObject[@"result"][@"orderInfo"][@"oi_number"];
                [UPPayPlugin startPay:tn mode:@"00" viewController:self delegate:self];
            } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self showHUDNetError];
            }];
        } else {
            [self showHUDErrorWithText:responseObject[@"reason"]];
        }
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self showHUDErrorWithText:BAD_NETWORK];
    }];
}

/**
 *  查询充值结果
 */
- (void) requestChargeResult {
    [HttpManager requestPhoneChargeOrderStatus:_orderNo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([responseObject[@"code"] integerValue] == 45) {
            //订单结束
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self chargeSuccess];
        } else if([responseObject[@"code"] integerValue] == 43){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            //订单异常
            [self chargeFail];
        } else {
            NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
            if(nowTime - _askTime > MAX_ASK_TIME) {
                //订单异常
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self chargeFail];
            } else {
                //继续轮回
                [self requestChargeResult];
            }
        }
    } fail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self showHUDNetError];
    }];
}

- (void) chargeFail {
    ChargeFailViewController *controller = [[ChargeFailViewController alloc] initWithNibName:@"ChargeFailViewController" bundle:nil];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.navigationBar.barTintColor = AppBlueColor;
    navController.navigationBar.tintColor = [UIColor whiteColor];
    [navController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:FontNeveLightWithSize(16.0)}];
    [delegate.window.rootViewController presentViewController:navController animated:YES completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void) chargeSuccess {
    ChargeSuccessViewController *controller = [[ChargeSuccessViewController alloc] initWithNibName:@"ChargeSuccessViewController" bundle:nil];
    controller.phoneNum = _chargePhone;
    controller.money = _chargeFee;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.navigationBar.barTintColor = AppBlueColor;
    navController.navigationBar.tintColor = [UIColor whiteColor];
    [navController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:FontNeveLightWithSize(16.0)}];
    [delegate.window.rootViewController presentViewController:navController animated:YES completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MobileChargeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IDENTIFIER forIndexPath:indexPath];
    if(indexPath.row == _selectedIndexPath.row) {
        cell.backgroundColor =  ColorWithRGB(255, 138, 0);
        cell.moneyLabel.textColor = [UIColor whiteColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
        cell.moneyLabel.textColor = [UIColor blackColor];
    }
    
    MobileRechargeOrder *order = _data[indexPath.row];
    cell.moneyLabel.text = order.pi_title;
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(_cellWidth, _cellHeight);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _selectedIndexPath = indexPath;
    [_collectionView reloadData];
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

/*
 Discussion
 该方法在用户选择通讯录一级列表的某一项时被调用,通过person可以获得选中联系人的所有信息,但当选中的联系人有多个号码,而我们又希望用户可以明确的指定一个号码时(如拨打电话),返回YES允许通讯录进入联系人详情界面:
 */
- (BOOL)peoplePickerNavigationController: (ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
}

// Called after a property has been selected by the user.
// 8.0之后才会调用
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    if(property == kABPersonPhoneProperty) {
        ABMutableMultiValueRef phoneMulti = ABRecordCopyValue(person, property);
        CFIndex index = ABMultiValueGetIndexForIdentifier(phoneMulti,identifier);
        NSString* phone = [NSString stringWithFormat:@"%@",ABMultiValueCopyValueAtIndex(phoneMulti, index)];
        [_peoplePicker dismissViewControllerAnimated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            _phoneTextField.text = phone;
        }];
    }
    
}

/**
 * 当用户进入单个联系人信息（二级页面）点击某个字段时,会调用如下方法,返回YES继续进入下一步，点击NO不进入下一步，比如点击电话，返回YES就拨打电话，返回NO不拨打电话:
 *
 *  @param peoplePicker
 *  @param person
 *  @param property
 *  @param identifier
 *
 *  @return 
 */
- (BOOL)peoplePickerNavigationController: (ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier {
    
    if (property == kABPersonPhoneProperty) {
        ABMutableMultiValueRef phoneMulti = ABRecordCopyValue(person, property);
        CFIndex index = ABMultiValueGetIndexForIdentifier(phoneMulti,identifier);
        NSString* phone = [NSString stringWithFormat:@"%@",ABMultiValueCopyValueAtIndex(phoneMulti, index)];
        [_peoplePicker dismissViewControllerAnimated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            _phoneTextField.text = phone;
        }];
    }
    return NO;
}

/**
 *
 *
 *  @param peoplePicker
 */
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [peoplePicker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_phoneTextField resignFirstResponder];
}

#pragma mark - UPPayPluginDelegate
-(void)UPPayPluginResult:(NSString*)result {
    if([@"cancel" isEqualToString:result]) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } else if([@"success" isEqualToString:result]) {
        //轮回询问充值是否成功
        _askTime = [[NSDate date] timeIntervalSince1970];
        [self requestChargeResult];
    } else {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self showHUDErrorWithText:result];
    }
}

@end
