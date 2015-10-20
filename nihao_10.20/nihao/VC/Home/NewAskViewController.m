//
//  NewAskViewController.m
//  nihao
//
//  Created by HelloWorld on 7/13/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "NewAskViewController.h"
#import "PlaceholderTextView.h"
#import "AppConfigure.h"
#import "HttpManager.h"
#import <JDStatusBarNotification.h>
#import "SelectCityViewController.h"
#import "AskCategory.h"
//#import "LiveCitiesViewController.h"
#import "City.h"
#import "AskContent.h"
#import <MJExtension/MJExtension.h>

@interface NewAskViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UITextField *questionTitleTextField;
@property (weak, nonatomic) IBOutlet PlaceholderTextView *questionContentTextView;
@property (weak, nonatomic) IBOutlet UILabel *selectedCityNameLabel;
@property (weak, nonatomic) IBOutlet UIView *questionBGView;

@end

@implementation NewAskViewController

#pragma mark - view life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	self.title = @"Ask";
	[self dontShowBackButtonTitle];
	
	if (self.askCategory) {
		// 设置导航栏按钮的点击执行方法等
		UIBarButtonItem *postItem = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:@selector(postNewQuestion)];
		self.navigationItem.rightBarButtonItem = postItem;
		self.navigationItem.rightBarButtonItem.enabled = NO;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionTitleDidChanged:) name:UITextFieldTextDidChangeNotification object:self.questionTitleTextField];
	}
	
	[self initViews];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

#pragma mark Lifecycle

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initViews {
	self.mainView.frame = CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(self.mainView.frame));
	self.scrollView.contentSize = self.mainView.frame.size;
	[self.scrollView addSubview:self.mainView];
	self.scrollView.backgroundColor = self.view.backgroundColor;
	self.mainView.backgroundColor = self.scrollView.backgroundColor;
	
	// 分隔线
	UIView *separatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.questionTitleTextField.frame), SCREEN_WIDTH, 0.5)];
	separatorLine.backgroundColor = SeparatorColor;
	[self.questionBGView addSubview:separatorLine];
	
	self.questionTitleTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Your question" attributes:@{NSForegroundColorAttributeName : HintTextColor}];
	
	self.questionContentTextView.placeholder = @"Question description";
	self.questionContentTextView.placeholderFont = FontNeveLightWithSize(16.0);
	self.questionContentTextView.placeholderColor = HintTextColor;
	self.questionContentTextView.font = FontNeveLightWithSize(16.0);
	self.questionContentTextView.textColor = TextColor575757;
	
//	//如果当前城市为nil，则使用默认服务城市
//	City *city = [City getCityFromUserDefault:CURRENT_CITY];
//	if(!city) {
//		city = [City getCityFromUserDefault:DEFAULT_CITY];
//		[City saveCityToUserDefault:city key:CURRENT_CITY];
//	}
//	cityID = city.city_id;
	self.selectedCityNameLabel.text = self.currentCityName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self.view endEditing:YES];
}

#pragma mark - NSNotification

- (void)questionTitleDidChanged:(NSNotification* )notification {
	if (self.questionTitleTextField.text.length > 0) {
		self.navigationItem.rightBarButtonItem.enabled = YES;
	} else {
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
}

#pragma mark - click events

- (void)postNewQuestion {
	[JDStatusBarNotification showWithStatus:@"Posting..." dismissAfter:1.5 styleName:JDStatusBarStyleDark];
	
	NSString *userID = [AppConfigure objectForKey:LOGINED_USER_ID];
	NSString *categoryID = [NSString stringWithFormat:@"%ld", self.askCategory.akc_id];
	NSString *questionTitle = self.questionTitleTextField.text;
	NSString *questionDescription = self.questionContentTextView.text;
	NSString *cityIDString = [NSString stringWithFormat:@"%ld", self.currentCityID];
	
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setValue:userID forKey:@"ci_id"];
	[parameters setValue:categoryID forKey:@"aki_akc_id"];
	if (self.currentCityID != 0) {// 不是全国
		[parameters setValue:cityIDString forKey:@"aki_area"];
	}
	[parameters setValue:questionTitle forKey:@"aki_title"];
	if (IsStringNotEmpty(questionDescription)) {
		[parameters setValue:questionDescription forKey:@"aki_info"];
	}
	
	NSLog(@"publish ask parameters = %@", parameters);
	[HttpManager publishNewAskByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *resultDict = (NSDictionary *)responseObject;
		NSInteger rtnCode = [resultDict[@"code"] integerValue];
		if (rtnCode == 0) {
			[JDStatusBarNotification showWithStatus:@"Send Successfully!" dismissAfter:1.5 styleName:JDStatusBarStyleDark];
			AskContent *askContent = [AskContent objectWithKeyValues:resultDict[@"result"]];
			NSString *nickname = [AppConfigure valueForKey:LOGINED_USER_NICKNAME];
			askContent.aki_source_nikename = nickname;
			if (self.postAsk) {
				self.postAsk(askContent);
			}
		}
	} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"error = %@", error);
		[JDStatusBarNotification showWithStatus:@"Send fail!" dismissAfter:1.5 styleName:JDStatusBarStyleDark];
	}];
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)selectCity:(id)sender {
	SelectCityViewController *selectCityViewController = [[SelectCityViewController alloc] init];
	selectCityViewController.askCategoryID = [NSString stringWithFormat:@"%ld", self.askCategory.akc_id];
//	selectCityViewController.currentCityName = self.currentCityName;
//	selectCityViewController.currentCityID = self.currentCityID;
	selectCityViewController.selectCityFromType = SelectCityFromTypeNewAsk;
	__weak typeof(self) weakSelf = self;
	selectCityViewController.selectedCity = ^(NSString *cityName, NSInteger cityID) {
//		NSLog(@"NewAskViewController cityName = %@, cityID = %ld", cityName, cityID);
		__strong typeof(weakSelf) strongSelf = weakSelf;
		[strongSelf selectedCityWithName:cityName cityID:cityID];
	};
	UINavigationController *nav = [self navigationControllerWithRootViewController:selectCityViewController navBarTintColor:AppBlueColor];
	[self presentViewController:nav animated:YES completion:nil];
	
//	LiveCitiesViewController *liveCitiesViewController = [[LiveCitiesViewController alloc] init];
//	liveCitiesViewController.selectCityType = SelectCityTypeAsk;
//	__weak typeof(self) weakSelf = self;
//	liveCitiesViewController.cityChoosed = ^(City *city) {
//		[weakSelf selectedCityWithName:city.city_name_en cityID:city.city_id];
//	};
//	UINavigationController *nav = [self navigationControllerWithRootViewController:liveCitiesViewController navBarTintColor:AppBlueColor];
//	[self presentViewController:nav animated:YES completion:nil];
}

- (void)selectedCityWithName:(NSString *)cityName cityID:(NSInteger)cityID {
	self.currentCityName = cityName;
	self.currentCityID = cityID;
	self.selectedCityNameLabel.text = self.currentCityName;
}

- (void)keyBoardHidden {
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
