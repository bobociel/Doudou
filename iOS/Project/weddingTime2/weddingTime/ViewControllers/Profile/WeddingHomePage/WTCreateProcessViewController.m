//
//  WTCreateProcessViewController.m
//  weddingTime
//
//  Created by wangxiaobo on 16/5/31.
//  Copyright © 2016年 默默. All rights reserved.
//

#import "WTCreateProcessViewController.h"
#import "CommDatePickView.h"
#define kViewHeight 44.0
#define kLabelWidth 40
#define kMaxContent 128
@interface WTCreateProcessViewController () <UITextViewDelegate,CommDatePickViewDelegate>
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) CommDatePickView *datePicker;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UILabel *placeholderLabel;
@property (nonatomic,strong) UITextView *contentTextView;
@property (nonatomic,strong) UIButton *saveButton;
@property (nonatomic,strong) WTWeddingProcess *process;
@property (nonatomic,assign) unsigned long long processTime;
@end

@implementation WTCreateProcessViewController
+ (instancetype)instanceWithWeddingProcess:(WTWeddingProcess *)process
{
	WTCreateProcessViewController *VC = [WTCreateProcessViewController new];
	VC.process = process;
	VC.processTime = process.time;
	return VC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setupView];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardFrameChanged:(NSNotification *)noti
{
	CGRect keyFrame = [(NSValue *)noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	if(keyFrame.origin.y == screenHeight){
		_scrollView.frame = CGRectMake(0, 0, screenWidth,screenHeight - kNavBarHeight - kTabBarHeight);
		_contentTextView.height = _scrollView.height - _contentTextView.top;
	}else{
		[UIView animateKeyframesWithDuration:0.25 delay:0 options:7 animations:^{
			_scrollView.frame = CGRectMake(0, 0, screenWidth, keyFrame.origin.y - kNavBarHeight);
			_contentTextView.height = _scrollView.height - _contentTextView.top;
		} completion:nil];
	}
}

#pragma mark - Action
- (void)saveAction:(UIButton *)sender
{
	if(_processTime == 0){
		[WTProgressHUD ShowTextHUD:@"请选择时间" showInView:self.view];
		return ;
	}
	if(_contentTextView.text.length == 0){
		[WTProgressHUD ShowTextHUD:@"请输入内容" showInView:self.view];
		return ;
	}

	WTWeddingProcess *progress = [WTWeddingProcess new];
	progress.ID = _process.ID ?: @"0";
	progress.content = _contentTextView.text ?: @"";
	progress.time = _processTime;

	[self showLoadingView];
	[PostDataService postWeddingProcess:progress callback:^(NSDictionary *result, NSError *error) {
		[self hideLoadingView];
		if(!error && result[@"success"]){
			[WTProgressHUD ShowTextHUD:@"保存成功" showInView:nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:HomePageWebShouldBeReloadNotify object:nil];
			if(self.refreshBlock) { self.refreshBlock(YES); }
			[self.navigationController popViewControllerAnimated:YES];
		}else{
			[WTProgressHUD ShowTextHUD:result[@"error_message"] ?: @"网络出错，请稍后重试" showInView:self.scrollView];
		}
	}];
}

- (void)chooseTime:(UIControl *)sender
{
	[self.view endEditing:YES];
	[_datePicker showWithType:PickerViewTypeTime];
}

#pragma mark - DatePickerViewDelegate
- (void)didPickDataWithDate:(NSDate *)date andType:(PickerViewType)type
{
	_processTime = [date timeIntervalSince1970];

	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"HH:mm"];
	NSDate *aDate = [NSDate dateWithTimeIntervalSince1970:_processTime];

	_timeLabel.text = [dateFormatter stringFromDate:aDate];
}

#pragma mark - TextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
	_placeholderLabel.hidden = _contentTextView.text.length > 0;
	if(!textView.markedTextRange){
		textView.text = [textView.text substringWithRange:NSMakeRange(0,MIN(kMaxContent,textView.text.length))];
	}
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if ([text isEqualToString:@"\n"]) {
		[textView resignFirstResponder];
		return NO;
	}
	return YES;
}

#pragma mark - View
- (void)setupView
{
	self.title = @"日程安排";

	self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - kNavBarHeight - kTabBarHeight)];
	[self.view addSubview:_scrollView];

	UILabel *(^ControlBlock)(CGFloat y,  WTProInputType state,NSString *text) = ^(CGFloat y,  WTProInputType state,NSString *text){
		UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(0, y, screenWidth, kViewHeight)];
		control.backgroundColor = [UIColor clearColor];
		control.tag = state;
		[self.scrollView addSubview:control];
		[control addTarget:self action:@selector(chooseTime:) forControlEvents:UIControlEventTouchUpInside];

		UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, kViewHeight-0.5, screenWidth-30, 0.5)];
		lineView.backgroundColor = rgba(220, 220, 220, 1);
		[control addSubview:lineView];

		UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, kLabelWidth, kViewHeight-12)];
		leftLabel.font = DefaultFont16;
		leftLabel.textColor = rgba(170, 170, 170, 1);
		leftLabel.text = text;
		[control addSubview:leftLabel];

		UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(15+kLabelWidth, 12, screenWidth-30-kLabelWidth, kViewHeight-12)];
		rightLabel.font = DefaultFont16;
		rightLabel.textColor = WeddingTimeBaseColor;
		rightLabel.textAlignment = NSTextAlignmentRight;
		[control addSubview:rightLabel];

		return rightLabel;
	};

	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"HH:mm"];
	NSDate *aDate = [NSDate dateWithTimeIntervalSince1970:_process.time];

	_timeLabel = ControlBlock(10,WTProInputTypeTime,@"时间");
	_timeLabel.text = _process.time == 0 ? @"0:00" : [dateFormatter stringFromDate:aDate];

	_contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(13,_timeLabel.bottom+20,screenWidth-26,100)];
	_contentTextView.height = _scrollView.height - _contentTextView.top;
	_contentTextView.layoutManager.allowsNonContiguousLayout = NO;
	_contentTextView.returnKeyType = UIReturnKeyDone;
	_contentTextView.delegate = self;
	_contentTextView.font = DefaultFont16;
	[self.scrollView addSubview:_contentTextView];
	_contentTextView.text = [LWUtil getString:_process.content andDefaultStr:@""];

	_placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, _timeLabel.bottom+25, screenWidth-26, 20)];
	_placeholderLabel.font = DefaultFont16;
	_placeholderLabel.textColor = rgba(204, 204, 204, 1);
	_placeholderLabel.text = @"输入相关事宜";
	[self.scrollView addSubview:_placeholderLabel];
	_placeholderLabel.hidden = _contentTextView.text.length > 0;

	_saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_saveButton.frame = CGRectMake(0, screenHeight-kNavBarHeight-kTabBarHeight, screenWidth, kTabBarHeight);
	_saveButton.backgroundColor = WeddingTimeBaseColor;
	_saveButton.titleLabel.font = DefaultFont16;
	[_saveButton setTitle:@"保存" forState:UIControlStateNormal];
	[_saveButton addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_saveButton];

	_datePicker = [CommDatePickView viewWithStyle:PickerViewStyleDefault];
	_datePicker.delagate = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
