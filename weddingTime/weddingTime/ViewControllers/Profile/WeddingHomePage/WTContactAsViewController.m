//
//  WTContactAsViewController.m
//  weddingTime
//
//  Created by wangxiaobo on 16/5/17.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTContactAsViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#define kViewHeight 44.0
#define kLabelWidth 100
@interface WTContactAsViewController () <UITextFieldDelegate>
@property (nonatomic,strong) TPKeyboardAvoidingScrollView *scrollView;
@property (nonatomic,assign) BOOL showPhone;
@property (nonatomic,copy) NSString *phone;
@property (nonatomic,copy) NSString *halfPhone;
@property (nonatomic,strong) UISwitch *switchBtn;
@property (nonatomic,strong) UITextField  *stateTextField;
@property (nonatomic,strong) UITextField  *phoneTextField;
@property (nonatomic,strong) UITextField  *pPhoneTextField;
@property (nonatomic,strong) UIButton *saveButton;
@end

@implementation WTContactAsViewController

+ (instancetype)instanceWithContact:(BOOL)isContact
{
	WTContactAsViewController *VC = [WTContactAsViewController new];
	VC.showPhone = isContact;
	return VC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"联系我们";

	[self setupView];
	[self loadData];
}

- (void)loadData
{
	[self showLoadingView];
	[GetService getShowPhoneWithBlock:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		if(!error && [result[@"success"] boolValue]){
			_phone = [LWUtil getString:result[@"data"][@"own_phone"] andDefaultStr:@""];
			_halfPhone = [LWUtil getString:result[@"data"][@"half_phone"] andDefaultStr:@""];
			_showPhone = [result[@"data"][@"enable_contact"] boolValue];
			[self updateInfo];
		}else{
			[WTProgressHUD ShowTextHUD:result[@"error_message"] ? : @"网络出错，请稍后重试" showInView:self.view];
		}
	}];
}

- (void)updateInfo
{
	_phoneTextField.text = [LWUtil getString:_phone andDefaultStr:@""];
	_pPhoneTextField.text = [LWUtil getString:_halfPhone andDefaultStr:@""];
	_switchBtn.on = self.showPhone;
}

- (void)saveAction:(UIButton *)btn
{
	if(_switchBtn.on == _showPhone && [_phone isEqualToString:_phoneTextField.text] &&  [_halfPhone isEqualToString:_pPhoneTextField.text]){
		[self.navigationController popViewControllerAnimated:YES];
		return ;
	}
	_phone = [LWUtil getString:_phoneTextField.text andDefaultStr:@""];
	_halfPhone = [LWUtil getString:_pPhoneTextField.text andDefaultStr:@""];

	if( [_phone isNotEmptyCtg] && ![LWUtil validatePhoneNumber:_phone]){
		[WTProgressHUD ShowTextHUD:@"请输入正确的手机号码" showInView:self.view];
		return ;
	}
	if( [_halfPhone isNotEmptyCtg] && ![LWUtil validatePhoneNumber:_halfPhone]){
		[WTProgressHUD ShowTextHUD:@"请输入正确的手机号码" showInView:self.view];
		return ;
	}
	[self showLoadingView];
	[PostDataService postWeddingHomeShowPhone:_switchBtn.on myPhone:_phone otherPhone:_halfPhone withBlock:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		if(!error && [result[@"success"] boolValue]){
			if(self.refreshBlock) { self.refreshBlock(_switchBtn.on); }
			[self.navigationController popViewControllerAnimated:YES];
			[[NSNotificationCenter defaultCenter] postNotificationName:HomePageWebShouldBeReloadNotify object:nil];
		}else{
			[WTProgressHUD ShowTextHUD:result[@"error_message"] ? : @"网络出错，请稍后重试" showInView:self.view];
		}
	}];
}

#pragma mark - TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self.view endEditing:YES];
	return YES;
}

- (void)setupView
{
	self.scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - kTabBarHeight)];
	[self.view addSubview:_scrollView];

	UITextField *(^ControlBlock)(CGFloat y,  WTContactListType state,NSString *text) = ^(CGFloat y,  WTContactListType state,NSString *text){
		UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(0, y, screenWidth, kViewHeight)];
		control.backgroundColor = [UIColor clearColor];
		control.tag = state;
		[self.scrollView addSubview:control];

		UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, kViewHeight-0.5, screenWidth-30, 0.5)];
		lineView.backgroundColor = rgba(220, 220, 220, 1);
		[control addSubview:lineView];

		UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, kLabelWidth, kViewHeight-12)];
		leftLabel.font = DefaultFont16;
		leftLabel.textColor = rgba(153, 153, 153, 1);
		leftLabel.text = text;
		[control addSubview:leftLabel];

		UITextField *rightLabel = [[UITextField alloc] initWithFrame:CGRectMake(15+kLabelWidth, 12, screenWidth-30-kLabelWidth, kViewHeight-12)];
		rightLabel.delegate = self;
		rightLabel.font = DefaultFont16;
		rightLabel.textColor = WeddingTimeBaseColor;
		rightLabel.tintColor = WeddingTimeBaseColor;
		rightLabel.textAlignment = NSTextAlignmentRight;
		[rightLabel setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
		[control addSubview:rightLabel];

		return rightLabel;
	};

	_stateTextField = ControlBlock(10,WTContactListTypeState,@"在请柬中显示");
	_phoneTextField = ControlBlock(10+kViewHeight,WTContactListTypePhone,@"我的电话");
	_pPhoneTextField = ControlBlock(10+kViewHeight*2,WTContactListTypePPhone,@"另一半电话");
	_stateTextField.enabled = NO;
	_phoneTextField.returnKeyType = UIReturnKeyDone;
	_pPhoneTextField.returnKeyType = UIReturnKeyDone;

	_switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(screenWidth-50-15, 18, 50, 30)];
	_switchBtn.onTintColor = WeddingTimeBaseColor;
	[self.view addSubview:_switchBtn];

	_saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_saveButton.frame = CGRectMake(0, screenHeight-kNavBarHeight-kTabBarHeight, screenWidth, kTabBarHeight);
	_saveButton.backgroundColor = WeddingTimeBaseColor;
	_saveButton.titleLabel.font = DefaultFont16;
	[_saveButton setTitle:@"保存" forState:UIControlStateNormal];
	[_saveButton addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_saveButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
