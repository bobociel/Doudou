//
//  PPNatAndBirthViewController.m
//  nihao
//
//  Created by HelloWorld on 6/9/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "PPNatAndBirthViewController.h"
#import "BaseFunction.h"
#import "PPAddFriendsViewController.h"
#import "NationalityViewController.h"
#import "LiveCitiesViewController.h"
#import "Nationality.h"
#import "City.h"
#import "AppConfigure.h"

@interface PPNatAndBirthViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIButton *nationalityBtn;
@property (strong, nonatomic) UIButton *cityBtn;
@property (strong, nonatomic) UILabel *birthDayLabel;
@property (strong, nonatomic) UIButton *nextBtn;
@property (strong, nonatomic) UIDatePicker *birthDayPicker;

@end

@implementation PPNatAndBirthViewController {
	// 保存用户选择的国家 ID
    NSString *userNationalityID;
	// 保存用户选择的居住城市 ID
    NSString *userCityID;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Personal Profile";
    [self dontShowBackButtonTitle];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(self.view.frame) - 64)];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.contentSize = CGSizeMake(0, 0);
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    // 初始化国籍和居住城市选择按钮
//    UIView *nationalityView = [[UIView alloc] initWithFrame:CGRectMake(37, 30, SCREEN_WIDTH - 37 * 2, 33)];
//    self.nationalityBtn = [self getButtonWithFrame:nationalityView.bounds title:@"Nationality"];
//    [self.nationalityBtn addTarget:self action:@selector(nationalityBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIView *cityView = [[UIView alloc] initWithFrame:CGRectMake(37, CGRectGetMaxY(nationalityView.frame) + 14, SCREEN_WIDTH - 37 * 2, 33)];
//    self.cityBtn = [self getButtonWithFrame:cityView.bounds title:@"City of Residence"];
//    [self.cityBtn addTarget:self action:@selector(cityBtnClick) forControlEvents:UIControlEventTouchUpInside];
	
//    UIImage *arrowImg = [UIImage imageNamed:@"icon_right_arrow_blue"];
//    UIImageView *nArrow = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(nationalityView.frame) - 15 - 8, (CGRectGetHeight(nationalityView.frame) - 14) / 2, 8, 14)];
//    nArrow.image = arrowImg;
//    UIImageView *cArrow = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(cityView.frame) - 15 - 8, (CGRectGetHeight(nationalityView.frame) - 14) / 2, 8, 14)];
//    cArrow.image = arrowImg;
//    
//    [nationalityView addSubview:self.nationalityBtn];
//    [cityView addSubview:self.cityBtn];
//    [nationalityView addSubview:nArrow];
//    [cityView addSubview:cArrow];
//    
//    [self.scrollView addSubview:nationalityView];
//    [self.scrollView addSubview:cityView];
//    
//    // 初始化UILabel
//    self.birthDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(cityView.frame) + 35, SCREEN_WIDTH - 30, 25)];
//    self.birthDayLabel.text = @"Date of birth";
//    self.birthDayLabel.textColor = NormalTextColor;
//    self.birthDayLabel.font = FontNeveLightWithSize(16.0);
//    self.birthDayLabel.numberOfLines = 0;
//    self.birthDayLabel.lineBreakMode = NSLineBreakByWordWrapping;
//    [self.birthDayLabel sizeToFit];
//    [self.birthDayLabel setNeedsDisplay];
//    [self.scrollView addSubview:self.birthDayLabel];
//    
//    // 初始化日期选择控件
//    self.birthDayPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.birthDayLabel.frame) + 20, SCREEN_WIDTH, 70)];
//    self.birthDayPicker.datePickerMode = UIDatePickerModeDate;
//    self.birthDayPicker.date = [BaseFunction dateFromString:@"1987-01-01"];
//    self.birthDayPicker.maximumDate = [NSDate date];
//    [self.scrollView addSubview:self.birthDayPicker];
//    
//    // 初始化Next按钮
//    self.nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.birthDayPicker.frame) + 50, SCREEN_WIDTH - 40, 40)];
//    self.nextBtn.backgroundColor = AppBlueColor;
//    [self.nextBtn setTitle:@"Next" forState:UIControlStateNormal];
//    [self.nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    self.nextBtn.titleLabel.font = FontNeveLightWithSize(18.0);
//    [self.nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.scrollView addSubview:self.nextBtn];
//    
//    [self.view addSubview:self.scrollView];
	
//    NSLog(@"PPNatAndBirthViewController -> userRegisterInfo = %@", self.userRegisterInfo);
}

#pragma mark - Lifecycle

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - click events
// 选择国家
- (void)nationalityBtnClick {
    NationalityViewController *controller = [[NationalityViewController alloc] initWithNibName:@"NationalityViewController" bundle:nil];
    controller.nationChoosed = ^(Nationality *nation) {
        userNationalityID = [NSString stringWithFormat:@"%ld", nation.country_id];
        [self.nationalityBtn setTitle:nation.country_name_en forState:UIControlStateNormal];
		[AppConfigure setObject:userNationalityID ForKey:LOGINED_USER_COUNTRY_ID];
		[AppConfigure setObject:nation.country_name_en ForKey:LOGINED_USER_COUNTRY_NAME_EN];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

// 选择居住城市
- (void)cityBtnClick {
    LiveCitiesViewController *controller = [[LiveCitiesViewController alloc] initWithNibName:@"LiveCitiesViewController" bundle:nil];
    controller.cityChoosed = ^(City *city) {
        userCityID = [NSString stringWithFormat:@"%d", city.city_id];
        [self.cityBtn setTitle:city.city_name_en forState:UIControlStateNormal];
		[AppConfigure setObject:userCityID ForKey:LOGINED_USER_CITY_ID];
		[AppConfigure setObject:city.city_name_en ForKey:LOGINED_USER_CITY_NAME_EN];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)nextBtnClick {
    if (IsStringEmpty(userNationalityID)) {
        [self showHUDErrorWithText:@"select your nationality"];
        return;
    }
    if (IsStringEmpty(userCityID)) {
        [self showHUDErrorWithText:@"select city of residence"];
        return;
    }
	
    // 保存用户国籍id
//    [self.userRegisterInfo setValue:userNationalityID forKey:USER_PP_NATIONALITY_ID];
    // 保存用户居住城市id
//    [self.userRegisterInfo setValue:userCityID forKey:USER_PP_LIVE_CITY_ID];
    // 保存用户生日
//    NSInteger age = [BaseFunction calculateAgeByBirthday:self.birthDayPicker.date];
//    NSString *birthday = [BaseFunction stringDateFromDate:self.birthDayPicker.date];
//	[AppConfigure setValue:birthday forKey:LOGINED_USER_BIRTHDAY];
//    [self.userRegisterInfo setValue:birthday forKey:USER_PP_BIRTHDAY];
//    [self.userRegisterInfo setValue:[NSString stringWithFormat:@"%ld", age] forKey:USER_PP_AGE];
	
//    PPAddFriendsViewController *addFriendsViewController = [[PPAddFriendsViewController alloc] init];
//    addFriendsViewController.userRegisterInfo = self.userRegisterInfo;
//    [self.navigationController pushViewController:addFriendsViewController animated:YES];
}

//- (UIButton *)getButtonWithFrame:(CGRect)frame title:(NSString *)title {
//    UIButton *button = [[UIButton alloc] initWithFrame:frame];
//    [button setTitle:title forState:UIControlStateNormal];
//    button.layer.masksToBounds = YES;
//    button.titleLabel.font = FontNeveLightWithSize(14.0);
//    button.layer.borderWidth = 1;
//    button.layer.borderColor = AppBlueColor.CGColor;
//    [button setTitleColor:AppBlueColor forState:UIControlStateNormal];
//    button.backgroundColor = [UIColor whiteColor];
//    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//    button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    
//    return button;
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
