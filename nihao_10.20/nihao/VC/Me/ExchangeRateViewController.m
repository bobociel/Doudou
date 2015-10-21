//
//  ExchangeRateViewController.m
//  nihao
//
//  Created by HelloWorld on 7/21/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "ExchangeRateViewController.h"
#import "SelectCurrencyCodeViewController.h"
#import "HttpManager.h"
#import "ExchangeRateResult.h"
#import <MJExtension/MJExtension.h>
//#import "BaseFunction.h"

#define LeftCurrencyTypeTag 0
#define RightCurrencyTypeTag 1

@interface ExchangeRateViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *currencyTypeView;
@property (weak, nonatomic) IBOutlet UILabel *leftCurrencyTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightCurrencyTypeLabel;
@property (weak, nonatomic) IBOutlet UIView *resultView;
@property (weak, nonatomic) IBOutlet UITextField *leftCurrencyTypeTextField;
@property (weak, nonatomic) IBOutlet UITextField *rightCurrencyTypeTextField;
@property (weak, nonatomic) IBOutlet UILabel *leftCurrencyTypeERLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightCurrencyTypeERLabel;
@property (weak, nonatomic) IBOutlet UIButton *calcButton;

@end

@implementation ExchangeRateViewController {
	ExchangeRateResult *exchangeRateResult;
}

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	self.title = @"Exchange Rate";
	[self dontShowBackButtonTitle];
	
	[self drawLines];
	
	[self setButtonState:ButtonStateDisable];
	[self hidesLabels:YES];
}

#pragma mark - Lifecycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Touch Events

- (IBAction)selectCurrencyType:(UIControl *)sender {
	SelectCurrencyCodeViewController *selectCurrencyCodeViewController = [[SelectCurrencyCodeViewController alloc] init];
	UINavigationController *nav = [self navigationControllerWithRootViewController:selectCurrencyCodeViewController navBarTintColor:AppBlueColor];
	
	if (sender.tag == LeftCurrencyTypeTag) {
		selectCurrencyCodeViewController.selectCurrencyCodeType = SelectCurrencyCodeTypeLeft;
	} else if (sender.tag == RightCurrencyTypeTag) {
		selectCurrencyCodeViewController.selectCurrencyCodeType = SelectCurrencyCodeTypeRight;
	}
	
	__weak typeof(self) weakSelf = self;
	selectCurrencyCodeViewController.selectedCurrencyCode = ^(SelectCurrencyCodeType type, NSString *currencyCode) {
		[weakSelf selectedCurrencyCodeWithType:type currencyCode:currencyCode];
	};
	
	[self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)exchange:(id)sender {
	[self exchangeCurrencyType];
}

- (IBAction)calculate:(id)sender {
	[self.leftCurrencyTypeTextField resignFirstResponder];
	[self calculateExchangeRate];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	if (textField == self.rightCurrencyTypeTextField) {
		return NO;
	} else {
		textField.textColor = TextFieldBeginEditingColor;
		return YES;
	}
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	textField.textColor = TextFieldEndEditingColor;
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if (textField == self.leftCurrencyTypeTextField) {
		[self calculateExchangeRate];
	}
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	if (textField == self.rightCurrencyTypeTextField) {
		return NO;
	} else {
//		NSLog(@"left textfield clear");
		self.rightCurrencyTypeTextField.text = @"";
		[self setButtonState:ButtonStateDisable];
		return YES;
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.rightCurrencyTypeTextField) {
		return NO;
	} else {
//		NSLog(@"left textfield return");
		[textField resignFirstResponder];
		[self calculateExchangeRate];
		return YES;
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//	NSLog(@"string = %@, textField.text = %@, string.length = %ld", string, textField.text, string.length);
	if (string.length) {// 输入文本
		[self setButtonState:ButtonStateClickable];
	} else {// 删除文本
		if (textField.text.length - 1 == 0) {
			[self setButtonState:ButtonStateDisable];
		}
	}
	
	return YES;
}

#pragma mark - Private

- (void)drawLines {
	UIView *line0 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.currencyTypeView.frame) - 0.5, SCREEN_WIDTH, 0.5)];
	line0.backgroundColor = SeparatorColor;
	[self.currencyTypeView addSubview:line0];
	
	UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.resultView.frame) - 0.5, SCREEN_WIDTH, 0.5)];
	line1.backgroundColor = SeparatorColor;
	[self.resultView addSubview:line1];
}

- (void)exchangeCurrencyType {
	NSString *leftCurrencyName = self.leftCurrencyTypeLabel.text;
	NSString *rightCurrencyName = self.rightCurrencyTypeLabel.text;
	
	self.leftCurrencyTypeLabel.text = rightCurrencyName;
	self.rightCurrencyTypeLabel.text = leftCurrencyName;
	self.leftCurrencyTypeTextField.placeholder = rightCurrencyName;
	self.rightCurrencyTypeTextField.placeholder = leftCurrencyName;
	
	[self calculateExchangeRate];
}

- (void)selectedCurrencyCodeWithType:(SelectCurrencyCodeType)type currencyCode:(NSString *)code {
	if (type == SelectCurrencyCodeTypeLeft) {
		self.leftCurrencyTypeLabel.text = code;
		self.leftCurrencyTypeTextField.placeholder = code;
	} else if (type == SelectCurrencyCodeTypeRight) {
		self.rightCurrencyTypeLabel.text = code;
		self.rightCurrencyTypeTextField.placeholder = code;
	}
	[self calculateExchangeRate];
}

/**
 *  设置按钮的状态
 *
 *  @param state 可点击BUTTON_STATE_CLICKABLE or 不可点击BUTTON_STATE_UNCLICKABLE
 */
- (void)setButtonState:(ButtonState)state {
	if(state == ButtonStateClickable) {
		[self.calcButton setBackgroundColor:BUTTON_ENABLED_COLOR];
		self.calcButton.userInteractionEnabled = YES;
	} else {
		[self.calcButton setBackgroundColor:BUTTON_DISABLED_COLOR];
		self.calcButton.userInteractionEnabled = NO;
	}
}

- (void)hidesLabels:(BOOL)hides {
	self.leftCurrencyTypeERLabel.hidden = hides;
	self.rightCurrencyTypeERLabel.hidden = hides;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.view endEditing:YES];
}

#pragma mark - Network

- (void)calculateExchangeRate {
	if (self.leftCurrencyTypeTextField.text.length > 0) {
		float amount = [self.leftCurrencyTypeTextField.text floatValue];
		if (amount > 0) {
			[self showHUDWithText:@""];
			NSString *amountString = [NSString stringWithFormat:@"%.2f", amount];
			NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[self.leftCurrencyTypeLabel.text, self.rightCurrencyTypeLabel.text, amountString] forKeys:@[@"fromCurrency", @"toCurrency", @"amount"]];
			[HttpManager calculateExchangeRateByParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
				NSLog(@"responseObject = %@", responseObject);
				if ([responseObject[@"errNum"] integerValue] == 0) {
					exchangeRateResult = [ExchangeRateResult objectWithKeyValues:responseObject[@"retData"]];
					[self hideHud];
					self.rightCurrencyTypeTextField.text = [NSString stringWithFormat:@"%.2lf", exchangeRateResult.convertedamount];
					self.leftCurrencyTypeERLabel.text = [NSString stringWithFormat:@"1 %@ = %.2lf %@", self.leftCurrencyTypeLabel.text, [exchangeRateResult.currency floatValue], self.rightCurrencyTypeLabel.text];
					NSString *reverseRate = [NSString stringWithFormat:@"%.2lf", 1 / [exchangeRateResult.currency floatValue]];
					self.rightCurrencyTypeERLabel.text = [NSString stringWithFormat:@"1 %@ = %@ %@", self.rightCurrencyTypeLabel.text, reverseRate, self.leftCurrencyTypeLabel.text];
					[self hidesLabels:NO];
				} else {
					[self showHUDErrorWithText:responseObject[@"errMsg"]];
				}
			} failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
				NSLog(@"Error: %@", error);
				[self showHUDNetError];
			}];
		}
	}
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
